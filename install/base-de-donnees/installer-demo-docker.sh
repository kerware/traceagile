#!/bin/sh
# Démo SwagLabs pour TraceAgile en conteneur (docs/installation.md §4.3) : lancé par
# « docker compose run --rm installation-demo » ; base et compte lus dans .env (TRACEAGILE_DB_*).
set -eu
ADRESSE="${TRACEAGILE_DB_URL#jdbc:postgresql://}"
HOTE_PORT="${ADRESSE%%/*}"
BASE="${ADRESSE#*/}"
export PGHOST="${HOTE_PORT%%:*}" PGPORT=5432 PGDATABASE="${BASE%%\?*}"
case "$HOTE_PORT" in *:*) PGPORT="${HOTE_PORT##*:}" ;; esac
export PGUSER="$TRACEAGILE_DB_USER" PGPASSWORD="$TRACEAGILE_DB_PASSWORD"

for _ in $(seq 1 30); do pg_isready -q && break; sleep 2; done
TABLES=$(psql -tA -c "select count(*) from information_schema.tables where table_schema = 'public'")
if [ "$TABLES" != "0" ]; then
  echo "La base $PGDATABASE sur $PGHOST n'est pas vide ($TABLES tables) : la démo ne s'injecte que dans une base neuve." >&2
  exit 3
fi
echo "1/3 Injection de la démo SwagLabs dans $PGDATABASE sur $PGHOST:$PGPORT"
psql -q -v ON_ERROR_STOP=1 -f /base-de-donnees/demo/swaglabs.sql > /dev/null
echo "2/3 Serveur d'exécution de la démo : ${TRACEAGILE_DEMO_URL_SERVEUR:-adresse inchangée}, à appairer"
psql -q -v url_serveur="${TRACEAGILE_DEMO_URL_SERVEUR:-}" -f /base-de-donnees/apres-demo.sql
echo "3/3 Pièces jointes de la démo"
cp -R /base-de-donnees/demo/pieces-jointes/. /pieces-jointes/
rm -f /pieces-jointes/.gitkeep
chown -R 10001:10001 /pieces-jointes
echo "Démo SwagLabs installée : comptes admin, po, qa1, qa2, dev, viewer — mot de passe « SwagLabs-2026 » (à changer)."
