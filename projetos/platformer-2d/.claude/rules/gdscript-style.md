---
description: Regras de estilo e integridade para scripts GDScript
globs: src/**/*.gd
---

# Regras de GDScript do Projeto

1. Tipagem estática obrigatória em todos os argumentos, retornos de função e variáveis exportadas.
2. Não utilize caminhos rígidos de nós. Prefira Scene Unique Nodes (`%`) ou anotações `@onready` explícitas.
3. Não use chamadas `get_node()` para acessar nós distantes na Scene Tree.
4. Mantenha os nomes de sinais no passado ou como eventos (`collected`, `health_changed`).
