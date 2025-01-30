FROM zaproxy/zap-stable:latest

# Set working directory
WORKDIR /zap

# Set the user
USER root

# Ensure ZAP user has correct permissions
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk

# Switch back to zap user
USER zap

# Define environment variables
ENV ZAP_PATH=/zap/zap.sh
ENV HOME=/home/zap/

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode
CMD ["sh", "-c", "$ZAP_PATH -daemon -host 0.0.0.0 -port 8080"]
