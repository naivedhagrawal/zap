FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y wget unzip openjdk-11-jre-headless xvfb libxtst6 libxrender1 libxi6 tar

WORKDIR /opt

ARG ZAP_VERSION=2.16.0
ARG ZAP_FILE=ZAP_${ZAP_VERSION}_Linux.tar.gz  # Changed to tar.gz

RUN wget "https://github.com/zaproxy/zaproxy/releases/download/v${ZAP_VERSION}/${ZAP_FILE}" && \
    tar -xzf ${ZAP_FILE} && \  # Use tar to extract
    rm ${ZAP_FILE}

RUN useradd -ms /bin/bash zapuser
RUN Xvfb :1 -screen 0 1024x768x24 &
ENV DISPLAY=:1
USER zapuser
EXPOSE 8080

# Correct the path to zap.sh
CMD ["/opt/zaproxy-${ZAP_VERSION}/zap.sh", "-daemon", "-port", "8080", "-config", "api.key=","-gui"]