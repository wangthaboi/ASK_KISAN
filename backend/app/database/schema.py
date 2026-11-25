"""SQLAlchemy schema and initialization for user management, quotas, and chat memory."""

from __future__ import annotations

from sqlalchemy import (
    Column,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    MetaData,
    String,
    Table,
    Text,
    UniqueConstraint,
    func,
    select,
)
from app.database.db import engine

metadata = MetaData()

users_table = Table(
    "users",
    metadata,
    Column("user_id", String(128), primary_key=True),  # BSUID or Phone number
    Column("phone_number", String(32), nullable=True, index=True),
    Column("name", String(255), nullable=True),
    Column("location", String(255), nullable=True),
    Column("user_type", String(50), nullable=False, server_default="Free"),
    Column("onboarding_step", String(50), nullable=False, server_default="ask_name"),
    Column("name_changes_count", Integer, nullable=False, server_default="0"),
    Column("created_at", DateTime, server_default=func.now()),
    Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now()),
)

user_tiers_table = Table(
    "user_tiers",
    metadata,
    Column("user_type", String(50), primary_key=True),
    Column("daily_token_limit", Integer, nullable=False),
    Column("max_history_messages", Integer, nullable=False, server_default="6"),
    Column("description", Text, nullable=True),
)

daily_token_usage_table = Table(
    "daily_token_usage",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("user_id", String(128), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("usage_date", Date, nullable=False, server_default=func.current_date()),
    Column("tokens_used", Integer, nullable=False, server_default="0"),
    Column("request_count", Integer, nullable=False, server_default="0"),
    Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now()),
    UniqueConstraint("user_id", "usage_date", name="uq_user_daily_usage"),
)

chat_history_table = Table(
    "chat_history",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("user_id", String(128), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("role", String(20), nullable=False),
    Column("content", Text, nullable=False),
    Column("tokens", Integer, nullable=False, server_default="0"),
    Column("created_at", DateTime, server_default=func.now()),
)


DEFAULT_TIERS = [
    {
        "user_type": "Free",
        "daily_token_limit": 10000,
        "max_history_messages": 6,
        "description": "Free plan with 10,000 daily tokens and 3-turn memory (~6 messages)",
    },
    {
        "user_type": "Pro",
        "daily_token_limit": 50000,
        "max_history_messages": 10,
        "description": "Pro plan with 50,000 daily tokens and 5-turn memory (~10 messages)",
    },
    {
        "user_type": "Ultra",
        "daily_token_limit": 200000,
        "max_history_messages": 16,
        "description": "Ultra plan with 200,000 daily tokens and 8-turn memory (~16 messages)",
    },
    {
        "user_type": "FPOHead",
        "daily_token_limit": 500000,
        "max_history_messages": 20,
        "description": "FPO Lead plan with 500,000 daily tokens and 10-turn memory (~20 messages)",
    },
]


def init_db(target_engine=None):
    """Ensure tables exist and seed initial tier limits."""
    from sqlalchemy import text
    eng = target_engine or engine
    metadata.create_all(eng)

    # Ensure backwards compatibility for name_changes_count and phone_number on existing tables
    with eng.begin() as conn:
        try:
            conn.execute(text("ALTER TABLE users ADD COLUMN name_changes_count INTEGER DEFAULT 0"))
        except Exception:
            pass  # Already exists or dialect handled by create_all

        try:
            conn.execute(text("ALTER TABLE users ADD COLUMN phone_number VARCHAR(32)"))
        except Exception:
            pass

    # Seed default tiers if not present
    with eng.begin() as conn:
        for tier in DEFAULT_TIERS:
            existing = conn.execute(
                select(user_tiers_table).where(user_tiers_table.c.user_type == tier["user_type"])
            ).fetchone()
            if not existing:
                conn.execute(user_tiers_table.insert().values(**tier))
