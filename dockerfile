FROM zaproxy/zap-stable:latest

# Set working directory
WORKDIR /zap

# Set the user
USER zap

# Define environment variables
ENV ZAP_PATH=/zap/zap.sh
ENV HOME=/home/zap/

# Install Node.js and Newman
USER root

# Install curl, Node.js, and Newman with error checking
RUN apt-get update -y && \
    apt-get install -y curl && \
    echo "Curl installed successfully" && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    echo "Node.js setup script executed" && \
    apt-get install -y nodejs && \
    echo "Node.js installed successfully" && \
    npm install -g newman && \
    echo "Newman installed successfully"

# Change permissions of all folders to rwx
RUN chmod -R 777 /zap && chmod -R 777 /home/zap

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode and run the Postman collection
CMD ["sh", "-c", "$ZAP_PATH -daemon -host 0.0.0.0 -port 8080 & newman run /zap/your_postman_collection.json"]
