"""Shared vector retrieval for ASK KISAN's embedding store."""

from __future__ import annotations

import json
import logging
import math
from dataclasses import dataclass

from sqlalchemy import text

from app.config import EMBEDDING_MODEL, OPENAI_API_KEY, RAG_SIMILARITY_THRESHOLD
from app.database.db import engine

logger = logging.getLogger(__name__)

_fastembed_model = None


def get_embedding_model():
    """Lazily load the FastEmbed model (sentence-transformers/all-MiniLM-L6-v2)."""
    global _fastembed_model
    if _fastembed_model is None:
        from fastembed import TextEmbedding
        _fastembed_model = TextEmbedding(model_name="sentence-transformers/all-MiniLM-L6-v2")
    return _fastembed_model


@dataclass(frozen=True)
class RetrievedRecord:
    source_table: str
    source_id: int
    content: str
    score: float


def embed_query(query: str) -> list[float]:
    """Generate vector embedding using local FastEmbed, falling back to OpenAI if configured."""
    try:
        model = get_embedding_model()
        embeddings = list(model.embed([query]))
        return [float(val) for val in embeddings[0]]
    except ImportError:
        # Fallback to OpenAI if fastembed is not installed and key is provided
        if OPENAI_API_KEY:
            try:
                from openai import OpenAI
                client = OpenAI(api_key=OPENAI_API_KEY)
                return client.embeddings.create(model=EMBEDDING_MODEL, input=query).data[0].embedding
            except Exception as err:
                logger.warning("OpenAI embedding fallback failed: %s", err)
        return []
    except Exception as exc:
        logger.warning("Local FastEmbed embedding failed: %s", exc)
        return []


def cosine_similarity(left: list[float], right: list[float]) -> float:
    if len(left) != len(right) or not left or not right:
        return -1.0
    denominator = math.sqrt(sum(value * value for value in left)) * math.sqrt(sum(value * value for value in right))
    return sum(a * b for a, b in zip(left, right)) / denominator if denominator else -1.0


def retrieve(query: str, limit: int = 5, min_score: float = RAG_SIMILARITY_THRESHOLD) -> list[RetrievedRecord]:
    """Rank the current JSON vectors with the same model used for source content, filtering below min_score."""
    query_vector = embed_query(query)
    if not query_vector:
        return []

    try:
        with engine.connect() as conn:
            rows = conn.execute(text("""
                SELECT source_table, source_id, content, vector
                FROM vector_embeddings
                WHERE vector IS NOT NULL
            """)).mappings().all()
    except Exception as exc:
        logger.warning("Database retrieval failed: %s", exc)
        return []

    ranked: list[RetrievedRecord] = []
    seen_sources: set[tuple[str, int]] = set()
    for row in rows:
        source_key = (row["source_table"], int(row["source_id"]))
        if source_key in seen_sources:
            continue
        try:
            vector = row["vector"] if isinstance(row["vector"], list) else json.loads(row["vector"])
            if not vector or not isinstance(vector, list):
                continue
            score = cosine_similarity(query_vector, vector)
        except (TypeError, ValueError, json.JSONDecodeError):
            continue
        if score >= min_score:
            seen_sources.add(source_key)
            ranked.append(RetrievedRecord(source_key[0], source_key[1], row["content"], score))
    return sorted(ranked, key=lambda result: result.score, reverse=True)[:limit]


def format_context(results: list[RetrievedRecord]) -> str:
    return "\n\n".join(
        f"Source: {result.source_table}:{result.source_id} (similarity {result.score:.3f})\n{result.content}"
        for result in results
    )
