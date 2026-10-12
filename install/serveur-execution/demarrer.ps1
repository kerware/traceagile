# Démarre le serveur d’exécution (docs/installation.md §7) : lit serveur-execution.env à côté de ce script puis lance le jar.
$ErrorActionPreference = 'Stop'
$ici = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ici
$fichier = Join-Path $ici 'serveur-execution.env'
if (-not (Test-Path $fichier)) { throw 'serveur-execution.env absent : copiez serveur-execution.env.exemple et adaptez-le' }
foreach ($ligne in Get-Content -Encoding UTF8 $fichier) {
    if ($ligne -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { Set-Item "env:$($Matches[1])" $Matches[2] }
}
$options = @(if ($env:JAVA_OPTS) { $env:JAVA_OPTS.Trim() -split '\s+' })
& java @options -jar (Join-Path $ici 'execution-server.jar')
exit $LASTEXITCODE
