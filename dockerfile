FROM zaproxy/zap-stable

# Set zap user and group IDs
USER root

# Fix permissions for zap user and give jenkins access
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk && \
    apt-get update && \
    apt-get install -y acl && \
    setfacl -m u:jenkins:rwx /zap/wrk  # Apply ACL permissions to jenkins

# Switch back to zap user
USER zap

ENTRYPOINT ["/bin/bash"]
