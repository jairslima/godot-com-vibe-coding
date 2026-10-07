# Arquitetura Técnica: Estação Sobrevivência (Pós-Refatoração)

## Visão Geral

Este documento descreve a topologia de nós, os contratos de comunicação e a arquitetura de componentes do projeto `estacao-sobrevivencia` no Godot 4.7.2 Stable após a refatoração do Mínimo Produto Viável (MVP).

O objetivo central desta arquitetura é assegurar baixo acoplamento, alta coesão, reatividade orientada a eventos e isolamento estrito entre física espacial, regras de negócio e interface com o usuário.

---

## Princípio Fundamental: Call Down, Signal Up

A árvore de nós segue com rigor a convenção oficial do Godot:
1. **Chamadas descendentes (Call Down):** Nós superiores invocam métodos em nós subordinados. O orquestrador de nível `EstacaoMVP` conecta sinais e aciona métodos públicos do `GameManager` e do `SpawnerProgressivo`.
2. **Sinais ascendentes (Signal Up):** Nós folha e subsistemas periféricos nunca buscam dependências na raiz ou em nós irmãos via caminhos rígidos (`get_parent()` ou `get_node()`). Toda alteração de estado é propagada por sinais tipados.

---

## Mapa de Subsistemas e Componentes

### 1. Entidades Físicas

* **Player (`res://src/entities/player/player.gd`):**
  * Tipo: `CharacterBody3D`
  * Grupo: `"players"`
  * Responsabilidade: Movimentação horizontal em primeira pessoa orientada pela câmera, desaceleração com atrito (`move_toward`) e aplicação de gravidade vertical.
  * Sinais: Não se acopla ao HUD nem aos inimigos.

* **TargetDetector3D (`res://src/components/target_detector_3d.gd`):**
  * Tipo: `Node3D`
  * Responsabilidade: Sensor espacial autônomo. Localiza alvos através de grupos configuráveis (padrão: `"players"`), mantém a referência do alvo em memória e calcula distâncias e vetores direcionais normalizados no plano horizontal ($Y = 0$).
  * Sinais:
    * `alvo_adquirido(alvo: Node3D)`
    * `alvo_perdido()`

* **Creature (`res://src/entities/creature/creature.gd`):**
  * Tipo: `CharacterBody3D`
  * Grupo: `"creatures"`
  * Composição: Instancia internamente o componente `%TargetDetector3D`.
  * Responsabilidade: Locomoção física em direção ao alvo indicado pelo detector e emissão de captura ao entrar no raio de ataque.
  * Sinais:
    * `jogador_capturado()`

---

### 2. Núcleo de Partida e Geração Reativa

* **GameManager (`res://src/core/game_manager.gd`):**
  * Tipo: `Node`
  * Responsabilidade: Máquina de estados da partida (`EM_ANDAMENTO`, `VITORIA`, `DERROTA`) e cronômetro decrescente de trezentos segundos (5 minutos).
  * Sinais:
    * `tempo_atualizado(tempo_restante: float)`
    * `partida_finalizada(vitoria: bool, motivo: String)`

* **SpawnerProgressivo (`res://src/core/spawner_progressivo.gd`):**
  * Tipo: `Node3D`
  * Responsabilidade: Instanciação escalonada de criaturas com curva quadrática e limite rígido de 16 entidades ativas simultâneas.
  * Arquitetura Reativa: Monitora o sinal `tree_exited` de cada criatura instanciada para decrementar contagens sem necessidade de polling por frame.
  * Sinais:
    * `criatura_instanciada(criatura: CharacterBody3D)`
    * `contagem_criaturas_alterada(total: int)`

---

### 3. Interface e Orquestração

* **HUD (`res://src/ui/hud.gd`):**
  * Tipo: `CanvasLayer`
  * Responsabilidade: Exibição do cronômetro no formato `MM:SS`, contagem de ameaças ativas em tela e banners de desfecho.
  * Arquitetura: Totalmente passivo, atualizado exclusivamente por Callables conectados a sinais externos.

* **EstacaoMVP (`res://src/levels/estacao_mvp.gd`):**
  * Tipo: `Node3D`
  * Responsabilidade: Conector declarativo no `_ready()`. Liga os sinais do `GameManager` e do `SpawnerProgressivo` aos métodos do `HUD` e trata o evento `jogador_capturado` das criaturas.
  * Otimização: Não implementa o método `_process()`, poupando ciclos de CPU da árvore de cena.

---

## Diagrama de Fluxo de Dados e Sinais

```text
+---------------------+           tempo_atualizado            +-------------+
|     GameManager     | ------------------------------------> |     HUD     |
| (Cronômetro e FSM)  | ----+                                 |  (Display)  |
+---------------------+     |                                 +-------------+
                            | partida_finalizada                     ^
                            v                                        |
+---------------------+  _on_partida_finalizada                      |
|                     | ----------------------+                      |
|     EstacaoMVP      |                       |                      |
|    (Orquestrador)   |                       v                      |
|                     |           spawner.desativar()                |
+---------------------+                                              |
      ^             ^                                                |
      |             +-------- contagem_criaturas_alterada -----------+
      |                       (sem polling em _process)              |
      |                                                              |
      | criatura_instanciada                                         |
      |                                                              |
+---------------------+                                              |
|  SpawnerProgressivo | ---------------------------------------------+
| (Gestão de Limite)  |
+---------------------+
      | instancia
      v
+---------------------+      delega busca e vetores      +--------------------+
|      Creature       | -------------------------------> |  TargetDetector3D  |
|  (Física e Ataque)  |                                  |  (Sensor Espacial) |
+---------------------+                                  +--------------------+
      |
      | jogador_capturado
      v
_on_jogador_capturado -> game_manager.registrar_derrota()
```

---

## Validação e Garantia de Qualidade

A integridade desta arquitetura é assegurada por três suítes de teste automatizadas executadas via CLI headless:
1. `tests/test_mvp_runner.tscn`: 6 asserções cobrindo regras de negócio, temporizador, formatação de HUD e regressão de gameplay.
2. `tests/test_refactor_runner.tscn`: 6 asserções validando isolamento do `TargetDetector3D`, sinais reativos do spawner e desregistro automático.
3. `tests/test_license_manager.tscn`: 6 asserções auditando o Asset Ledger e licenças de ativos.
