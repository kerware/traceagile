<#
.SYNOPSIS
  Installation hors Docker (docs/installation.md) : crée le rôle et la base PostgreSQL de TraceAgile et,
  avec -Demo, injecte le jeu de démonstration SwagLabs (projet SWAG, comptes de démonstration).

.EXAMPLE
  .\installer-base.ps1 -MotDePasse 'secret'
  .\installer-base.ps1 -MotDePasse 'secret' -Demo -UrlServeur http://machine-de-test:8091 -PiecesJointes C:\TraceAgile\pieces-jointes

.NOTES
  Le mot de passe du superutilisateur est demandé par psql (ou lu dans $env:PGPASSWORD / pgpass.conf).
  $env:PSQL remplace la commande psql (chemin complet, ex. "C:\Program Files\PostgreSQL\16\bin\psql.exe").
#>
param(
    [Parameter(Mandatory = $true)][string]$MotDePasse,
    [string]$Hote = 'localhost',
    [int]$Port = 5432,
    [string]$Superutilisateur = 'postgres',
    [string]$Base = 'traceagile',
    [string]$Utilisateur = 'traceagile',
    [switch]$Demo,
    [switch]$Remplacer,
    [string]$UrlServeur = '',
    [string]$PiecesJointes = ''
)
$ErrorActionPreference = 'Stop'
$ici = Split-Path -Parent $MyInvocation.MyCommand.Path
$psql = if ($env:PSQL) { $env:PSQL } else { 'psql' }

function Invoke-Psql([string[]]$Arguments, [string]$Script, [string]$Password) {
    $previous = $env:PGPASSWORD
    if ($Password) { $env:PGPASSWORD = $Password }
    try {
        if ($Script) { Get-Content -Raw -Encoding UTF8 $Script | & $psql @Arguments } else { & $psql @Arguments }
        if ($LASTEXITCODE -ne 0) { throw "psql a échoué (code $LASTEXITCODE)" }
    } finally {
        $env:PGPASSWORD = $previous
    }
}

$remplacerValeur = if ($Remplacer) { 'oui' } else { 'non' }
Write-Host "1/4 Rôle « $Utilisateur » et base « $Base » sur ${Hote}:$Port (superutilisateur $Superutilisateur)"
Invoke-Psql @('-h', $Hote, '-p', $Port, '-U', $Superutilisateur, '-d', 'postgres', '-q', '-v', "base=$Base", '-v', "utilisateur=$Utilisateur",
    '-v', "motdepasse=$MotDePasse", '-v', "remplacer=$remplacerValeur") (Join-Path $ici 'creer-base.sql') $null

$app = @('-h', $Hote, '-p', $Port, '-U', $Utilisateur, '-d', $Base)
if (-not $Demo) {
    Write-Host "Base prête. Au premier démarrage, TraceAgile crée le schéma, les référentiels et l'administrateur"
    Write-Host "(TRACEAGILE_ADMIN_LOGIN / TRACEAGILE_ADMIN_PASSWORD)."
    exit 0
}

$tables = (& { $env:PGPASSWORD = $MotDePasse; & $psql @app -tA -c "select count(*) from information_schema.tables where table_schema = 'public'" }).Trim()
if ($tables -ne '0') {
    Write-Error "La base « $Base » n'est pas vide ($tables tables) : la démo ne s'injecte que dans une base neuve (-Remplacer la recrée)."
    exit 3
}

Write-Host '2/4 Injection de la démo SwagLabs (schéma, référentiels, comptes, projet SWAG)'
Invoke-Psql ($app + @('-q', '-v', 'ON_ERROR_STOP=1', '-o', ($(if ($IsLinux) { '/dev/null' } else { 'NUL' })))) (Join-Path $ici 'demo\swaglabs.sql') $MotDePasse

Write-Host "3/4 Serveur d'exécution de la démo : adresse $(if ($UrlServeur) { $UrlServeur } else { 'inchangée' }), à appairer depuis TraceAgile"
Invoke-Psql ($app + @('-q', '-v', "url_serveur=$UrlServeur")) (Join-Path $ici 'apres-demo.sql') $MotDePasse

if ($PiecesJointes) {
    Write-Host "4/4 Pièces jointes de la démo → $PiecesJointes (TRACEAGILE_ATTACHMENTS_DIR)"
    New-Item -ItemType Directory -Force $PiecesJointes | Out-Null
    Copy-Item -Recurse -Force (Join-Path $ici 'demo\pieces-jointes\*') $PiecesJointes
} else {
    Write-Host "4/4 Pièces jointes : copiez $(Join-Path $ici 'demo\pieces-jointes') dans le dossier TRACEAGILE_ATTACHMENTS_DIR"
}
Write-Host 'Démo SwagLabs installée : comptes admin, po, qa1, qa2, dev, viewer — mot de passe « SwagLabs-2026 » (à changer).'
