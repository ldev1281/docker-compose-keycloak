#!/usr/bin/env sh
set -e

# Required
: "${SOURCE_PORT:?Missing SOURCE_PORT}"
: "${TARGET_HOST:?Missing TARGET_HOST}"
: "${TARGET_PORT:?Missing TARGET_PORT}"

if [ -n "${SOCKS5H_HOST:-}" ]; then
  : "${SOCKS5H_PORT:=1080}"

  echo "[INFO] Starting socat via proxychains (socks5h)"
  echo "[INFO] SOCKS5 proxy (with DNS): $SOCKS5H_HOST:$SOCKS5H_PORT"
  echo "[INFO] Target:       $TARGET_HOST:$TARGET_PORT"
  echo "[INFO] Listening on: 0.0.0.0:$SOURCE_PORT"
  {
    echo "strict_chain"
    echo "proxy_dns"
    echo "tcp_read_time_out 15000"
    echo "tcp_connect_time_out 8000"
    echo "[ProxyList]"
    echo "socks5  ${SOCKS5H_HOST} ${SOCKS5H_PORT}"
  } > /etc/proxychains.conf

  exec proxychains socat TCP-LISTEN:$SOURCE_PORT,fork,reuseaddr TCP:$TARGET_HOST:$TARGET_PORT

else
  echo "[INFO] Starting socat directly (no proxy)..."
  echo "[INFO] Target:       $TARGET_HOST:$TARGET_PORT"
  echo "[INFO] Listening on: 0.0.0.0:$SOURCE_PORT"

  exec socat TCP-LISTEN:$SOURCE_PORT,fork,reuseaddr TCP:$TARGET_HOST:$TARGET_PORT
fi
