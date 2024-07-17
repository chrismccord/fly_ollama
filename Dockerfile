# Use a multi-stage build to cache the llama2:7b image
FROM ubuntu:20.04 as builder

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl

# Install ollama
RUN curl -sSL https://ollama.com/install.sh | bash

# Start the ollama service in the background and pull the llama-2:7b image to cache it
RUN bash -c "ollama serve > /dev/null 2>&1 & until curl -s http://localhost:11434 > /dev/null; do echo 'Waiting for ollama...'; sleep 1; done && ollama pull llama2:7b"

# Final stage: use the cached image
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl

# Install ollama
RUN curl -sSL https://ollama.com/install.sh | bash

# Copy the cached image from the builder stage
COPY --from=builder /root/.ollama /root/.ollama

ADD server .
RUN chmod a+x server
# Start the ollama service in the background and run the ollama command
CMD ["./server"]