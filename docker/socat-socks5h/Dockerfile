FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        socat \
        proxychains \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 usr/local/bin/entrypoint.bash /usr/local/bin/entrypoint.bash

ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
