FROM python:3.9

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget openjdk-11-jre unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/zap

# Download OWASP ZAP
RUN wget -q https://github.com/zaproxy/zaproxy/releases/latest/download/ZAP_2_13_0_Linux.tar.gz -O zap.tar.gz && \
    tar -xzf zap.tar.gz --strip-components=1 && \
    rm zap.tar.gz

# Install zapcli
RUN pip install --no-cache-dir zapcli

# Expose ZAP default port
EXPOSE 8080

# Set default entrypoint
ENTRYPOINT ["./zap.sh", "-daemon", "-host", "0.0.0.0", "-port", "8080"]
