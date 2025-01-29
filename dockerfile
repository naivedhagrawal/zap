FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    xvfb \
    x11-xserver-utils \
    xdg-utils \
    libxtst6 \
    libxi6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/zap

# Download and install OWASP ZAP
RUN wget https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2_14_0_unix.sh -O zap.sh \
    && chmod +x zap.sh \
    && ./zap.sh -q -dir /opt/zap

# Expose ZAP GUI using X11
ENV DISPLAY=:0

# Entry point
CMD ["bash", "-c", "/opt/zap/ZAP_2.14.0/zap.sh"]
