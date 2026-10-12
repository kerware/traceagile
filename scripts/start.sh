#!/usr/bin/env sh
# Démarre TraceAgile (PostgreSQL, API, simulateur, front) avec le jeu de démonstration.
set -e
cd "$(dirname "$0")/.."
docker compose up --build -d
echo "TraceAgile : http://localhost:3000  (admin / demo)"
echo "API        : http://localhost:8085/swagger-ui.html"
