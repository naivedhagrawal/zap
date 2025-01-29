FROM python:3.9-slim

# Install OWASP ZAP
RUN apt-get update && apt-get install -y zaproxy && \
    python3 -m pip install --no-cache-dir zapcli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["zap.sh", "-daemon", "-host", "0.0.0.0", "-port", "8080"]
