import json

from sqlalchemy import text
from openai import OpenAI

from app.database.db import engine
from app.config import OPENAI_API_KEY

client = OpenAI(api_key=OPENAI_API_KEY)

EMBEDDING_MODEL = "text-embedding-3-small"


def generate_embedding(text_to_embed):
    response = client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=text_to_embed
    )

    return response.data[0].embedding


def main():

    with engine.begin() as conn:

        # Fetch rows that don't yet have embeddings
        rows = conn.execute(
            text("""
                SELECT id, content
                FROM vector_embeddings
                WHERE vector IS NULL
                   OR JSON_LENGTH(vector) = 0
            """)
        ).fetchall()

        print(f"Found {len(rows)} rows to embed.")

        for row in rows:

            print(f"Embedding row {row.id}...")

            embedding = generate_embedding(row.content)

            conn.execute(
                text("""
                    UPDATE vector_embeddings
                    SET vector = :vector
                    WHERE id = :id
                """),
                {
                    "vector": json.dumps(embedding),
                    "id": row.id
                }
            )

        print("Done.")


if __name__ == "__main__":
    main() 
    