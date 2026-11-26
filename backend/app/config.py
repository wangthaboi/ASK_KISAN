from pathlib import Path
from dotenv import load_dotenv
import os

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# OpenAI Configs (Vector Embeddings)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")
RAG_SIMILARITY_THRESHOLD = float(os.getenv("RAG_SIMILARITY_THRESHOLD", "0.45"))

# LLM Provider Configuration ("gemini" or "groq")
LLM_PROVIDER = os.getenv(
    "LLM_PROVIDER",
    "gemini" if os.getenv("GEMINI_API_KEY") else ("groq" if os.getenv("GROQ_API_KEY") else "gemini"),
).lower()

# Google Gemini Configs (Primary Chat Completions)
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
GEMINI_BASE_URL = os.getenv("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com/v1beta/openai/")

# GroqCloud Configs (Fallback / Secondary Chat Completions)
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_MODEL = os.getenv("GROQ_MODEL", os.getenv("CHAT_MODEL", "qwen/qwen3.8-27b"))
GROQ_BASE_URL = os.getenv("GROQ_BASE_URL", "https://api.groq.com/openai/v1")

# Fallback Flag (default fallback if Supabase DB is unreachable)
ENABLE_GROQ_FALLBACK = os.getenv("ENABLE_GROQ_FALLBACK", "true").lower() in ("true", "1", "yes")

# Active Chat Model
CHAT_MODEL = GEMINI_MODEL if LLM_PROVIDER == "gemini" else GROQ_MODEL

# WhatsApp API Configs
WHATSAPP_TOKEN = os.getenv("WHATSAPP_TOKEN")
WHATSAPP_PHONE_NUMBER_ID = os.getenv("WHATSAPP_PHONE_NUMBER_ID")
WHATSAPP_VERIFY_TOKEN = os.getenv("WHATSAPP_VERIFY_TOKEN")
WHATSAPP_APP_SECRET = os.getenv("WHATSAPP_APP_SECRET")

CORS_ORIGINS = [
	origin.strip()
	for origin in os.getenv(
		"CORS_ORIGINS",
		"http://localhost:5173,http://127.0.0.1:5173",
	).split(",")
	if origin.strip()
]


