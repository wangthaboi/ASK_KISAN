# ==========================================
# Stage 1: Build virtual environment
# ==========================================
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies required for compiling certain Python extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create isolated virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# ==========================================
# Stage 2: Minimal runtime image
# ==========================================
FROM python:3.12-slim AS runtime

# Install minimal runtime dependencies (curl for healthcheck, libpq5 for PostgreSQL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root system user and group for security
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -d /app appuser

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Configure environment
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app \
    PORT=8000

WORKDIR /app

# Copy application source code with non-root ownership
COPY --chown=appuser:appgroup app /app/app

# Run as non-privileged user
USER appuser

# Expose default application port
EXPOSE 8000

# Container healthcheck using FastAPI /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Start Uvicorn, dynamically binding to $PORT (fallback 8000)
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]

