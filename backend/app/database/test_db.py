from sqlalchemy import text
from app.database.db import engine


def get_tables():

    with engine.connect() as connection:

        result = connection.execute(
            text("SHOW TABLES")
        )

        tables = [row[0] for row in result]

    return tables