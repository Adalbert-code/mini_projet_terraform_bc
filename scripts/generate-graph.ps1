# =============================================================================
# Script PowerShell pour générer le schéma de l'infrastructure Terraform
# =============================================================================

param(
    [string]$OutputFormat = "png",
    [string]$OutputFile = "infrastructure",
    [switch]$OpenAfter
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppDir = Join-Path $ScriptDir "..\app"
$OutputDir = Join-Path $ScriptDir "..\docs"

# Créer le dossier docs s'il n'existe pas
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Dossier 'docs' créé" -ForegroundColor Green
}

# Vérifier si Graphviz est installé
$dotPath = Get-Command dot -ErrorAction SilentlyContinue
if (!$dotPath) {
    Write-Host "Graphviz n'est pas installé!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installez-le avec une des commandes suivantes:" -ForegroundColor Yellow
    Write-Host "  choco install graphviz" -ForegroundColor Cyan
    Write-Host "  winget install graphviz" -ForegroundColor Cyan
    Write-Host "  scoop install graphviz" -ForegroundColor Cyan
    exit 1
}

Write-Host "=== Génération du schéma d'infrastructure ===" -ForegroundColor Cyan
Write-Host ""

# Se déplacer dans le dossier app
Push-Location $AppDir

try {
    # Vérifier si Terraform est initialisé
    if (!(Test-Path ".terraform")) {
        Write-Host "Initialisation de Terraform..." -ForegroundColor Yellow
        terraform init -backend=false | Out-Null
    }

    # Générer le graphe
    $dotFile = Join-Path $OutputDir "$OutputFile.dot"
    $outputPath = Join-Path $OutputDir "$OutputFile.$OutputFormat"

    Write-Host "Génération du fichier DOT..." -ForegroundColor Yellow
    terraform graph > $dotFile

    Write-Host "Conversion en $OutputFormat..." -ForegroundColor Yellow
    dot -T$OutputFormat $dotFile -o $outputPath

    # Nettoyer le fichier DOT intermédiaire
    Remove-Item $dotFile -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Schéma généré avec succès!" -ForegroundColor Green
    Write-Host "Fichier: $outputPath" -ForegroundColor Cyan

    # Ouvrir le fichier si demandé
    if ($OpenAfter) {
        Start-Process $outputPath
    }
}
finally {
    Pop-Location
}
