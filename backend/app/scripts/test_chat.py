from openai import OpenAI
from app.config import (
    OPENAI_API_KEY,
    EMBEDDING_MODEL,
    GROQ_API_KEY,
    GROQ_BASE_URL,
    GROQ_MODEL,
)

embedding_client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None
groq_client = (
    OpenAI(api_key=GROQ_API_KEY, base_url=GROQ_BASE_URL)
    if GROQ_API_KEY
    else None
)


SYSTEM_PROMPT = """
You are ASK KISAN, an AI assistant for Indian farmers.

Your responsibilities include:
- Government agricultural schemes
- Crop cultivation
- Pest and disease management
- Fertilizers and nutrients
- Irrigation
- Weather-related farming advice
- Agricultural best practices

For now, answer the user's question normally.
Later you will receive retrieved context from a vector database.

If you don't know something, say so instead of making it up.
"""


def embed_query(query: str):
    if not embedding_client:
        raise RuntimeError("OPENAI_API_KEY is not configured for embeddings.")
    response = embedding_client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=query
    )

    return response.data[0].embedding


def ask_llm(query: str):
    if not groq_client:
        raise RuntimeError("GROQ_API_KEY is not configured for chat completions.")

    response = groq_client.chat.completions.create(
        model=GROQ_MODEL,
        messages=[
            {
                "role": "system",
                "content": SYSTEM_PROMPT
            },
            {
                "role": "user",
                "content": query
            }
        ],
        temperature=0.2
    )

    return response.choices[0].message.content


def main():

    while True:

        query = input("\nYou: ")

        if query.lower() in ["exit", "quit"]:
            break

        embedding = embed_query(query)

        print(f"\nEmbedding generated ({len(embedding)} dimensions)")

        answer = ask_llm(query)

        print("\nASK KISAN:")
        print(answer)


if __name__ == "__main__":
    main()