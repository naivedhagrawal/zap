FROM zaproxy/zap-stable

# Set zap user and group IDs
USER root

# Fix permissions for zap user and give jenkins access
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk && \
    echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y acl && \
    setfacl -m u:jenkins:rwx /zap/wrk  # Use ACL without -d flag

# Switch back to zap user
USER zap

ENTRYPOINT ["/bin/bash"]
