# Use the official OWASP ZAP Docker image
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
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    npm install -g newman

# Change permissions of all folders to rwx
RUN chmod -R 777 /zap && chmod -R 777 /home/zap

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode and run the Postman collection
CMD ["sh", "-c", "$ZAP_PATH -daemon -host 0.0.0.0 -port 8080 & newman run /zap/your_postman_collection.json"]
