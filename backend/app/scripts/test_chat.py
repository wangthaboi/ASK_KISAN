from openai import OpenAI
from app.config import OPENAI_API_KEY, EMBEDDING_MODEL

client = OpenAI(api_key=OPENAI_API_KEY)

LLM_MODEL = "gpt-4.1-mini"


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
    response = client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=query
    )

    return response.data[0].embedding


def ask_llm(query: str):

    response = client.chat.completions.create(
        model=LLM_MODEL,
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