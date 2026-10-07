# validate.ps1: Script de validacao automatizada para o projeto Plataforma 2D (Godot 4.7.2)
param (
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"
$swTotal = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   PIPELINE DE VALIDACAO E TESTES AUTOMATIZADOS (GODOT)     " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Deteccao de executavel
$godotCmd = if (Get-Command "godot_console" -ErrorAction SilentlyContinue) { "godot_console" } else { "godot" }
Write-Host "[1/6] Detectando Godot Engine ($godotCmd)..."
$version = & $godotCmd --version
Write-Host "      Versao identificada: $version" -ForegroundColor Green

# 2. Importacao headless
Write-Host "[2/6] Importando recursos e atualizando UIDs (--import)..."
& $godotCmd --headless --path $ProjectPath --import
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Importacao headless retornou codigo de erro: $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "      Importacao concluida com sucesso." -ForegroundColor Green

# 3. Analise estatica (--check-only)
Write-Host "[3/6] Analisando sintaxe de scripts GDScript (--check-only)..."
$scripts = Get-ChildItem -Path $ProjectPath -Filter "*.gd" -Recurse | Where-Object { $_.FullName -notmatch "\.godot" }
$falhasSintaxe = 0

foreach ($script in $scripts) {
    $caminhoRelativo = "res://" + ($script.FullName.Substring((Resolve-Path $ProjectPath).Path.Length).TrimStart("\", "/")).Replace("\", "/")
    & $godotCmd --headless --path $ProjectPath --check-only -s $caminhoRelativo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      FALHA DE ANALISE: $caminhoRelativo" -ForegroundColor Red
        $falhasSintaxe++
    }
}

if ($falhasSintaxe -gt 0) {
    Write-Error "FALHA: $falhasSintaxe script(s) apresentaram erros de sintaxe ou tipos."
    exit 1
}
Write-Host "      Todos os $($scripts.Count) scripts GDScript estao sintaticamente validos." -ForegroundColor Green

# 4. Smoke Test headless via SceneTree
Write-Host "[4/6] Executando smoke test via SceneTree (-s res://tools/smoke_test.gd)..."
& $godotCmd --headless --path $ProjectPath -s res://tools/smoke_test.gd
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Smoke test de recursos vitais falhou (Codigo: $LASTEXITCODE)."
    exit $LASTEXITCODE
}
Write-Host "      Smoke test aprovado: cenas, recursos e Player validos." -ForegroundColor Green

# 5. Suites de teste headless dedicadas (Save/Load e Fisica)
Write-Host "[5/6] Executando suites de regressao e integracao headless..."

Write-Host "  -> [5.1] Suite de Persistencia e Save/Load (test_save_load.tscn)..."
& $godotCmd --headless --path $ProjectPath --scene res://src/levels/test_save_load.tscn
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Suite de persistencia falhou (Codigo: $LASTEXITCODE)."
    exit $LASTEXITCODE
}

Write-Host "  -> [5.2] Suite de Fisica, Salto e Camera (test_physics.tscn)..."
& $godotCmd --headless --path $ProjectPath --scene res://src/levels/test_physics.tscn
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Suite de fisica e movimento falhou (Codigo: $LASTEXITCODE)."
    exit $LASTEXITCODE
}
Write-Host "      Suites de integracao concluidas com 100% de assercoes aprovadas." -ForegroundColor Green

# 6. Smoke Test de execucao de fase principal
Write-Host "[6/6] Executando smoke test de ciclo de vida na fase Level 01 (60 frames)..."
& $godotCmd --headless --no-header --path $ProjectPath --scene res://src/levels/level_01.tscn --quit-after 60
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Execucao do Level 01 interrompida de forma anomala (Codigo: $LASTEXITCODE)."
    exit $LASTEXITCODE
}
Write-Host "      Level 01 executou 60 quadros sem excecoes." -ForegroundColor Green

$swTotal.Stop()
$segundos = [math]::Round($swTotal.Elapsed.TotalSeconds, 2)
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   TODAS AS VERIFICACOES PASSARAM COM SUCESSO! ($segundos s)  " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
exit 0
