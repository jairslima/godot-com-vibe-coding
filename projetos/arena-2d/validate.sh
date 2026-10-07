#!/usr/bin/env bash
# validate.sh: Script de validacao automatizada para projetos Godot 4.7.2
set -euo pipefail

PROJECT_PATH="${1:-.}"

echo "=== VALIDACAO AGENTICA DE PROJETO GODOT ==="

# 1. Detectar comando Godot
GODOT_CMD="godot"
if command -v godot_console &> /dev/null; then
    GODOT_CMD="godot_console"
elif ! command -v godot &> /dev/null; then
    echo "Erro: Executavel do Godot nao encontrado no PATH." >&2
    exit 1
fi

echo "[1/4] Verificando versao do Godot ($GODOT_CMD)..."
"$GODOT_CMD" --version

echo "[2/4] Executando importacao headless (--import)..."
"$GODOT_CMD" --headless --path "$PROJECT_PATH" --import

echo "[3/4] Analisando sintaxe de scripts GDScript (--check-only)..."
find "$PROJECT_PATH" -type f -name "*.gd" ! -path "*/.godot/*" | while read -r script_file; do
    rel_path="res://${script_file#$PROJECT_PATH/}"
    rel_path="${rel_path#res://./}"
    rel_path="${rel_path//\\//}"
    if [[ "$rel_path" != res://* ]]; then
        rel_path="res://$rel_path"
    fi
    echo "  -> Checando: $rel_path"
    "$GODOT_CMD" --headless --path "$PROJECT_PATH" --check-only -s "$rel_path"
done

echo "[4/4] Executando smoke test na cena principal (10 frames)..."
"$GODOT_CMD" --headless --no-header --path "$PROJECT_PATH" --scene res://main.tscn --quit-after 10

echo "=== TODAS AS VERIFICACOES PASSARAM COM SUCESSO ==="
exit 0
