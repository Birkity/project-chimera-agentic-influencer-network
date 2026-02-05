# Project Chimera - Production Docker Environment
# Multi-stage build for optimized container size and security

# Stage 1: Build Environment with uv package manager
FROM python:3.11-slim as builder

# Install system dependencies required for building Python packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv - fast Python package manager
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files for optimized layer caching
COPY pyproject.toml uv.lock ./

# Create virtual environment and install dependencies
RUN uv venv /opt/venv
RUN /opt/venv/bin/python -m pip install --upgrade pip
RUN uv pip install --system -r pyproject.toml

# Stage 2: Runtime Environment (minimal)
FROM python:3.11-slim as runtime

# Set environment variables for production
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app \
    PATH="/opt/venv/bin:$PATH" \
    ENVIRONMENT=production \
    POSTGRES_DB=chimera \
    REDIS_URL=redis://redis:6379/0 \
    WEAVIATE_URL=http://weaviate:8080

# Install only runtime system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN groupadd -g 1000 chimera && \
    useradd -r -u 1000 -g chimera -d /app -s /bin/bash chimera

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Set working directory and change ownership
WORKDIR /app
RUN chown -R chimera:chimera /app

# Copy application code
COPY --chown=chimera:chimera . .

# Ensure skills and chimera modules are properly structured
RUN mkdir -p /app/chimera /app/skills /app/tests /app/data /app/logs
RUN chown -R chimera:chimera /app

# Switch to non-root user
USER chimera

# Expose port for FastAPI application
EXPOSE 8000

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command - can be overridden
CMD ["uvicorn", "chimera.main:app", "--host", "0.0.0.0", "--port", "8000"]

# Metadata labels
LABEL org.opencontainers.image.title="Project Chimera - Autonomous AI Influencer Network"
LABEL org.opencontainers.image.description="FastRender Swarm Pattern implementation with MCP integration"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.vendor="Chimera AI Team"
LABEL org.opencontainers.image.licenses="MIT"

# Volume mounts for persistent data
VOLUME ["/app/data", "/app/logs"]