from sqlalchemy import create_engine
from app.config import DATABASE_URL, DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER


def get_database_url() -> str:
    """Build or normalize the database connection URL."""
    if DATABASE_URL:
        url = DATABASE_URL
        # Normalize postgresql schemes for SQLAlchemy + psycopg2
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+psycopg2://", 1)
        elif url.startswith("postgresql://") and not url.startswith("postgresql+"):
            url = url.replace("postgresql://", "postgresql+psycopg2://", 1)
        return url

    if DB_HOST and DB_USER:
        port = int(DB_PORT) if DB_PORT else 3306
        return (
            f"mysql+pymysql://{DB_USER}:{DB_PASSWORD or ''}"
            f"@{DB_HOST}:{port}/{DB_NAME or ''}"
        )

    # Fallback in-memory database for testing and offline development
    return "sqlite:///:memory:"


resolved_url = get_database_url()

engine = create_engine(
    resolved_url,
    pool_pre_ping=True,
    echo=False,
)