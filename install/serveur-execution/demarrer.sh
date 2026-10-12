#!/usr/bin/env bash
# Démarre le serveur d’exécution (docs/installation.md §7) : lit serveur-execution.env à côté de ce script puis lance le jar.
set -euo pipefail
ICI="$(cd "$(dirname "$0")" && pwd)"
cd "$ICI"
[ -f serveur-execution.env ] || { echo "serveur-execution.env absent : copiez serveur-execution.env.exemple et adaptez-le" >&2; exit 1; }
set -a; . ./serveur-execution.env; set +a
# shellcheck disable=SC2086
exec java ${JAVA_OPTS:-} -jar "$ICI/execution-server.jar"
