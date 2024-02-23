# Base stage for shared environment setup, including Python, R, and wandb
FROM python:3.8-slim-buster as base

# Install R base
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    && rm -rf /var/lib/apt/lists/*

# Install wandb globally for both development and running stages
RUN pip install --upgrade pip && \
    pip install wandb

# Argument for wandb API token, allowing it to be passed at build time
ARG WANDB_API_KEY
# Set the wandb API token as an environment variable for the application to use
ENV WANDB_API_KEY=$WANDB_API_KEY

WORKDIR /app

# Development stage for setting up a development environment with Poetry
FROM base as development
# Install Poetry
RUN pip install poetry
COPY . /app
RUN poetry install

# Running stage for setting up the production environment
FROM base as running
COPY requirements.txt /app/
RUN pip install -r requirements.txt
# Install scGPT with specific dependencies, ensuring compatibility
RUN pip install scgpt "flash-attn<1.0.5" "orbax<0.1.8"

# Set the default command for the running stage
CMD ["python", "<your-script-here>.py"]
