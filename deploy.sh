#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v docker >/dev/null || { echo "Docker not found"; exit 1; }
[ -f .env ] || { cp .env.example .env; echo "Created .env. Fill secrets and run again."; exit 2; }
docker compose pull db
docker compose up -d --build
docker compose ps
echo "Posterum-IT is listening on http://127.0.0.1:3000"
