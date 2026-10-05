# AGENTS.md - Regras Operacionais do Repositório

Projeto: Plataforma 2D by Jair Lima
Engine: Godot 4.7.2 Stable (Windows 11 / Forward Plus / 2D)
Linguagem: GDScript com tipagem estática obrigatória.

## 1. Contrato de Arquitetura
- Organização modular obrigatória em `res://src/`:
  - `entities/`: Nós autocontidos com cenas e scripts no mesmo diretório específico.
  - `levels/`: Cenas de fases que instanciam entidades.
  - `components/`: Comportamentos atômicos desacoplados.
  - `ui/`: Interface gráfica isolada em CanvasLayer.
- Regra de comunicação: "Call down, signal up". O Player nunca acessa HUD ou Level diretamente.
- Nós internos utilizam Scene Unique Nodes (`%NomeDoNo`) quando referenciados por script.

## 2. Modificações Multi-arquivo
- Nunca altere mais de 2 ou 3 arquivos por tarefa sem aprovação prévia.
- Ao alterar um script, verifique se a cena (`.tscn`) correspondente continua íntegra.
- Não renomeie nem mova cenas ou recursos sem atualizar todas as referências `res://`.
- Não introduza nós globais (Autoload) sem justificativa de arquitetura aprovada.

## 3. Validação e Qualidade
- Todo código deve passar sem erros na CLI:
  `godot_console --headless --path . --import`
  `godot_console --headless --path . --scene res://src/levels/level_01.tscn --quit-after 10`
- Não comite arquivos temporários ou a pasta `.godot/`.
- Mensagens de commit seguem o padrão convencional: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
