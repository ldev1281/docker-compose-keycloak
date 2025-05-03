FROM alpine:3.19

RUN apk add --no-cache socat proxychains

COPY --chmod=755 ./usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]