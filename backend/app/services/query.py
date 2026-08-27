"""Grounded answer generation for the public farmer-query endpoint."""

from __future__ import annotations

from openai import OpenAI

from app.config import CHAT_MODEL, OPENAI_API_KEY
from app.rag.retrieval import RetrievedRecord, format_context, retrieve


SYSTEM_PROMPT = """
You are ASK KISAN, an AI assistant for Indian farmers. Answer the farmer's
question using only the supplied agricultural and scheme source material.
Do not invent facts, recommendations, eligibility rules, or procedures. If the
sources do not provide enough information, say so plainly and encourage the
farmer to verify time-sensitive advice with a local agricultural officer or an
official government source. Keep the response practical, concise, and in the
language requested by the farmer when possible.
""".strip()


def source_references(results: list[RetrievedRecord]) -> list[str] | None:
    """Return stable source identifiers without exposing database content."""
    references = [f"{result.source_table}:{result.source_id}" for result in results]
    return references or None


def answer_question(question: str, language: str) -> tuple[str, list[str] | None]:
    """Retrieve authoritative context and generate a grounded answer."""
    if not OPENAI_API_KEY:
        raise RuntimeError("The query service is not configured with an OpenAI API key.")

    results = retrieve(question)
    sources = source_references(results)
    if not results:
        return (
            "I could not find enough verified information in Ask Kisan's current knowledge base to answer that safely.",
            None,
        )

    response = OpenAI(api_key=OPENAI_API_KEY).chat.completions.create(
        model=CHAT_MODEL,
        temperature=0.2,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": (
                    f"Requested response language: {language}\n\n"
                    f"Farmer question: {question}\n\n"
                    f"Verified source material:\n{format_context(results)}"
                ),
            },
        ],
    )
    answer = response.choices[0].message.content
    if not answer:
        raise RuntimeError("The language model returned an empty answer.")
    return answer, sources
