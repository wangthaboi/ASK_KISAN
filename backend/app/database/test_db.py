from sqlalchemy import inspect
from app.database.db import engine


def get_tables():
    """Return all table names across any supported database engine."""
    inspector = inspect(engine)
    return inspector.get_table_names()