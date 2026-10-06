# AGENTS.md - Regras Locais para Criação e Manutenção de Níveis (Levels)

Este arquivo complementa o AGENTS.md raiz com regras específicas para o subsistema de fases (`res://src/levels/`).

## 1. Estrutura Padrão de Fases
- Toda cena de fase deve ter como nó raiz um `Node2D` estendendo a classe de controle de nível.
- O cenário estático deve ser composto por instâncias de `TileMapLayer` segregadas:
  - `BackgroundLayer`: decoração sem colisão.
  - `WorldLayer`: terreno sólido com máscaras de colisão física ativas.
- Instâncias do `Player` devem ser filhas diretas da fase ou de um nó agrupador `Entities`.

## 2. Limites de Escopo em Níveis
- Ao editar uma fase, não altere os scripts de componentes (`src/components/`) nem a física do jogador (`src/entities/player/`).
- Novas fases devem obrigatoriamente incluir uma área de conclusão (`GoalArea`) conectada ao sinal de transição de fase.
- Todo script de fase (`level_XX.gd`) deve ser acompanhado de um teste automatizado ou ser compatível com a suíte headless existente.
