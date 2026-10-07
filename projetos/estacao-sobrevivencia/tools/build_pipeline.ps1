# build_pipeline.ps1 - Pipeline automatizado de validacao e exportacao para Godot 4.7.2
param(
    [string]$Preset = "Windows Desktop",
    [string]$OutputPath = "build/EstacaoSobrevivencia.exe"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Iniciando pipeline de build: Estacao Sobrevivencia 3D" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Validacao de pre-requisitos via SceneTree script
Write-Host "`n[1/3] Executando auditoria de pre-requisitos..." -ForegroundColor Yellow
& godot_console --headless --path . -s res://tools/test_build_integrity.gd
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha na auditoria de integridade de pré-build (codigo: $LASTEXITCODE)"
    exit $LASTEXITCODE
}

# 2. Exportacao headless
Write-Host "`n[2/3] Exportando projeto com preset '$Preset'..." -ForegroundColor Yellow
& godot_console --headless --path . --export-release $Preset $OutputPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha na exportacao headless do Godot (codigo: $LASTEXITCODE)"
    exit $LASTEXITCODE
}

# 3. Smoke test do executavel gerado fora do editor
Write-Host "`n[3/3] Executando smoke test do binario standalone..." -ForegroundColor Yellow
if (Test-Path $OutputPath) {
    $item = Get-Item $OutputPath
    $tamanhoMb = [math]::Round($item.Length / 1MB, 2)
    Write-Host "Binario gerado com sucesso: $($item.FullName) ($tamanhoMb MB)" -ForegroundColor Green
    
    # Smoke test headless de 2 quadros
    & $OutputPath --headless --quit-after 2
    if ($LASTEXITCODE -ne 0) {
        Write-Error "O binario exportado falhou no smoke test de execucao (codigo: $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
    Write-Host "Smoke test aprovado: o binario executou e encerrou com codigo 0." -ForegroundColor Green
} else {
    Write-Error "O executavel de saida nao foi encontrado no caminho especificado: $OutputPath"
    exit 1
}

Write-Host "`nPipeline concluido com 100% de sucesso!" -ForegroundColor Cyan
