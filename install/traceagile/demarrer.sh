#!/usr/bin/env bash
# Démarre TraceAgile (docs/installation.md §5) : lit traceagile.env à côté de ce script puis lance le jar.
set -euo pipefail
ICI="$(cd "$(dirname "$0")" && pwd)"
cd "$ICI"
[ -f traceagile.env ] || { echo "traceagile.env absent : copiez traceagile.env.exemple et adaptez-le" >&2; exit 1; }
set -a; . ./traceagile.env; set +a
# shellcheck disable=SC2086
exec java ${JAVA_OPTS:-} -jar "$ICI/traceagile-api.jar"
