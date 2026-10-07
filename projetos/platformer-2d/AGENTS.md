# AGENTS.md

# Projeto Plataforma 2D by Jair Lima
# Contrato Operacional de Governança Agêntica

Este repositório contém o código-fonte, cenas, recursos e testes automatizados do jogo Plataforma 2D desenvolvido no Godot Engine. Qualquer agente autônomo ou assistente de IA operando neste repositório deve obedecer estritamente às diretrizes abaixo.

## 1. Baseline Tecnológica e Version Gate
- Engine: Godot 4.7.2 Stable (oficial).
- Sistema Operacional do ambiente: Windows 11.
- Linguagem: GDScript com tipagem estática rigorosa e inferência explícita (`:=` ou tipo declarado).
- Renderer: Forward+ (compatível com Mobile e Compatibility).
- Proibição estrita: não utilize sintaxes, métodos ou nós do Godot 3 (exemplo: `move_and_slide(velocity)` com argumentos, `yield`, `KinematicBody2D` ou nós obsoletos como `TileMap`).
- Nunca invente classes, métodos, sinais ou flags de linha de comando. Na dúvida sobre qualquer recurso da API 4.7.2, consulte a documentação oficial ou declare o item como NÃO CONFIRMADO antes de codificar.

## 2. Contrato Arquitetural
- Organização em `res://src/`:
  - `entities/`: cenas e scripts de entidades dinâmicas (Player, inimigos).
  - `levels/`: fases e controladores de nível.
  - `components/`: comportamentos modulares atômicos (áreas de perigo, colecionáveis, checkpoints).
  - `ui/`: interfaces gráficas isoladas em camadas `CanvasLayer`.
  - `core/`: gerenciadores de persistência e estados globais essenciais (`SaveManager`).
- Regra de ouro: "Call down, signal up". Filhos e componentes nunca chamam nós pais ou estruturas externas diretamente. O Player nunca acessa HUD, fase ou câmera diretamente.
- Comunicação por eventos: emita sinais customizados e tipados com `.emit()`. Conecte sinais via Callables (`sinal.connect(metodo)`).
- Acesso a nós: utilize Scene Unique Nodes (`%NomeDoNo`) para nós internos referenciados em script, evitando caminhos estáticos frágeis como `get_node("Node2D/Sprite")`.

## 3. Delimitação de Escopo e Blast Radius
- Mantenha alterações estritamente cirúrgicas. Nunca modifique mais de 2 ou 3 arquivos por tarefa sem aprovação prévia do desenvolvedor humano.
- Proibido refatorar sistemas adjacentes que não façam parte do objetivo imediato da tarefa.
- Toda nova mecânica deve ser acompanhada de uma suíte ou script de teste automatizado headless na pasta correspondente.
- Arquivos de cena (`.tscn`) e recursos (`.tres`): leia o arquivo textual antes de alterar. Preserve cabeçalhos, IDs externos (`ext_resource`) e sub-recursos (`sub_resource`).

## 4. Segurança e Políticas de Sandbox
- Operação em modo restrito de escrita no workspace (`workspace-write`). Nunca tente acessar ou modificar arquivos fora da pasta raiz do projeto.
- Nunca execute comandos destrutivos no terminal, como exclusão recursiva de diretórios do sistema ou alterações fora da árvore do projeto.
- Nunca adicione credenciais, chaves de API ou tokens a nenhum arquivo do repositório.
- A pasta `.godot/` e arquivos temporários nunca devem ser adicionados ao controle de versão.

## 5. Validação Automatizada Obrigatória
Antes de considerar qualquer tarefa pronta, execute os seguintes passos na linha de comando:
1. Reimportação headless e checagem de integridade:
   `godot_console --headless --path . --import`
2. Validação estática ou smoke test de cena:
   `godot_console --headless --path . --scene res://src/levels/level_01.tscn --quit-after 30`
3. Execução da suíte de testes relevante (exemplo):
   `godot_console --headless --path . --scene res://src/levels/test_coin_collection.tscn`

## 6. Definition of Done (Critérios de Aceite)
Uma tarefa só é considerada concluída pelo agente quando todos os critérios abaixo forem satisfeitos:
1. O código GDScript compila e executa sem erros ou advertências no Output do Godot.
2. A suíte de testes headless foi executada e aprovou 100% das asserções.
3. As alterações no Git estão restritas aos arquivos combinados no escopo.
4. O arquivo `SPEC.md` ou documentação do projeto foi atualizado se houver novos componentes ou nós.
5. A mensagem de commit segue o padrão convencional: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
