FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        socat \
        proxychains \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
