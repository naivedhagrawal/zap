FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip openjdk-11-jre-headless xvfb libxtst6 libxrender1 libxi6

# Download and install OWASP ZAP
WORKDIR /opt

RUN wget https://github.com/zaproxy/zaproxy/releases/download/v2.13.0/ZAP_2.13.0_Linux.zip && \
    unzip ZAP_2.13.0_Linux.zip && \
    rm ZAP_2.13.0_Linux.zip

# Create a user for ZAP (recommended for security)
RUN useradd -ms /bin/bash zapuser

# Set up Xvfb (for headless GUI)
CMD Xvfb :1 -screen 0 1024x768x24 & \
    /opt/zaproxy-2.13.0/zap.sh -daemon -port 8080 -config api.key= -gui

# Set DISPLAY environment variable
ENV DISPLAY=:1

# Switch to the zapuser
USER zapuser

# Expose the ZAP API port (adjust as needed)
EXPOSE 8080

# Run ZAP with the GUI (using Xvfb)
CMD ["/opt/zaproxy-2.13.0/zap.sh", "-daemon", "-port", "8080", "-config", "api.key=","-gui"] # Replace with the correct path if you changed the version. Adding api key as blank for now. You can add your api key here.

# Alternatively, if you want to run ZAP headlessly (without GUI), comment out the GUI line and uncomment the following:
#CMD ["/opt/zaproxy-2.13.0/zap.sh", "-daemon", "-port", "8080", "-config", "api.key="]