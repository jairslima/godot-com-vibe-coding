# validate.ps1: Script de validacao automatizada para projetos Godot 4.7.2
param (
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "=== VALIDACAO AGENTICA DE PROJETO GODOT ===" -ForegroundColor Cyan

# 1. Detectar comando do Godot
$godotCmd = if (Get-Command "godot_console" -ErrorAction SilentlyContinue) { "godot_console" } else { "godot" }
Write-Host "[1/4] Verificando versao do Godot ($godotCmd)..."
$version = & $godotCmd --version
Write-Host "Versao detectada: $version"

# 2. Importacao headless de recursos
Write-Host "[2/4] Executando importacao headless (--import)..."
& $godotCmd --headless --path $ProjectPath --import
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha na importacao de recursos (ExitCode: $LASTEXITCODE)"
    exit $LASTEXITCODE
}
Write-Host "Importacao concluida com sucesso." -ForegroundColor Green

# 3. Validacao estatica de GDScript (--check-only)
Write-Host "[3/4] Analisando sintaxe de scripts GDScript (--check-only)..."
$scripts = Get-ChildItem -Path $ProjectPath -Filter "*.gd" -Recurse | Where-Object { $_.FullName -notmatch "\.godot" }
$failed = 0

foreach ($script in $scripts) {
    $relPath = "res://" + ($script.FullName.Substring((Resolve-Path $ProjectPath).Path.Length).TrimStart("\", "/")).Replace("\", "/")
    Write-Host "  -> Checando: $relPath"
    & $godotCmd --headless --path $ProjectPath --check-only -s $relPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "     FALHA no script: $relPath" -ForegroundColor Red
        $failed++
    }
}

if ($failed -gt 0) {
    Write-Error "Validacao falhou em $failed script(s)."
    exit 1
}
Write-Host "Todos os scripts GDScript foram analisados com sucesso." -ForegroundColor Green

# 4. Execucao de smoke test de cena (--scene e --quit-after)
Write-Host "[4/4] Executando smoke test na cena principal (10 frames)..."
& $godotCmd --headless --no-header --path $ProjectPath --scene res://main.tscn --quit-after 10
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha na execucao da cena res://main.tscn (ExitCode: $LASTEXITCODE)"
    exit $LASTEXITCODE
}
Write-Host "Smoke test concluido com sucesso." -ForegroundColor Green

Write-Host "=== TODAS AS VERIFICACOES PASSARAM COM SUCESSO ===" -ForegroundColor Cyan
exit 0
