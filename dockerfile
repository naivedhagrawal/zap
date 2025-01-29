FROM zaproxy/zap-stable

# Ensure package list is updated and install Python3 + pip
RUN apt-get update && apt-get install -y python3 python3-pip --no-install-recommends && \
    python3 -m pip install --no-cache-dir zapcli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["zap.sh", "-daemon", "-host", "0.0.0.0", "-port", "8080"]
