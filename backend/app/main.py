import asyncio
import logging
from contextlib import asynccontextmanager
from uuid import uuid4

logger = logging.getLogger(__name__)

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.api.query import QueryRequest, QueryResponse
from app.api.whatsapp import router as whatsapp_router
from app.config import CORS_ORIGINS
from app.database.test_db import get_tables
from app.services.embedding_service import auto_sync_embeddings_worker, run_sync_pipeline
from app.services.query import answer_question


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle: background tasks startup and clean termination."""
    try:
        from app.database.schema import init_db
        init_db()
    except Exception as exc:
        logger.warning("Database init_db on startup encountered an issue: %s", exc)
    sync_task = asyncio.create_task(auto_sync_embeddings_worker())
    yield
    sync_task.cancel()
    try:
        await sync_task
    except asyncio.CancelledError:
        pass


app = FastAPI(
    title="ASK KISAN API",
    description="Backend API for the ASK KISAN chatbot",
    version="1.0.0",
    lifespan=lifespan,
)

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)


@app.get("/")
async def root():
    return {
        "message": "Welcome to ASK KISAN API",
        "status": "running"
    }


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "server": "online"
    }

app.include_router(whatsapp_router)


@app.get("/version")
async def version():
    return {
        "api": "ASK KISAN",
        "version": "1.0.0"
    }


@app.get("/tables")
def tables():
    return get_tables()


@app.post("/sync-embeddings")
@limiter.limit("5/minute")
async def sync_embeddings(request: Request):
    """Manually or webhook-triggered on-demand sync of database records to vector_embeddings."""
    try:
        results = run_sync_pipeline()
        return {
            "status": "success",
            **results
        }
    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Embedding synchronization failed: {error}"
        ) from error


@app.post("/query", response_model=QueryResponse)
@limiter.limit("10/minute")
async def query(request: Request, payload: QueryRequest) -> QueryResponse:
    """Answer an anonymous farmer question using retrieved source content."""
    try:
        target_user = payload.user_id
        if target_user:
            answer, sources = answer_question(payload.question, payload.language, user_id=target_user)
        else:
            answer, sources = answer_question(payload.question, payload.language)
    except Exception as error:
        logger.exception("Error processing /query request: %s", error)
        # Configuration and upstream/database failures must not leak to public clients.
        raise HTTPException(
            status_code=503,
            detail="Ask Kisan is temporarily unable to answer questions. Please try again shortly.",

            # detail=f"Ask Kisan error: {error}",
        ) from error

    return QueryResponse(
        answer=answer,
        sources=sources,
        session_id=payload.session_id or str(uuid4()),
    )
