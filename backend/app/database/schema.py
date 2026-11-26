"""SQLAlchemy schema and initialization for user management, quotas, and chat memory."""

from __future__ import annotations

import logging

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

logger = logging.getLogger(__name__)

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

app_settings_table = Table(
    "app_settings",
    metadata,
    Column("key", String(64), primary_key=True),
    Column("value", String(255), nullable=False),
    Column("description", Text, nullable=True),
    Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now()),
)

DEFAULT_SETTINGS = [
    {
        "key": "enable_groq_fallback",
        "value": "true",
        "description": "Enable automatic fallback to Groq when Gemini rate limits or credits are exhausted",
    },
    {
        "key": "primary_llm_provider",
        "value": "gemini",
        "description": "Primary LLM provider to use for chat and advisories (gemini or groq)",
    },
]

_SETTINGS_CACHE: dict[str, tuple[str, float]] = {}
CACHE_TTL_SECONDS = 30.0


def get_app_setting(key: str, default: str | None = None, eng=None) -> str | None:
    """Retrieve setting value from app_settings with a 30s in-memory TTL cache."""
    import time
    now = time.time()
    if key in _SETTINGS_CACHE:
        val, expires_at = _SETTINGS_CACHE[key]
        if now < expires_at:
            return val

    target_engine = eng or engine
    try:
        with target_engine.connect() as conn:
            row = conn.execute(
                select(app_settings_table.c.value).where(app_settings_table.c.key == key)
            ).fetchone()
            if row is not None:
                val = str(row[0])
                _SETTINGS_CACHE[key] = (val, now + CACHE_TTL_SECONDS)
                return val
    except Exception:
        pass

    return default


def set_app_setting(key: str, value: str, description: str | None = None, eng=None) -> None:
    """Set or update setting in app_settings table and invalidate/update cache."""
    import time
    target_engine = eng or engine
    with target_engine.begin() as conn:
        existing = conn.execute(
            select(app_settings_table).where(app_settings_table.c.key == key)
        ).fetchone()
        if existing:
            conn.execute(
                app_settings_table.update()
                .where(app_settings_table.c.key == key)
                .values(value=value, updated_at=func.now())
            )
        else:
            conn.execute(
                app_settings_table.insert().values(
                    key=key, value=value, description=description
                )
            )
    _SETTINGS_CACHE[key] = (value, time.time() + CACHE_TTL_SECONDS)


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
    from sqlalchemy import inspect, text
    eng = target_engine or engine
    metadata.create_all(eng)

    # Ensure backwards compatibility for name_changes_count and phone_number on existing tables
    try:
        inspector = inspect(eng)
        if inspector.has_table("users"):
            existing_cols = {col["name"] for col in inspector.get_columns("users")}
            if "name_changes_count" not in existing_cols:
                with eng.begin() as conn:
                    conn.execute(text("ALTER TABLE users ADD COLUMN name_changes_count INTEGER DEFAULT 0"))
            if "phone_number" not in existing_cols:
                with eng.begin() as conn:
                    conn.execute(text("ALTER TABLE users ADD COLUMN phone_number VARCHAR(32)"))
    except Exception as exc:
        logger.warning("Could not verify/migrate users table columns: %s", exc)

    # Seed default tiers if not present
    with eng.begin() as conn:
        for tier in DEFAULT_TIERS:
            existing = conn.execute(
                select(user_tiers_table).where(user_tiers_table.c.user_type == tier["user_type"])
            ).fetchone()
            if not existing:
                conn.execute(user_tiers_table.insert().values(**tier))

    # Seed default settings if not present
    with eng.begin() as conn:
        for setting in DEFAULT_SETTINGS:
            existing = conn.execute(
                select(app_settings_table).where(app_settings_table.c.key == setting["key"])
            ).fetchone()
            if not existing:
                conn.execute(app_settings_table.insert().values(**setting))
