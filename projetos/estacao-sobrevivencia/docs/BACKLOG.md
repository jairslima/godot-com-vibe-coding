# Backlog de Desenvolvimento: Estação Sobrevivência by Jair Lima

Este documento estabelece o backlog decomposto do projeto a partir do GDD, estruturado em histórias de usuário atômicas, estimativas relativas, critérios de aceitação e priorização para o desenvolvimento do MVP e fases subsequentes.

---

## 1. Critérios de Priorização (Escala MoSCoW e Níveis P)
* **P0 (Must Have - MVP Essencial):** Requisitos inegociáveis para validar o core loop de jogabilidade. Sem qualquer um deles, o jogo não pode ser testado como produto funcional.
* **P1 (Should Have - Pós-MVP):** Funcionalidades importantes para aprofundar a estratégia, previstas para o marco seguinte.
* **P2 (Could Have - Polimento):** Melhorias estéticas e secundárias que agregam valor apenas se houver tempo hábil.
* **P3 (Won't Have - Fora de Escopo):** Recursos deliberadamente rejeitados para preservar foco e integridade arquitetural.

---

## 2. Backlog do MVP (Prioridade P0 - Foco do Capítulo 43)

### US-01: Movimentação em Primeira Pessoa do Jogador
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 3 pontos (Pequena)
* **História:** Como jogador, quero me movimentar pelo cenário tridimensional usando as teclas W, A, S e D para poder explorar a estação e fugir das criaturas.
* **Critérios de Aceitação:**
  1. O nó `Player` herda de `CharacterBody3D` e possui colisão com forma de cápsula (`CapsuleShape3D`).
  2. As ações de entrada `move_forward`, `move_backward`, `move_left` e `move_right` movem o corpo horizontalmente a uma velocidade base de 5.0 metros por segundo.
  3. A velocidade vertical é afetada pela gravidade da engine quando o jogador não está em contato com o chão.
  4. O movimento utiliza `move_and_slide()` no ciclo `_physics_process(delta)`.
  5. A câmera em primeira pessoa (`Camera3D`) está posicionada na altura dos olhos do personagem (1.5m em Y).

### US-02: Criatura Hostil Perseguidora
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 3 pontos (Pequena)
* **História:** Como designer de jogo, quero que criaturas hostis identifiquem a posição do jogador e avancem em sua direção para criar sensação contínua de ameaça física.
* **Critérios de Aceitação:**
  1. O nó `Creature` herda de `CharacterBody3D` e possui identificador no grupo `"creatures"`.
  2. A criatura localiza o nó do jogador na cena e orienta seu vetor de velocidade diretamente em direção à coordenada global do alvo.
  3. A criatura se desloca a uma velocidade constante de 3.2 metros por segundo.
  4. Uma área de contato (`Area3D` com `CollisionShape3D`) detecta a sobreposição com o corpo do jogador.
  5. Ao tocar no jogador, a criatura emite o sinal `jogador_atingido` e aciona o encerramento da partida.

### US-03: Temporizador Central e Condições de Vitória e Derrota
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 3 pontos (Pequena)
* **História:** Como jogador, quero que a partida dure exatamente 300 segundos, vencendo se sobreviver até o tempo zerar e perdendo se for capturado antes.
* **Critérios de Aceitação:**
  1. O nó `GameManager` gerencia o estado da partida com a enumeração `EstadoJogo { EM_ANDAMENTO, VITORIA, DERROTA }`.
  2. O cronômetro regressivo inicia em 300.0 segundos e drena continuamente a cada quadro de processamento.
  3. O sinal `tempo_atualizado(restante: float)` é emitido periodicamente para consumo desacoplado da interface.
  4. Se o cronômetro atinge 0.0 segundos enquanto o jogador está vivo, o estado muda para `VITORIA` e o sinal `partida_finalizada(true, "Sobreviveu!")` é emitido.
  5. Se o método `registrar_derrota(motivo: String)` for chamado por colisão com criatura, o estado muda para `DERROTA` e o sinal `partida_finalizada(false, motivo)` é emitido.
  6. Uma vez finalizada a partida, o processamento de tempo cessa e nenhum outro desfecho pode sobrepor o resultado.

### US-04: Spawner Progressivo de Criaturas
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 5 pontos (Média)
* **História:** Como designer de jogo, quero que a quantidade de criaturas aumente progressivamente ao longo dos 300 segundos para que a dificuldade escale da tranquilidade ao sufoco.
* **Critérios de Aceitação:**
  1. O nó `SpawnerProgressivo` instancia cenas dinâmicas de `Creature` em posições periféricas do mapa.
  2. A taxa de surgimento escala com o tempo decorrido, seguindo a curva do GDD (de 1 criatura inicial até um teto máximo de 16 criaturas ativas simultâneas).
  3. Antes de instanciar nova criatura, o spawner valida se a contagem no grupo `"creatures"` é estritamente menor que o limite máximo.
  4. O spawner interrompe a geração de novas entidades imediatamente após a emissão de qualquer sinal de fim de jogo.

### US-05: Interface do Usuário (HUD) Desacoplada
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 2 pontos (Pequena)
* **História:** Como jogador, quero visualizar o tempo restante no formato MM:SS e receber aviso claro em caso de vitória ou derrota.
* **Critérios de Aceitação:**
  1. O nó `HUD` herda de `CanvasLayer` e opera de forma estritamente desacoplada via sinais.
  2. Um rótulo (`%TimerLabel`) exibe o tempo formatado em minutos e segundos com zeros à esquerda (exemplo: `05:00`, `02:45`, `00:10`).
  3. Um rótulo (`%CreaturesLabel`) exibe a contagem numérica de criaturas ativas no cenário.
  4. Um painel modal ou mensagem em destaque (`%StatusLabel`) exibe o texto de Vitória em verde ou Derrota em vermelho com botão ou instrução de reinício.

### US-06: Suíte de Testes Automatizados Headless
* **Prioridade:** P0 (Must Have)
* **Estimativa:** 3 pontos (Pequena)
* **História:** Como engenheiro de software, quero executar uma suíte de asserções em modo headless no Godot 4.7.2 para comprovar a viabilidade e estabilidade mecânica do MVP antes de qualquer teste manual.
* **Critérios de Aceitação:**
  1. A cena `test_mvp_runner.tscn` instancia e valida os nós essenciais da arquitetura.
  2. Valida o tempo inicial em 300.0s e a formatação temporal correta.
  3. Simula colisão entre criatura e jogador, atestando o disparo de derrota.
  4. Simula o esgotamento do relógio, atestando o disparo de vitória.
  5. Valida o respeito ao teto populacional do spawner progressivo.
  6. Finaliza com `quit(0)` se todas as asserções passarem e `quit(1)` se houver falha.

---

## 3. Backlog de Iterações Futuras (P1 e P2 - Pós-MVP)

### US-07 (P1): Reatores Setoriais e Consumo de Bateria
* Três reatores espalhados pelo mapa perdem carga continuamente a 0.5% por segundo. Se qualquer um zerar, oxigênio acaba.

### US-08 (P1): Células de Fusão Coletáveis
* Itens espalhados pelo chão que o jogador pode carregar (máximo 1 por vez) para alimentar reatores.

### US-09 (P1): Comportas Herméticas com Consumo Elétrico
* Portas que o jogador pode abrir e fechar para bloquear a rota das criaturas, consumindo energia do setor.

### US-10 (P2): Lanterna e Sistema de Iluminação Dinâmica
* Iluminação pontual com alternância pela tecla F, afetando a visibilidade e o raio de alerta dos inimigos.

### US-11 (P2): Efeitos Sonoros e Passos Metálicos
* Síntese e reprodução de passos do jogador e zumbidos dos reatores no espaço tridimensional.
