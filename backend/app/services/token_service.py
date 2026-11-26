"""Daily token rate limiting and tier quota enforcement."""

from __future__ import annotations

import logging
from sqlalchemy import func, select, text
from app.database.db import engine
from app.database.schema import daily_token_usage_table, user_tiers_table, init_db

logger = logging.getLogger(__name__)

DEFAULT_LIMITS = {
    "Free": 10000,
    "Pro": 50000,
    "Ultra": 200000,
    "FPOHead": 500000,
}


def check_daily_quota(user_id: str, user_type: str = "Free") -> tuple[bool, int, int]:
    """Check if user has remaining tokens for today. Returns (has_quota, tokens_used, daily_limit)."""
    user_id = str(user_id).strip()
    daily_limit = DEFAULT_LIMITS.get(user_type, 10000)

    try:
        with engine.begin() as conn:
            # 1. Fetch tier limit
            limit_val = conn.execute(
                select(user_tiers_table.c.daily_token_limit).where(
                    user_tiers_table.c.user_type == user_type
                )
            ).scalar()
            daily_limit = limit_val or daily_limit

            # 2. Fetch today's usage
            today_date = conn.execute(select(func.current_date())).scalar()
            usage_row = conn.execute(
                select(daily_token_usage_table.c.tokens_used).where(
                    (daily_token_usage_table.c.user_id == user_id) &
                    (daily_token_usage_table.c.usage_date == today_date)
                )
            ).scalar()

            tokens_used = usage_row or 0
            has_quota = tokens_used < daily_limit
            return has_quota, tokens_used, daily_limit
    except Exception as exc:
        logger.warning("Database error checking quota for user %s: %s. Allowing turn.", user_id, exc)
        return True, 0, daily_limit


def record_token_usage(user_id: str, tokens: int = 0) -> None:
    """Atomically record consumed tokens and increment request count for the user's current date."""
    if tokens < 0:
        return

    user_id = str(user_id).strip()

    try:
        with engine.begin() as conn:
            today_date = conn.execute(select(func.current_date())).scalar()
            existing = conn.execute(
                select(daily_token_usage_table.c.id, daily_token_usage_table.c.tokens_used, daily_token_usage_table.c.request_count)
                .where(
                    (daily_token_usage_table.c.user_id == user_id) &
                    (daily_token_usage_table.c.usage_date == today_date)
                )
            ).fetchone()

            if existing:
                conn.execute(
                    daily_token_usage_table.update()
                    .where(daily_token_usage_table.c.id == existing[0])
                    .values(
                        tokens_used=existing[1] + tokens,
                        request_count=existing[2] + 1,
                        updated_at=func.now(),
                    )
                )
            else:
                conn.execute(
                    daily_token_usage_table.insert().values(
                        user_id=user_id,
                        usage_date=today_date,
                        tokens_used=tokens,
                        request_count=1,
                    )
                )
    except Exception as exc:
        logger.warning("Database error recording token usage for user %s: %s", user_id, exc)


def get_quota_exceeded_message(user_name: str | None, user_type: str, daily_limit: int) -> str:
    """Generate a polite quota limit notification."""
    name_display = user_name or "Kisan Mitra"
    return (
        f"Namaste {name_display}. 🙏\n\n"
        f"You have reached your daily limit of {daily_limit:,} tokens on your {user_type} plan.\n\n"
        "Your quota will automatically reset tomorrow at midnight. "
        "Upgrade to Pro or Ultra for higher daily limits and extended conversation memory!"
    )
