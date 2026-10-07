# AGENTS.md

# Projeto Estação Sobrevivência by Jair Lima
# Contrato Operacional de Governança Agêntica

Este repositório contém o código-fonte, cenas 3D, recursos, documentação e testes automatizados do jogo Estação Sobrevivência no Godot Engine. Qualquer agente autônomo ou assistente de IA operando neste repositório deve obedecer estritamente às diretrizes abaixo.

## 1. Baseline Tecnológica e Version Gate
- Engine: Godot 4.7.2 Stable (oficial).
- Sistema Operacional: Windows 11.
- Linguagem: GDScript com tipagem estática rigorosa e anotações explícitas (`:=`, `@export`, `@onready`).
- Arquitetura 3D: Nós 3D nativos (CharacterBody3D, Camera3D, CSGBox3D, NavigationRegion3D).
- Proibição estrita: não utilize métodos legados do Godot 3 nem invente métodos ou nós inexistentes. Na dúvida, consulte a documentação oficial da versão 4.7.stable.

## 2. Contrato Arquitetural
- Organização em pastas:
  - `res://src/entities/`: entidades dinâmicas (Player, Creature).
  - `res://src/core/`: gerenciadores de partida, persistência e conformidade (`GameManager`, `StoreManager`, `ComplianceManager`).
  - `res://src/levels/`: cenários e fases tridimensionais.
  - `res://src/ui/`: interfaces em camadas CanvasLayer.
  - `res://tests/`: suítes de validação automatizadas em modo headless.
  - `res://tools/`: scripts e pipelines de automação CLI.
- Princípio de desacoplamento: "Call down, signal up". Entidades comunicam mudanças de estado por sinais e recebem comandos diretos de seus controladores.

## 3. Delimitação de Escopo e Blast Radius
- Toda alteração deve ser cirúrgica, atômica e justificada no contexto da tarefa.
- Nunca altere mais de 2 ou 3 arquivos por interação sem alinhamento prévio com o desenvolvedor humano.
- Preserve a integridade de arquivos de cena textuais (`.tscn`), mantendo as referências e UIDs intactos.

## 4. Segurança e Políticas de Sandbox
- Operação em sandbox restrita ao espaço de trabalho local (`workspace-write`).
- Proibição absoluta de credenciais ou segredos em código, arquivos de cena ou repositórios remotos.
- A pasta `.godot/` e executáveis compilados na pasta `build/` nunca devem ser versionados no Git.

## 5. Validação Automatizada Obrigatória
Antes de concluir qualquer ciclo de trabalho:
1. Reimportação headless: `godot --headless --path . --import`
2. Execução da suíte de testes relevante: `godot --headless --path . --scene res://tests/test_mvp_runner.tscn`
3. Auditoria de maturidade: `godot --headless --path . -s res://tools/audit_project_maturity.gd`

## 6. Definition of Done
1. GDScript sem erros ou avisos na saída padrão.
2. 100% dos testes da suíte headless aprovados com código de saída 0.
3. Git diff limpo e restrito ao escopo acordado.
4. Documentação técnica atualizada em SPEC.md e docs/PROVENANCE.md.
