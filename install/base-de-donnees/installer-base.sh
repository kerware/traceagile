#!/usr/bin/env bash
# Installation hors Docker (docs/installation.md) : crée le rôle et la base PostgreSQL de TraceAgile et,
# avec --demo, injecte le jeu de démonstration SwagLabs (projet SWAG, comptes de démonstration).
#
#   ./installer-base.sh --mot-de-passe 'secret' [--hote localhost] [--port 5432] [--superutilisateur postgres]
#                       [--base traceagile] [--utilisateur traceagile] [--demo] [--remplacer]
#                       [--url-serveur http://machine-de-test:8091] [--pieces-jointes /var/lib/traceagile/pieces-jointes]
#
# Le mot de passe du superutilisateur est demandé par psql (ou lu dans PGPASSWORD / ~/.pgpass).
# PSQL remplace la commande psql, par exemple : PSQL="docker exec -i traceagile-postgres-1 psql".
set -euo pipefail

ICI="$(cd "$(dirname "$0")" && pwd)"
PSQL="${PSQL:-psql}"
HOTE=localhost PORT=5432 SUPER=postgres BASE=traceagile UTILISATEUR=traceagile MOT_DE_PASSE=""
DEMO=non REMPLACER=non URL_SERVEUR="" PIECES_JOINTES=""

while [ $# -gt 0 ]; do
  case "$1" in
    --hote) HOTE="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --superutilisateur) SUPER="$2"; shift 2 ;;
    --base) BASE="$2"; shift 2 ;;
    --utilisateur) UTILISATEUR="$2"; shift 2 ;;
    --mot-de-passe) MOT_DE_PASSE="$2"; shift 2 ;;
    --demo) DEMO=oui; shift ;;
    --remplacer) REMPLACER=oui; shift ;;
    --url-serveur) URL_SERVEUR="$2"; shift 2 ;;
    --pieces-jointes) PIECES_JOINTES="$2"; shift 2 ;;
    -h|--aide) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Option inconnue : $1" >&2; exit 2 ;;
  esac
done
[ -n "$MOT_DE_PASSE" ] || { echo "--mot-de-passe est obligatoire (mot de passe du rôle $UTILISATEUR)" >&2; exit 2; }

echo "1/4 Rôle « $UTILISATEUR » et base « $BASE » sur $HOTE:$PORT (superutilisateur $SUPER)"
$PSQL -h "$HOTE" -p "$PORT" -U "$SUPER" -d postgres -q -v base="$BASE" -v utilisateur="$UTILISATEUR" \
  -v motdepasse="$MOT_DE_PASSE" -v remplacer="$REMPLACER" < "$ICI/creer-base.sql"

app() { PGPASSWORD="$MOT_DE_PASSE" $PSQL -h "$HOTE" -p "$PORT" -U "$UTILISATEUR" -d "$BASE" "$@"; }

if [ "$DEMO" = non ]; then
  echo "Base prête. Au premier démarrage, TraceAgile crée le schéma, les référentiels et l'administrateur"
  echo "(TRACEAGILE_ADMIN_LOGIN / TRACEAGILE_ADMIN_PASSWORD)."
  exit 0
fi

TABLES=$(app -tA -c "select count(*) from information_schema.tables where table_schema = 'public'" | tr -d '[:space:]\r')
if [ "$TABLES" != "0" ]; then
  echo "La base « $BASE » n'est pas vide ($TABLES tables) : la démo ne s'injecte que dans une base neuve (--remplacer la recrée)." >&2
  exit 3
fi

echo "2/4 Injection de la démo SwagLabs (schéma, référentiels, comptes, projet SWAG)"
app -q -v ON_ERROR_STOP=1 < "$ICI/demo/swaglabs.sql" > /dev/null

echo "3/4 Serveur d'exécution de la démo : adresse ${URL_SERVEUR:-inchangée}, à appairer depuis TraceAgile"
app -q -v url_serveur="$URL_SERVEUR" < "$ICI/apres-demo.sql"

if [ -n "$PIECES_JOINTES" ]; then
  echo "4/4 Pièces jointes de la démo → $PIECES_JOINTES (TRACEAGILE_ATTACHMENTS_DIR)"
  mkdir -p "$PIECES_JOINTES"
  cp -R "$ICI/demo/pieces-jointes/." "$PIECES_JOINTES/"
else
  echo "4/4 Pièces jointes : copiez $ICI/demo/pieces-jointes dans le dossier TRACEAGILE_ATTACHMENTS_DIR"
fi
echo "Démo SwagLabs installée : comptes admin, po, qa1, qa2, dev, viewer — mot de passe « SwagLabs-2026 » (à changer)."
