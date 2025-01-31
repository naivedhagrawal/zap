FROM zaproxy/zap-stable

# Set zap user and group IDs
USER root

# Fix permissions for zap user
RUN mkdir -p /zap/wrk && \
    chown -R zap:zap /zap/wrk && \
    chmod -R 777 /zap/wrk

RUN touch /zap/wrk/data/zap-out.json \
    chmod 777 /zap/wrk/data/zap-out.json

# Switch back to zap user
USER zap

ENTRYPOINT ["/bin/bash"]
