"""User onboarding state machine and profile management."""

from __future__ import annotations

import logging
import re
from sqlalchemy import select, update, delete, or_
from app.database.db import engine
from app.database.schema import (
    users_table,
    daily_token_usage_table,
    chat_history_table,
    init_db,
)

logger = logging.getLogger(__name__)

NAME_CHANGE_PATTERNS = [
    r"\b(?:change|update|edit|correct|modify)\s+(?:my\s+)?name\b",
    r"\b(?:my\s+name\s+is\s+wrong|wrong\s+name|incorrect\s+name)\b",
]

LOCATION_CHANGE_PATTERNS = [
    r"\b(?:change|update|edit|correct|modify)\s+(?:my\s+)?(?:location|district|state|city|village|place|address)\b",
    r"\b(?:my\s+location\s+is\s+wrong|wrong\s+location|moved\s+to|shifted\s+to)\b",
]


def is_name_change_intent(text: str) -> bool:
    """Detect if the user is asking to update or correct their registered name."""
    t = text.lower().strip()
    return any(re.search(pat, t, re.IGNORECASE) for pat in NAME_CHANGE_PATTERNS)


def is_location_change_intent(text: str) -> bool:
    """Detect if the user is asking to update their farming location."""
    t = text.lower().strip()
    return any(re.search(pat, t, re.IGNORECASE) for pat in LOCATION_CHANGE_PATTERNS)


def get_or_create_user(user_id: str, phone_number: str | None = None) -> dict:
    """Look up a user by user_id (BSUID) or create/migrate a user profile.

    If user_id is not found, but phone_number is provided and matches an existing
    user_id or phone_number, migrate that user record to the new user_id (BSUID)
    without duplicating user records.
    """
    user_id = str(user_id).strip()
    phone = str(phone_number).strip() if phone_number else None

    try:
        with engine.begin() as conn:
            row = conn.execute(
                select(users_table).where(users_table.c.user_id == user_id)
            ).mappings().fetchone()

            if row:
                # Update phone_number if missing and provided
                if phone and not row.get("phone_number"):
                    conn.execute(
                        update(users_table)
                        .where(users_table.c.user_id == user_id)
                        .values(phone_number=phone)
                    )
                    return {**dict(row), "phone_number": phone}
                return dict(row)

            # Check if an existing user was registered by phone number previously
            if phone:
                existing_phone_user = conn.execute(
                    select(users_table).where(
                        or_(
                            users_table.c.user_id == phone,
                            users_table.c.phone_number == phone,
                        )
                    )
                ).mappings().fetchone()

                if existing_phone_user:
                    old_id = existing_phone_user["user_id"]
                    if old_id != user_id:
                        # Migrate existing user record to new BSUID
                        # 1. Insert new row with new user_id copying all attributes
                        conn.execute(
                            users_table.insert().values(
                                user_id=user_id,
                                phone_number=phone,
                                name=existing_phone_user.get("name"),
                                location=existing_phone_user.get("location"),
                                user_type=existing_phone_user.get("user_type", "Free"),
                                onboarding_step=existing_phone_user.get("onboarding_step", "ask_name"),
                                name_changes_count=existing_phone_user.get("name_changes_count", 0),
                            )
                        )
                        # 2. Update child table records to reference new BSUID
                        conn.execute(
                            update(daily_token_usage_table)
                            .where(daily_token_usage_table.c.user_id == old_id)
                            .values(user_id=user_id)
                        )
                        conn.execute(
                            update(chat_history_table)
                            .where(chat_history_table.c.user_id == old_id)
                            .values(user_id=user_id)
                        )
                        # 3. Delete old row safely
                        conn.execute(
                            delete(users_table).where(users_table.c.user_id == old_id)
                        )

                        migrated_row = conn.execute(
                            select(users_table).where(users_table.c.user_id == user_id)
                        ).mappings().fetchone()
                        if migrated_row:
                            return dict(migrated_row)

            # Create new user in onboarding state
            conn.execute(
                users_table.insert().values(
                    user_id=user_id,
                    phone_number=phone,
                    user_type="Free",
                    onboarding_step="ask_name",
                    name_changes_count=0,
                )
            )
            return {
                "user_id": user_id,
                "phone_number": phone,
                "name": None,
                "location": None,
                "user_type": "Free",
                "onboarding_step": "ask_name",
                "name_changes_count": 0,
                "is_new": True,
            }
    except Exception as exc:
        logger.warning(
            "Database connection failed in user_service for user %s: %s. Using in-memory fallback profile.",
            user_id,
            exc,
        )
        return {
            "user_id": user_id,
            "phone_number": phone,
            "name": None,
            "location": None,
            "user_type": "Free",
            "onboarding_step": "completed",
            "name_changes_count": 0,
        }


def handle_onboarding_turn(user: dict, message_text: str) -> str | None:
    """Process onboarding and profile modification turns. Returns prompt to reply, or None if completed."""
    step = user.get("onboarding_step")
    user_id = user["user_id"]
    text_clean = message_text.strip()

    if step == "ask_name":
        if user.get("is_new"):
            # Brand new user prompt asking for government name
            return (
                "Namaste! 🙏 Welcome to ASK KISAN, your AI agricultural assistant.\n\n"
                "To personalize your crop, weather, and government scheme advisories, "
                "please tell us your official full name (government name):"
            )

        # User is replying with their initial name
        try:
            with engine.begin() as conn:
                conn.execute(
                    update(users_table)
                    .where(users_table.c.user_id == user_id)
                    .values(name=text_clean, onboarding_step="ask_location")
                )
        except Exception as exc:
            logger.warning("Could not update user name in DB for %s: %s", user_id, exc)

        return (
            f"Thank you, {text_clean}! 🙏\n\n"
            "Now, please tell us your location (District and State) so we can provide "
            "accurate local crop, soil, and weather advisories for your area:"
        )

    if step == "ask_location":
        try:
            with engine.begin() as conn:
                conn.execute(
                    update(users_table)
                    .where(users_table.c.user_id == user_id)
                    .values(location=text_clean, onboarding_step="completed")
                )
        except Exception as exc:
            logger.warning("Could not update user location in DB for %s: %s", user_id, exc)

        user_name = user.get("name") or "Kisan Mitra"
        return (
            f"Welcome to ASK KISAN, {user_name}! 🌾\n\n"
            f"Your profile has been successfully set up for {text_clean}.\n\n"
            "How can I help you today? You can ask about crop cultivation, pest and disease remedies, "
            "fertilizers, irrigation, or government schemes like PM-KISAN!"
        )

    if step == "updating_name":
        # Save new name and record that the one-time name change has been used
        try:
            with engine.begin() as conn:
                conn.execute(
                    update(users_table)
                    .where(users_table.c.user_id == user_id)
                    .values(
                        name=text_clean,
                        name_changes_count=users_table.c.name_changes_count + 1,
                        onboarding_step="completed",
                    )
                )
        except Exception as exc:
            logger.warning("Could not execute name update in DB for %s: %s", user_id, exc)
        return (
            f"Thank you, {text_clean}! 🙏\n\n"
            "Your official name has been updated. Please note that further automated name changes "
            "cannot be performed for identity and scheme verification. If you ever need further corrections, "
            "please contact Ask Kisan Admin (support@askkisan.in)."
        )

    if step == "updating_location":
        try:
            with engine.begin() as conn:
                conn.execute(
                    update(users_table)
                    .where(users_table.c.user_id == user_id)
                    .values(location=text_clean, onboarding_step="completed")
                )
        except Exception as exc:
            logger.warning("Could not execute location update in DB for %s: %s", user_id, exc)
        return (
            f"Your location has been successfully updated to {text_clean}! 🌾\n\n"
            "All upcoming weather, sowing, and agricultural advisories will now be tailored to this region. "
            "How can I assist you with your farming today?"
        )

    if step == "completed":
        # Check if the user is asking to change their name
        if is_name_change_intent(message_text):
            name_changes = user.get("name_changes_count", 0)
            if name_changes >= 1:
                user_name = user.get("name") or "Kisan Mitra"
                return (
                    f"Namaste {user_name}. 🙏\n\n"
                    "Your name has already been updated once. For legal compliance and government scheme "
                    "verification, additional name modifications cannot be performed automatically.\n\n"
                    "Please contact Ask Kisan Admin (support@askkisan.in) for assistance."
                )

            # Initiate one-time name change
            try:
                with engine.begin() as conn:
                    conn.execute(
                        update(users_table)
                        .where(users_table.c.user_id == user_id)
                        .values(onboarding_step="updating_name")
                    )
            except Exception as exc:
                logger.warning("Could not initiate name update step in DB for %s: %s", user_id, exc)
            return (
                "You can update your name. Please note that **name changes can only be performed once**.\n\n"
                "Please enter your full name exactly as it appears on your **Aadhaar card or equivalent government-issued document**:"
            )

        # Check if the user is asking to change their location
        if is_location_change_intent(message_text):
            try:
                with engine.begin() as conn:
                    conn.execute(
                        update(users_table)
                        .where(users_table.c.user_id == user_id)
                        .values(onboarding_step="updating_location")
                    )
            except Exception as exc:
                logger.warning("Could not initiate location update step in DB for %s: %s", user_id, exc)
            return (
                "Sure! Please enter your new location (District and State) so we can provide accurate local crop, "
                "soil, and weather advisories for your area:"
            )

        # Normal query processing
        return None


def get_user_tier_history_limit(user_type: str = "Free") -> int:
    """Retrieve maximum history messages configured for a user tier."""
    from app.database.schema import user_tiers_table
    try:
        with engine.begin() as conn:
            row = conn.execute(
                select(user_tiers_table.c.max_history_messages).where(
                    user_tiers_table.c.user_type == user_type
                )
            ).scalar()
            return row or 6
    except Exception as exc:
        logger.warning(
            "Could not fetch user tier history limit for tier %s (%s). Using fallback 6.",
            user_type,
            exc,
        )
        return 6
