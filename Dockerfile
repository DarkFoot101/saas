# Python version
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# Create virtual environment
RUN python -m venv /opt/venv

# Use virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Python environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip
RUN pip install --upgrade pip

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libjpeg-dev \
    libcairo2 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Application directory
WORKDIR /code

# Copy requirements first
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip install -r /tmp/requirements.txt

# Copy Django project
COPY ./src /code

# Django project name
ARG PROJ_NAME="cfehome"

# Create startup script
RUN printf '#!/bin/bash\n' > ./paracord_runner.sh && \
    printf 'RUN_PORT="${PORT:-8000}"\n\n' >> ./paracord_runner.sh && \
    printf 'python manage.py migrate --no-input\n' >> ./paracord_runner.sh && \
    printf 'gunicorn ${PROJ_NAME}.wsgi:application --bind "[::]:$RUN_PORT"\n' >> ./paracord_runner.sh

# Make script executable
RUN chmod +x paracord_runner.sh

# Container startup
CMD ["./paracord_runner.sh"]