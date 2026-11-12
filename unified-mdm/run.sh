#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
set -a
[ -f .env ] && source .env
set +a
exec .venv/bin/uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8050}" --workers 1
