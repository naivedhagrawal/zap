# syntax=docker/dockerfile:1
# This Dockerfile builds the ZAP stable release with Webswing support and includes zap-cli and newman

# Builder stage: Fetch dependencies and download ZAP stable release
FROM --platform=linux/amd64 debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -q -y --no-install-recommends --fix-missing \
    wget \
    curl \
    openjdk-17-jdk \
    xmlstarlet \
    unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /zap

# Download and extract the latest stable release of ZAP
RUN wget -qO- https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions.xml | \
    xmlstarlet sel -t -v //url | grep -i Linux | \
    wget --content-disposition -i - -O - | tar zxv && \
    mv ZAP*/* . && rm -R ZAP*

# Update add-ons
RUN ./zap.sh -cmd -silent -addonupdate

# Copy add-ons to installation directory
RUN cp /root/.ZAP/plugin/*.zap plugin/ || :

# Setup Webswing
ENV WEBSWING_VERSION=24.2.2
RUN --mount=type=secret,id=webswing_url \
    if [ -s /run/secrets/webswing_url ] ; \
    then curl -s -L "$(cat /run/secrets/webswing_url)-${WEBSWING_VERSION}-distribution.zip" > webswing.zip; \
    else curl -s -L "https://dev.webswing.org/files/public/webswing-examples-eval-${WEBSWING_VERSION}-distribution.zip" > webswing.zip; fi && \
    unzip webswing.zip && \
    rm webswing.zip && \
    mv webswing-* webswing && \
    rm -Rf webswing/apps/

# Final stage: Setup the final image with necessary tools
FROM debian:bookworm-slim AS final
LABEL maintainer="psiinon@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -q -y --no-install-recommends --fix-missing \
    make \
    automake \
    autoconf \
    gcc g++ \
    openjdk-17-jdk \
    wget \
    curl \
    xmlstarlet \
    unzip \
    git \
    openbox \
    xterm \
    net-tools \
    python3-pip \
    python-is-python3 \
    firefox-esr \
    xvfb \
    x11vnc \
    nodejs \
    npm && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies and zap-cli
RUN pip3 install --break-system-packages --no-cache-dir --upgrade \
    awscli \
    pip \
    zaproxy \
    pyyaml \
    urllib3 \
    zap-cli

# Install Newman (Postman CLI)
RUN npm install -g newman

# Create user for running ZAP
RUN useradd -u 1000 -d /home/zap -m -s /bin/bash zap && \
    echo zap:zap | chpasswd && \
    mkdir /zap && chown zap:zap /zap

WORKDIR /zap

# Create /zap/wrk directory for working files
RUN mkdir /zap/wrk

# Change to the zap user for proper permissions
USER zap

# Copy stable release and Webswing from the builder stage
COPY --from=builder --chown=1000:1000 /zap /zap
COPY --from=builder --chown=1000:1000 /zap/webswing /zap/webswing

# Set environment variables
ARG TARGETARCH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-$TARGETARCH
ENV PATH=$JAVA_HOME/bin:/zap/:$PATH
ENV ZAP_PATH=/zap/zap.sh
ENV ZAP_PORT=8080
ENV IS_CONTAINERIZED=true
ENV HOME=/home/zap/
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Copy configuration and script files
COPY --from=builder --chown=1000:1000 zap* CHANGELOG.md /zap/
COPY --from=builder --chown=1000:1000 webswing.config /zap/webswing/
COPY --from=builder --chown=1000:1000 webswing.properties /zap/webswing/
COPY --from=builder --chown=1000:1000 policies /home/zap/.ZAP/policies/
COPY --from=builder --chown=1000:1000 policies /root/.ZAP/policies/
COPY --from=builder --chown=1000:1000 scripts /home/zap/.ZAP_D/scripts/
COPY --from=builder --chown=1000:1000 .xinitrc /home/zap/
COPY --from=builder --chown=1000:1000 firefox /home/zap/.mozilla/firefox/

# Create container label
RUN echo "zap2docker-stable" > /zap/container && chmod a+x /home/zap/.xinitrc

# Health check to ensure ZAP is running
HEALTHCHECK CMD curl --silent --output /dev/null --fail http://localhost:$ZAP_PORT/ || exit 1
