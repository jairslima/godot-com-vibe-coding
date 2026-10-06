# AGENTS.md

# Projeto Estação 3D by Jair Lima
# Contrato Operacional de Governança Agêntica

Este repositório contém o código-fonte, cenas, recursos e testes automatizados do jogo Estação 3D desenvolvido no Godot Engine. Qualquer agente autônomo ou assistente de IA operando neste repositório deve obedecer estritamente às diretrizes abaixo.

## 1. Baseline Tecnológica e Version Gate
- Engine: Godot 4.7.2 Stable (oficial).
- Sistema Operacional do ambiente: Windows 11.
- Linguagem: GDScript com tipagem estática rigorosa e inferência explícita (`:=` ou tipo declarado).
- Renderer: Forward+ (Vulkan moderno para pipeline 3D com sombras e materiais PBR).
- Proibição estrita: não utilize sintaxes, métodos ou nós do Godot 3 (exemplo: `Spatial`, `SpatialMaterial`, `KinematicBody`, `ImmediateGeometry`, `is_on_floor()` sem chamar `move_and_slide()` prévio).
- Proibição de contaminação 2D: no espaço 3D, posições e velocidades utilizam `Vector3`, nunca `Vector2`. O eixo vertical (altura) é +Y e o sentido frontal padrão é -Z (`Vector3.FORWARD`). Não atribua valores escalares (float) à propriedade `rotation` de nós `Node3D`.
- Nunca invente classes, métodos, sinais ou flags de linha de comando. Na dúvida sobre qualquer recurso da API 4.7.2, consulte a documentação oficial ou declare o item como NÃO CONFIRMADO antes de codificar.

## 2. Contrato Arquitetural
- Organização em `res://src/`:
  - `entities/`: cenas e scripts de entidades 3D com física (Player, ameaças).
  - `levels/`: setores da estação e salas instanciando geometria, luzes e entidades.
  - `components/`: comportamentos modulares atômicos (interação via raycast, sensores de proximidade, gatilhos).
  - `props/`: objetos de cenário interativos ou estáticos (terminais, portas, contêineres).
  - `ui/`: interfaces em tela (`CanvasLayer`) ou na interface 3D.
- Geometria e Prototipagem: utilize nós CSG (`CSGBox3D`, `CSGCombiner3D`) com `use_collision = true` para prototipagem rápida e bloqueio de fases (_blockout_). Malhas de produção utilizam `MeshInstance3D` com colisores explícitos (`StaticBody3D` / `CollisionShape3D`).
- Regra de ouro: "Call down, signal up". O Player ou entidades móveis nunca acessam o HUD, o gerenciador de fase ou a câmera diretamente.
- Acesso a nós: utilize Scene Unique Nodes (`%NomeDoNo`) para referências internas essenciais na cena.

## 3. Delimitação de Escopo e Blast Radius
- Mantenha alterações estritamente cirúrgicas. Nunca modifique mais de 2 ou 3 arquivos por tarefa sem aprovação prévia do desenvolvedor humano.
- Proibido refatorar sistemas adjacentes que não façam parte do objetivo imediato da tarefa.
- Toda nova mecânica deve ser acompanhada de uma suíte ou script de teste automatizado headless na pasta correspondente.
- Arquivos de cena (`.tscn`) e recursos (`.tres`): leia o arquivo textual antes de alterar. Preserve cabeçalhos, IDs externos (`ext_resource`) e sub-recursos (`sub_resource`).

## 4. Segurança e Políticas de Sandbox
- Operação em modo restrito de escrita no workspace (`workspace-write`). Nunca tente acessar ou modificar arquivos fora da pasta raiz do projeto.
- Nunca adicione credenciais, chaves de API ou tokens a nenhum arquivo do repositório.
- A pasta `.godot/` e arquivos temporários nunca devem ser adicionados ao controle de versão.

## 5. Validação Automatizada Obrigatória
Antes de considerar qualquer tarefa pronta, execute os seguintes passos na linha de comando:
1. Reimportação headless e checagem de integridade:
   `godot_console --headless --path . --import`
2. Validação da suíte de testes relevante (exemplo):
   `godot_console --headless --path . --scene res://src/levels/test_bootstrap_3d.tscn`
3. Smoke test da cena principal ou setor modificado:
   `godot_console --headless --path . --scene res://src/levels/station_hub.tscn --quit-after 30`

## 6. Definition of Done (Critérios de Aceite)
Uma tarefa só é considerada concluída pelo agente quando todos os critérios abaixo forem satisfeitos:
1. O código GDScript compila e executa sem erros ou advertências no Output do Godot.
2. A suíte de testes headless foi executada e aprovou 100% das asserções.
3. As alterações no Git estão restritas aos arquivos combinados no escopo.
4. O arquivo `SPEC.md` ou documentação do projeto foi atualizado se houver novos componentes ou nós.
5. A mensagem de commit segue o padrão convencional: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
