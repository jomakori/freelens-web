#!/usr/bin/env bash
set -euo pipefail
set -x

_term() {
  echo "bye"
  exit 0
}

trap _term TERM INT

mkdir -p /root/.kube

echo "Starting Xvfb..."
(
  rm -f /tmp/.X0-lock || true
  exec Xvfb :0 -screen 0 1366x768x24 -ac -listen tcp
) &
echo $! >/tmp/xvfb.pid


echo "Starting x11vnc..."
(
  wait-for localhost:6000
  exec x11vnc -display :0 -shared -nopw -forever
) &
echo $! >/tmp/x11vnc.pid

echo "Starting websockify-js..."
(
  wait-for localhost:5900
  exec node /opt/websockify-js/websockify/websockify.js --web /app/public --websockify-path /websockify ":$PORT" 127.0.0.1:5900
) &
websockify_pid=$!

echo "Starting Freelens..."
(
  cd /opt/Freelens
  while true; do
    ls -a
    ./freelens --no-sandbox
  done
) &
echo $! >/tmp/lens.pid

echo "listening at port :$PORT"
wait
