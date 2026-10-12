# Démarre TraceAgile (docs/installation.md §5) : lit traceagile.env à côté de ce script puis lance le jar.
$ErrorActionPreference = 'Stop'
$ici = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ici
$fichier = Join-Path $ici 'traceagile.env'
if (-not (Test-Path $fichier)) { throw 'traceagile.env absent : copiez traceagile.env.exemple et adaptez-le' }
foreach ($ligne in Get-Content -Encoding UTF8 $fichier) {
    if ($ligne -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { Set-Item "env:$($Matches[1])" $Matches[2] }
}
$options = @(if ($env:JAVA_OPTS) { $env:JAVA_OPTS.Trim() -split '\s+' })
& java @options -jar (Join-Path $ici 'traceagile-api.jar')
exit $LASTEXITCODE
