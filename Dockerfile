# Use a multi-stage build to cache the llama2:7b image
ARG BASE_IMAGE=debian:bullseye-20240701-slim

FROM ${BASE_IMAGE} as builder

RUN apt-get update -y && apt-get install -y build-essential git curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install dependencies
# RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
#     | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
#     curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
#     | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
#     | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \

RUN apt-get update && \
    apt-get install -y curl

# Install ollama
RUN curl -sSL https://ollama.com/install.sh | bash

# Start the ollama service in the background and pull the llama-2:7b image to cache it
RUN bash -c "ollama serve > /dev/null 2>&1 & until curl -s http://localhost:11434 > /dev/null; do echo 'Waiting for ollama...'; sleep 1; done && ollama pull llama2:7b"

# Final stage: use the cached image
FROM ${BASE_IMAGE}

# Install dependencies
RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates curl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install ollama
RUN curl -sSL https://ollama.com/install.sh | bash

# Copy the cached image from the builder stage
COPY --from=builder /root/.ollama /root/.ollama

ADD server .
RUN chmod a+x server
# Start the ollama service in the background and run the ollama command
CMD ["./server"]