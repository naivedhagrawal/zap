FROM owasp/zap2docker-stable

# Install zap-cli
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install zapcli

# Run zap in daemon mode
ENTRYPOINT ["zap.sh", "-daemon", "-host", "0.0.0.0", "-port", "8080"]
