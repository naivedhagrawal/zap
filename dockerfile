FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre \
    wget \
    xvfb \
    x11-utils \
    libxtst6 \
    libxi6 \
    libxrender1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/zap

# Download and install OWASP ZAP
RUN wget -q https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2_14_0_unix.sh -O zap.sh \
    && chmod +x zap.sh \
    && ./zap.sh -q -dir /opt/zap \
    && rm zap.sh  # Remove installer to save space

# Expose ZAP GUI using X11
ENV DISPLAY=:0

# Entry point
CMD ["/opt/zap/ZAP_2.14.0/zap.sh"]
