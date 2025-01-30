# Use the official OWASP ZAP Docker image
FROM zaproxy/zap-stable:latest

# Install Node.js and Newman
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    npm install -g newman

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode and run the Postman collection
CMD ["sh", "-c", "zap.sh -daemon -host 0.0.0.0 -port 8080 & newman run /zap/your_postman_collection.json"]