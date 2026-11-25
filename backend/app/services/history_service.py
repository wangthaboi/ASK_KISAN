"""Multi-turn conversation history and sliding window memory."""

from __future__ import annotations

import logging
from sqlalchemy import select
from app.database.db import engine
from app.database.schema import chat_history_table, init_db

logger = logging.getLogger(__name__)


def get_recent_history(user_id: str, limit: int = 6) -> list[dict]:
    """Retrieve recent conversation history formatted for Groq/OpenAI in chronological order."""
    init_db()
    user_id = str(user_id).strip()

    with engine.begin() as conn:
        rows = conn.execute(
            select(chat_history_table.c.role, chat_history_table.c.content)
            .where(chat_history_table.c.user_id == user_id)
            .order_by(chat_history_table.c.id.desc())
            .limit(limit)
        ).fetchall()

        # Reverse to chronological order (oldest to newest)
        return [{"role": r[0], "content": r[1]} for r in reversed(rows)]


def save_chat_turn(user_id: str, role: str, content: str, tokens: int = 0) -> None:
    """Store an individual conversation turn in chat history."""
    init_db()
    user_id = str(user_id).strip()

    with engine.begin() as conn:
        conn.execute(
            chat_history_table.insert().values(
                user_id=user_id,
                role=role,
                content=content,
                tokens=tokens,
            )
        )
