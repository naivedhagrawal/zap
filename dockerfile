FROM zaproxy/zap-stable

# Set zap user and group IDs
USER root

# Fix permissions for zap user
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk

RUN apt-get update && apt-get install -y acl && \
    setfacl -d -m u:jenkins:rwx /zap/wrk

# Switch back to zap user
USER zap

ENTRYPOINT ["/bin/bash"]
