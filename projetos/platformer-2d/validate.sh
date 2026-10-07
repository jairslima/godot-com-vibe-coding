#!/usr/bin/env bash
# validate.sh: Pipeline de validação e testes automatizados para o projeto Plataforma 2D (Godot 4.7.2)
set -euo pipefail

PROJECT_PATH="${1:-.}"

echo "============================================================"
echo "   PIPELINE DE VALIDACAO E TESTES AUTOMATIZADOS (GODOT)     "
echo "============================================================"

# 1. Deteccao de comando
GODOT_CMD="godot"
if command -v godot_console &> /dev/null; then
    GODOT_CMD="godot_console"
fi

echo "[1/6] Detectando Godot Engine ($GODOT_CMD)..."
$GODOT_CMD --version

echo "[2/6] Importando recursos e atualizando UIDs (--import)..."
$GODOT_CMD --headless --path "$PROJECT_PATH" --import

echo "[3/6] Analisando sintaxe de scripts GDScript (--check-only)..."
find "$PROJECT_PATH" -name "*.gd" -not -path "*/.godot/*" | while read -r script; do
    rel_path="res://${script#$PROJECT_PATH/}"
    $GODOT_CMD --headless --path "$PROJECT_PATH" --check-only -s "$rel_path"
done
echo "      Scripts GDScript validados com sucesso."

echo "[4/6] Executando smoke test via SceneTree (-s res://tools/smoke_test.gd)..."
$GODOT_CMD --headless --path "$PROJECT_PATH" -s res://tools/smoke_test.gd

echo "[5/6] Executando suites de regressao e integracao headless..."
echo "  -> [5.1] Suite de Persistencia e Save/Load (test_save_load.tscn)..."
$GODOT_CMD --headless --path "$PROJECT_PATH" --scene res://src/levels/test_save_load.tscn

echo "  -> [5.2] Suite de Fisica, Salto e Camera (test_physics.tscn)..."
$GODOT_CMD --headless --path "$PROJECT_PATH" --scene res://src/levels/test_physics.tscn

echo "[6/6] Executando smoke test na fase principal (60 frames)..."
$GODOT_CMD --headless --no-header --path "$PROJECT_PATH" --scene res://src/levels/level_01.tscn --quit-after 60

echo "============================================================"
echo "   TODAS AS VERIFICACOES PASSARAM COM SUCESSO!              "
echo "============================================================"
exit 0
