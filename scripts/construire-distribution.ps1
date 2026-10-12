# Produit les deux livrables hors Docker (docs/installation.md §2), comme construire-distribution.sh :
#   dist\traceagile-<version>\traceagile\          traceagile-api.jar (API + interface + guide), configuration, démarrage
#   dist\traceagile-<version>\serveur-execution\   execution-server.jar (serveur + interface), configuration, démarrage
#   dist\traceagile-<version>\base-de-donnees\     création de la base, démo SwagLabs
# et une archive .zip de chacun des deux premiers (avec base-de-donnees dans celle de TraceAgile).
# Prérequis : Java 21, Maven 3.9 ; Node est téléchargé par Maven pour construire les interfaces.
$ErrorActionPreference = 'Stop'
$racine = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $racine
$version = ([xml](Get-Content -Raw (Join-Path $racine 'backend\pom.xml'))).project.version -replace '-SNAPSHOT$', ''
$dist = Join-Path $racine "dist\traceagile-$version"

Write-Host "1/3 Construction des jars ($version)"
Push-Location backend
try {
    & mvn -q -pl traceagile-api,execution-server -am package -Pdistribution -DskipTests
    if ($LASTEXITCODE -ne 0) { throw "mvn a échoué (code $LASTEXITCODE)" }
} finally { Pop-Location }

Write-Host "2/3 Assemblage de $dist"
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force $dist | Out-Null
foreach ($dossier in 'traceagile', 'serveur-execution', 'base-de-donnees') {
    Copy-Item -Recurse (Join-Path $racine "install\$dossier") $dist
}
Remove-Item (Join-Path $dist 'base-de-donnees\generer-demo-swaglabs.sh')
Copy-Item 'backend\traceagile-api\target\traceagile-api.jar' (Join-Path $dist 'traceagile')
Copy-Item 'backend\execution-server\target\execution-server.jar' (Join-Path $dist 'serveur-execution')
Copy-Item 'docs\installation.md' (Join-Path $dist 'INSTALLATION.md')
Copy-Item 'docs\installation-traceagile.html' (Join-Path $dist 'INSTALLATION.html')
Copy-Item 'docs\installation-traceagile.docx' (Join-Path $dist 'INSTALLATION.docx')

Write-Host '3/3 Archives'
$zipTraceAgile = Join-Path $racine "dist\traceagile-$version.zip"
$zipServeur = Join-Path $racine "dist\serveur-execution-$version.zip"
Remove-Item -Force -ErrorAction SilentlyContinue $zipTraceAgile, $zipServeur
$note = @('md', 'html', 'docx' | ForEach-Object { Join-Path $dist "INSTALLATION.$_" })
Compress-Archive -Path (@((Join-Path $dist 'traceagile'), (Join-Path $dist 'base-de-donnees')) + $note) -DestinationPath $zipTraceAgile
Compress-Archive -Path (@(Join-Path $dist 'serveur-execution') + $note) -DestinationPath $zipServeur
Get-ChildItem (Join-Path $racine 'dist') | Format-Table Name, Length
