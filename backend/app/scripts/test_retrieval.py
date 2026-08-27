"""Run the representative ASK KISAN semantic-retrieval checks."""

from app.rag.retrieval import retrieve


QUERIES = [
    "How do I grow potato in Darjeeling?",
    "My potato leaves have dark spots. What should I do?",
    "When should I harvest French beans?",
    "My maize has caterpillars inside the whorl. What should I do?",
    "How should I manage waterlogging in turmeric?",
    "What is e-NAM?",
    "How do I register on e-NAM?",
    "What should I do if my tomato plants have dark lesions?",
    "What are the irrigation requirements for rice?",
    "What should I do if my cabbage has caterpillars?",
]


def main() -> None:
    for query in QUERIES:
        print(f"\nQuestion: {query}")
        for result in retrieve(query, limit=3):
            print(f"  {result.source_table}:{result.source_id}  score={result.score:.3f}")
            print(f"    {result.content[:260]}")


if __name__ == "__main__":
    main()
