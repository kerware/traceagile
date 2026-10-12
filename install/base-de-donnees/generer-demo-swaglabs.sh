#!/usr/bin/env bash
# Mainteneurs : régénère le jeu de démonstration SwagLabs distribuable (demo/swaglabs.sql et
# demo/pieces-jointes/) à partir d'une instance de TraceAgile neuve, installée comme hors Docker
# (jar distribuable, sans profil demo, administrateur créé au premier démarrage).
#
# Prérequis :
#   - la pile Docker démarrée (PostgreSQL sur localhost:5433, serveur d'exécution sur localhost:8091) ;
#   - le jar distribuable construit : cd backend && mvn -pl traceagile-api -am package -Pdistribution -DskipTests ;
#   - saucedemo/ installé (npm ci) et la branche courante committée (le serveur d'exécution la clone).
#
# Étapes : base temporaire → TraceAgile sur :8086 → tests réels de saucedemo (rapport JUnit) → scénario du
# guide sans captures (données du projet SWAG, runs réellement exécutés) → pg_dump → nettoyage.
set -euo pipefail

ICI="$(cd "$(dirname "$0")" && pwd)"
RACINE="$(cd "$ICI/../.." && pwd)"
JAR="$RACINE/backend/traceagile-api/target/traceagile-api.jar"
CONTENEUR="${CONTENEUR_POSTGRES:-traceagile-postgres-1}"
BASE=traceagile_swaglabs
ROLE=traceagile_demo
MOT_DE_PASSE_DEMO="${MOT_DE_PASSE_DEMO:-SwagLabs-2026}"
PORT=8086
TRAVAIL="$(mktemp -d)"
PIECES="$TRAVAIL/pieces-jointes"
psql_docker() { docker exec -i "$CONTENEUR" psql -U traceagile "$@"; }

[ -f "$JAR" ] || { echo "Jar distribuable absent : $JAR (mvn ... -Pdistribution)" >&2; exit 1; }
unzip -l "$JAR" | grep "BOOT-INF/classes/static/index.html" > /dev/null || { echo "Le jar n'embarque pas l'interface (profil distribution)" >&2; exit 1; }

echo "1/6 Base temporaire $BASE"
PSQL="docker exec -i $CONTENEUR psql" "$ICI/installer-base.sh" --hote localhost --port 5432 --superutilisateur traceagile \
  --base "$BASE" --utilisateur "$ROLE" --mot-de-passe "$MOT_DE_PASSE_DEMO" --remplacer

echo "2/6 TraceAgile (jar distribuable) sur :$PORT"
TRACEAGILE_DB_URL="jdbc:postgresql://localhost:5433/$BASE" TRACEAGILE_DB_USER="$ROLE" TRACEAGILE_DB_PASSWORD="$MOT_DE_PASSE_DEMO" \
TRACEAGILE_ADMIN_PASSWORD="$MOT_DE_PASSE_DEMO" TRACEAGILE_ATTACHMENTS_DIR="$PIECES" \
TRACEAGILE_CALLBACK_URL="http://host.docker.internal:$PORT/api/v1/execution-callbacks" \
  java -jar "$JAR" --server.port=$PORT > "$TRAVAIL/traceagile.log" 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null || true' EXIT
for _ in $(seq 1 90); do
  curl -fs "http://localhost:$PORT/actuator/health" 2>/dev/null | grep UP > /dev/null && break
  sleep 2
done
curl -fs "http://localhost:$PORT/actuator/health" 2>/dev/null | grep UP > /dev/null || { tail -40 "$TRAVAIL/traceagile.log"; exit 1; }

echo "3/6 Tests réels de saucedemo (rapport JUnit importé par le scénario)"
cd "$RACINE/saucedemo"
[ -f results/junit-saucedemo.xml ] || npx playwright test > "$TRAVAIL/app-tests.log" 2>&1 || true

echo "4/6 Scénario du guide sans captures : projet SWAG, deux sprints, runs exécutés par le serveur d'exécution"
TRACEAGILE_URL="http://localhost:$PORT" GUIDE_PROJET=SWAG GUIDE_MOT_DE_PASSE="$MOT_DE_PASSE_DEMO" GUIDE_SANS_CAPTURES=1 \
GUIDE_EXECUTEUR_URL_DEPUIS_TRACEAGILE="${GUIDE_EXECUTEUR_URL_DEPUIS_TRACEAGILE:-http://localhost:8091}" \
  npx playwright test -c guide.config.ts --reporter=line
kill $PID
wait $PID 2>/dev/null || true
trap - EXIT

echo "5/6 Export : demo/swaglabs.sql et demo/pieces-jointes/"
# ni jeton du serveur d'exécution ni session ouverte dans l'export
docker exec -i "$CONTENEUR" psql -U traceagile -d "$BASE" -q -v url_serveur= < "$ICI/apres-demo.sql" > /dev/null
{
  echo "-- Jeu de démonstration SwagLabs de TraceAgile (docs/installation.md) : schéma, migrations Flyway,"
  echo "-- référentiels, comptes (admin, po, qa1, qa2, dev, viewer ; mot de passe $MOT_DE_PASSE_DEMO) et projet SWAG."
  echo "-- Généré le $(date -u +%Y-%m-%d) par install/base-de-donnees/generer-demo-swaglabs.sh — PostgreSQL 16 ou plus."
  # \restrict (pg_dump 16.10+) est inconnu des psql plus anciens : l'export vient d'ici, on le retire
  docker exec "$CONTENEUR" pg_dump -U traceagile -d "$BASE" --no-owner --no-privileges --quote-all-identifiers \
    --exclude-table-data=public.refresh_tokens | grep -Ev '^[\](un)?restrict '
} > "$ICI/demo/swaglabs.sql"
rm -rf "$ICI/demo/pieces-jointes"
mkdir -p "$ICI/demo/pieces-jointes"
[ -d "$PIECES" ] && cp -R "$PIECES/." "$ICI/demo/pieces-jointes/"
touch "$ICI/demo/pieces-jointes/.gitkeep"

echo "6/6 Nettoyage de la base temporaire"
psql_docker -d postgres -q -c "DROP DATABASE IF EXISTS $BASE WITH (FORCE)" -c "DROP ROLE IF EXISTS $ROLE"
rm -rf "$TRAVAIL"
echo "Démo régénérée : $(wc -c < "$ICI/demo/swaglabs.sql") octets, $(find "$ICI/demo/pieces-jointes" -type f ! -name .gitkeep | wc -l) pièce(s) jointe(s)."
