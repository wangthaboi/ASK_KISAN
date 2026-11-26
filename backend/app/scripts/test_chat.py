from openai import OpenAI
from app.config import (
    OPENAI_API_KEY,
    EMBEDDING_MODEL,
    LLM_PROVIDER,
    GEMINI_API_KEY,
    GROQ_API_KEY,
)
from app.services.query import execute_chat_completion

embedding_client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None


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
    if LLM_PROVIDER == "gemini" and not GEMINI_API_KEY and not GROQ_API_KEY:
        raise RuntimeError("GEMINI_API_KEY is not configured for chat completions.")
    if LLM_PROVIDER == "groq" and not GROQ_API_KEY:
        raise RuntimeError("GROQ_API_KEY is not configured for chat completions.")

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": query},
    ]
    answer, _, _ = execute_chat_completion(messages, temperature=0.2)
    return answer


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