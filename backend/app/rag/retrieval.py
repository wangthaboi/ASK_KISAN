"""Shared vector retrieval for ASK KISAN's JSON-backed embedding store."""

from __future__ import annotations

import json
import math
from dataclasses import dataclass

from openai import OpenAI
from sqlalchemy import text

from app.config import EMBEDDING_MODEL, OPENAI_API_KEY
from app.database.db import engine


@dataclass(frozen=True)
class RetrievedRecord:
    source_table: str
    source_id: int
    content: str
    score: float


def embed_query(query: str) -> list[float]:
    if not OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not configured.")
    client = OpenAI(api_key=OPENAI_API_KEY)
    return client.embeddings.create(model=EMBEDDING_MODEL, input=query).data[0].embedding


def cosine_similarity(left: list[float], right: list[float]) -> float:
    if len(left) != len(right) or not left or not right:
        return -1.0
    denominator = math.sqrt(sum(value * value for value in left)) * math.sqrt(sum(value * value for value in right))
    return sum(a * b for a, b in zip(left, right)) / denominator if denominator else -1.0


def retrieve(query: str, limit: int = 5) -> list[RetrievedRecord]:
    """Rank the current JSON vectors with the same model used for source content."""
    query_vector = embed_query(query)
    with engine.connect() as conn:
        rows = conn.execute(text("""
            SELECT source_table, source_id, content, vector
            FROM vector_embeddings
            WHERE vector IS NOT NULL AND JSON_LENGTH(vector) > 0
        """)).mappings().all()
    ranked: list[RetrievedRecord] = []
    seen_sources: set[tuple[str, int]] = set()
    for row in rows:
        source_key = (row["source_table"], int(row["source_id"]))
        if source_key in seen_sources:
            continue
        try:
            vector = row["vector"] if isinstance(row["vector"], list) else json.loads(row["vector"])
            score = cosine_similarity(query_vector, vector)
        except (TypeError, ValueError, json.JSONDecodeError):
            continue
        if score >= 0:
            seen_sources.add(source_key)
            ranked.append(RetrievedRecord(source_key[0], source_key[1], row["content"], score))
    return sorted(ranked, key=lambda result: result.score, reverse=True)[:limit]


def format_context(results: list[RetrievedRecord]) -> str:
    return "\n\n".join(
        f"Source: {result.source_table}:{result.source_id} (similarity {result.score:.3f})\n{result.content}"
        for result in results
    )
