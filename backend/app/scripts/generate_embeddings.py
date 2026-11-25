"""
CLI tool for manual or deployment-triggered vector embeddings synchronization.
Reuses the shared embedding_service to avoid duplicate code.
"""

import logging
from app.services.embedding_service import run_sync_pipeline

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


def main():
    logger.info("Starting manual embedding sync...")
    results = run_sync_pipeline()
    logger.info(f"Sync complete! Synced: {results['synced_records']} records, Generated: {results['generated_vectors']} vectors.")


if __name__ == "__main__":
    main()
