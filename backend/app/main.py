from uuid import uuid4

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.api.query import QueryRequest, QueryResponse
from app.config import CORS_ORIGINS
from app.database.test_db import get_tables
from app.services.query import answer_question

app = FastAPI(
    title="ASK KISAN API",
    description="Backend API for the ASK KISAN chatbot",
    version="1.0.0"
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


@app.get("/version")
async def version():
    return {
        "api": "ASK KISAN",
        "version": "1.0.0"
    }

    from app.database.test_db import get_tables

@app.get("/tables")
def tables():

    return get_tables()


@app.post("/query", response_model=QueryResponse)
@limiter.limit("10/minute")
async def query(request: Request, payload: QueryRequest) -> QueryResponse:
    """Answer an anonymous farmer question using retrieved source content."""
    try:
        answer, sources = answer_question(payload.question, payload.language)
    except Exception as error:
        # Configuration and upstream/database failures must not leak to public clients.
        raise HTTPException(
            status_code=503,
            detail="Ask Kisan is temporarily unable to answer questions. Please try again shortly.",
        ) from error

    return QueryResponse(
        answer=answer,
        sources=sources,
        session_id=payload.session_id or str(uuid4()),
    )
