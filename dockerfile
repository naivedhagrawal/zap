FROM zaproxy/zap-stable:latest

# Set working directory
WORKDIR /zap

# Set the user
USER zap

# Define environment variables
ENV ZAP_PATH=/zap/zap.sh
ENV HOME=/home/zap/

# Change permissions of all folders to rwx
USER root
RUN chmod -R 777 /zap && chmod -R 777 /home/zap

# Expose the ZAP port
EXPOSE 8080

# Entrypoint to start ZAP in daemon mode
CMD ["sh", "-c", "$ZAP_PATH -daemon -host 0.0.0.0 -port 8080"]
