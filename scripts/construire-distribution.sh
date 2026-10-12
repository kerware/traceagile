#!/usr/bin/env bash
# Produit les deux livrables hors Docker (docs/installation.md §2) :
#   dist/traceagile-<version>/traceagile/          traceagile-api.jar (API + interface + guide), configuration, démarrage
#   dist/traceagile-<version>/serveur-execution/   execution-server.jar (serveur + interface), configuration, démarrage
#   dist/traceagile-<version>/base-de-donnees/     création de la base, démo SwagLabs
# et une archive .zip de chacun des deux premiers (avec base-de-donnees dans celle de TraceAgile).
# Prérequis : Java 21, Maven 3.9 ; Node est téléchargé par Maven pour construire les interfaces.
set -euo pipefail
cd "$(dirname "$0")/.."
RACINE="$(pwd)"
VERSION=$(grep -m2 '<version>' backend/pom.xml | tail -1 | sed 's:.*<version>\(.*\)</version>.*:\1:')
VERSION="${VERSION%-SNAPSHOT}"
DIST="$RACINE/dist/traceagile-$VERSION"

echo "1/3 Construction des jars ($VERSION)"
(cd backend && mvn -q -pl traceagile-api,execution-server -am package -Pdistribution -DskipTests)

echo "2/3 Assemblage de $DIST"
rm -rf "$DIST" && mkdir -p "$DIST"
cp -R install/traceagile install/serveur-execution install/base-de-donnees "$DIST/"
rm -f "$DIST/base-de-donnees/generer-demo-swaglabs.sh"
cp backend/traceagile-api/target/traceagile-api.jar "$DIST/traceagile/"
cp backend/execution-server/target/execution-server.jar "$DIST/serveur-execution/"
cp docs/installation.md "$DIST/INSTALLATION.md"

echo "3/3 Archives"
cd "$RACINE/dist"
rm -f "traceagile-$VERSION.zip" "serveur-execution-$VERSION.zip"
if command -v zip > /dev/null; then
  zip -qr "traceagile-$VERSION.zip" "traceagile-$VERSION/traceagile" "traceagile-$VERSION/base-de-donnees" "traceagile-$VERSION/INSTALLATION.md"
  zip -qr "serveur-execution-$VERSION.zip" "traceagile-$VERSION/serveur-execution" "traceagile-$VERSION/INSTALLATION.md"
else
  python3 -m zipfile -c "traceagile-$VERSION.zip" "traceagile-$VERSION/traceagile" "traceagile-$VERSION/base-de-donnees" "traceagile-$VERSION/INSTALLATION.md"
  python3 -m zipfile -c "serveur-execution-$VERSION.zip" "traceagile-$VERSION/serveur-execution" "traceagile-$VERSION/INSTALLATION.md"
fi
ls -l "$RACINE/dist"
