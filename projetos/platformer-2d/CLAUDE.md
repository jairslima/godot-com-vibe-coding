@AGENTS.md

# Instruções para Claude Code no Projeto Plataforma 2D

Este projeto adota o AGENTS.md como contrato de governança operacional único.
Leia e aplique rigorosamente todas as regras definidas em AGENTS.md.

## Diretrizes Específicas de Execução para Claude Code
1. Para validação de código, utilize preferencialmente o executável de console:
   `godot_console --headless --path . --import`
2. Antes de editar qualquer arquivo `.tscn` ou `.tres`, inspecione seu conteúdo com ferramentas de leitura para não quebrar referências textuais.
3. Não crie dependências cíclicas entre scripts. Mantenha os componentes em `res://src/components/` totalmente autocontidos.
4. Para tarefas complexas ou multi-arquivo, consulte ou atualize o plano correspondente em `docs/plans/PLANS.md`.
