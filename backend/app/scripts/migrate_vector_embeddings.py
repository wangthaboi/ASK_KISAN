"""Apply the additive metadata migration for the derived embedding search layer."""

from sqlalchemy import text

from app.database.db import engine


COLUMNS = {
    "content_hash": "CHAR(64) NULL AFTER content",
    "embedding_model": "VARCHAR(100) NULL AFTER vector",
    "updated_at": "TIMESTAMP NULL DEFAULT NULL AFTER created_at",
}


def main() -> None:
    with engine.begin() as conn:
        existing = set(conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = 'vector_embeddings'
        """)).scalars())
        for name, definition in COLUMNS.items():
            if name in existing:
                print(f"already present: {name}")
                continue
            conn.execute(text(f"ALTER TABLE vector_embeddings ADD COLUMN {name} {definition}"))
            print(f"added: {name}")


if __name__ == "__main__":
    main()
