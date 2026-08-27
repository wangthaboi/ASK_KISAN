"""Schemas for public, anonymous farmer queries."""

from __future__ import annotations

from pydantic import BaseModel, Field, field_validator


class QueryRequest(BaseModel):
    question: str = Field(min_length=1, max_length=1000)
    language: str | None = Field(default="en", max_length=16)
    session_id: str | None = Field(default=None, max_length=128)

    @field_validator("question")
    @classmethod
    def question_must_not_be_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Question must not be blank.")
        return value

    @field_validator("language")
    @classmethod
    def normalize_language(cls, value: str | None) -> str:
        return (value or "en").strip().lower() or "en"


class QueryResponse(BaseModel):
    answer: str
    sources: list[str] | None = None
    session_id: str
