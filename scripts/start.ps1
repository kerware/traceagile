# Démarre TraceAgile (PostgreSQL, API, simulateur, front) avec le jeu de démonstration.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
docker compose up --build -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host 'TraceAgile : http://localhost:3000  (admin / demo)'
Write-Host 'API        : http://localhost:8085/swagger-ui.html'
