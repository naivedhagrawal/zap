FROM zaproxy/zap-stable:latest

# Set working directory
WORKDIR /zap

# Set the user to root for installations
USER root

# Ensure ZAP user has correct permissions
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk

# Ensure ZAP user has correct permissions
RUN chown -R zap:zap /home/zap/ && \
    chmod -R 777 /home/zap/

# Install dependencies for Newman & Python
RUN apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs python3 python3-venv python3-pip && \
    npm install -g newman && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install zap-cli inside virtual environment
RUN python3 -m venv /zap-venv && \
    /zap-venv/bin/pip install --no-cache-dir zapcli

# Switch back to zap user
USER zap

# Define environment variables
ENV ZAP_PATH=/zap/zap.sh
ENV HOME=/home/zap/
ENV PATH="/zap-venv/bin:$PATH"

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode
CMD ["sh", "-c", "$ZAP_PATH -daemon -host 0.0.0.0 -port 8080"]
