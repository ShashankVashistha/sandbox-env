# Use Python base
FROM python:3.11-slim

# Install base packages and podman
RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    uidmap \
    slirp4netns \
    iptables \
    fuse-overlayfs \
    podman && \
    rm -rf /var/lib/apt/lists/*

# Install latest Docker CLI manually
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-25.0.2.tgz -o docker.tgz && \
    tar -xzf docker.tgz && \
    mv docker/docker /usr/bin/docker && \
    chmod +x /usr/bin/docker && \
    rm -rf docker docker.tgz

# Add a non-root user
RUN useradd -ms /bin/bash devuser

# Copy your entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory and switch to non-root
USER devuser
WORKDIR /workspace

# Default entrypoint
ENTRYPOINT ["/entrypoint.sh"]
