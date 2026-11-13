#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-root@47.94.225.66}"
APP_DIR="${APP_DIR:-/opt/unified-mdm}"
SERVICE="${SERVICE:-unified-mdm}"
PORT="${PORT:-8050}"

cd "$(dirname "$0")"

SSH_OPTS=()
if [ -n "${SSH_PROXY:-}" ]; then
  SSH_OPTS+=(-o "ProxyCommand=nc -X connect -x ${SSH_PROXY} %h %p")
fi

tar czf - \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='local.db' \
  --exclude='test_fin.db' \
  app requirements.txt run.sh | \
ssh "${SSH_OPTS[@]}" "$HOST" "set -e
  mkdir -p '$APP_DIR'
  tar xzf - -C '$APP_DIR'
  systemctl restart '$SERVICE'
  sleep 4
  curl -fsS 'http://127.0.0.1:$PORT/health'
  echo
  systemctl is-active '$SERVICE'"

echo "财务中心已部署：http://47.94.225.66:8030/fin"
