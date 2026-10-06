# ARQUIVO: res://src/levels/test_enemy_fsm.gd
# ANEXAR AO NODE: TestEnemyFSM (Node2D)
# CENA: res://src/levels/test_enemy_fsm.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/enemies/enemy_patrol.gd, res://src/components/health_component.gd, res://src/components/state_machine/state_machine.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa suíte automatizada headless comprovando FSM por enum, sensores de borda, perseguição reativa, HealthComponent e FSM por nós.
extends Node2D

const ENEMY_PATROL_SCENE: PackedScene = preload("res://src/entities/enemies/enemy_patrol.tscn")

var frame_count: int = 0
var testes_passaram: int = 0
const TOTAL_TESTES: int = 6

var enemy_instance: EnemyPatrol = null
var mock_player: CharacterBody2D = null
var test_state_machine: StateMachine = null
var patrol_state_node: EnemyPatrolState = null
var chase_state_node: EnemyChaseState = null

func _ready() -> void:
	print("============================================================")
	print("INICIANDO TESTES AUTOMATIZADOS: INIMIGOS, FSM E COMPONENTES")
	print("============================================================")
	_montar_cenario()

func _montar_cenario() -> void:
	# 1. Instancia mock do player
	mock_player = CharacterBody2D.new()
	mock_player.name = "MockPlayer"
	mock_player.add_to_group("player")
	mock_player.global_position = Vector2(800.0, 100.0) # longe inicialmente
	add_child(mock_player)

	# 2. Instancia o inimigo de patrulha
	enemy_instance = ENEMY_PATROL_SCENE.instantiate() as EnemyPatrol
	enemy_instance.global_position = Vector2(100.0, 100.0)
	add_child(enemy_instance)

	# 3. Monta StateMachine modular por nós para validação paralela
	test_state_machine = StateMachine.new()
	test_state_machine.name = "TestStateMachine"

	patrol_state_node = EnemyPatrolState.new()
	patrol_state_node.name = "PatrolState"
	test_state_machine.add_child(patrol_state_node)

	chase_state_node = EnemyChaseState.new()
	chase_state_node.name = "ChaseState"
	test_state_machine.add_child(chase_state_node)

	test_state_machine.initial_state = patrol_state_node
	add_child(test_state_machine)

func _physics_process(_delta: float) -> void:
	frame_count += 1

	if frame_count == 2:
		_testar_inicializacao_e_patrulha()
	elif frame_count == 4:
		_testar_inversao_sensores()
	elif frame_count == 6:
		_testar_deteccao_e_perseguicao()
	elif frame_count == 8:
		_testar_health_component_e_dano()
	elif frame_count == 10:
		_testar_morte_e_desativacao()
	elif frame_count == 12:
		_testar_fsm_por_nos()
	elif frame_count == 14:
		_concluir_testes()

func _testar_inicializacao_e_patrulha() -> void:
	assert(enemy_instance.current_state == EnemyPatrol.AIState.PATROL, "Inimigo deve iniciar no estado PATROL.")
	assert(enemy_instance.velocity.x == 60.0, "Velocidade horizontal no estado inicial de patrulha deve ser 60.0.")
	testes_passaram += 1
	print("[TESTE 1/6 PASSOU] Inimigo inicializado no estado PATROL com movimentação autônoma ativa.")

func _testar_inversao_sensores() -> void:
	var direcao_anterior: int = enemy_instance.facing_direction
	enemy_instance.inverter_direcao()
	assert(enemy_instance.facing_direction == -direcao_anterior, "Inversão de direção deve alternar o sinal de facing_direction.")
	assert(enemy_instance.sprite.flip_h == true, "Sprite deve ser espelhado horizontalmente ao olhar para a esquerda.")
	assert(enemy_instance.floor_detector.position.x < 0.0, "Sensor de chão deve ser reposicionado à esquerda.")
	testes_passaram += 1
	print("[TESTE 2/6 PASSOU] Inversão de patrulha e alinhamento geométrico de sensores validados.")

func _testar_deteccao_e_perseguicao() -> void:
	# Move o mock_player para perto do inimigo (dentro do detection_radius de 160 px)
	mock_player.global_position = enemy_instance.global_position + Vector2(80.0, 0.0)
	enemy_instance._processar_patrulha(0.016)
	assert(enemy_instance.current_state == EnemyPatrol.AIState.CHASE, "Inimigo deve transitar para CHASE ao detectar jogador no raio.")
	assert(enemy_instance.target_player == mock_player, "Alvo de perseguição deve ser o nó do jogador detectado.")
	testes_passaram += 1
	print("[TESTE 3/6 PASSOU] Transição reativa de PATROL para CHASE comprovada ao detectar jogador.")

func _testar_health_component_e_dano() -> void:
	var dados := {"dano": 0, "vida": 0}

	var health: HealthComponent = enemy_instance.health_component
	health.damaged.connect(func(amt: int): dados["dano"] = amt)
	health.health_changed.connect(func(curr: int, _max_val: int): dados["vida"] = curr)

	health.take_damage(1)
	assert(dados["dano"] == 1, "Sinal damaged deve emitir a quantidade de dano aplicada.")
	assert(dados["vida"] == 1, "Sinal health_changed deve refletir a redução de vida para 1.")
	assert(enemy_instance.current_state == EnemyPatrol.AIState.HURT, "Inimigo deve transitar para HURT após receber dano.")
	testes_passaram += 1
	print("[TESTE 4/6 PASSOU] HealthComponent disparou sinais de dano e acionou estado HURT com precisão.")

func _testar_morte_e_desativacao() -> void:
	var dados_morte := {"morreu": false}
	enemy_instance.enemy_died.connect(func(): dados_morte["morreu"] = true)

	enemy_instance.health_component.take_damage(1)
	assert(enemy_instance.health_component.is_dead(), "HealthComponent deve reportar morte quando vida atinge zero.")
	assert(enemy_instance.current_state == EnemyPatrol.AIState.DEAD, "Inimigo deve transitar para o estado DEAD.")
	assert(dados_morte["morreu"], "Sinal enemy_died deve ser emitido quando a entidade for derrotada.")
	testes_passaram += 1
	print("[TESTE 5/6 PASSOU] Morte da entidade, sinal enemy_died e transição para DEAD homologados.")

func _testar_fsm_por_nos() -> void:
	assert(test_state_machine.current_state == patrol_state_node, "FSM por nós deve ativar estado inicial PatrolState.")
	test_state_machine.transition_to("ChaseState")
	assert(test_state_machine.current_state == chase_state_node, "FSM por nós deve transitar corretamente para ChaseState.")
	testes_passaram += 1
	print("[TESTE 6/6 PASSOU] FSM modular baseada em nós de estado validada com transição limpa.")

func _concluir_testes() -> void:
	assert(testes_passaram == TOTAL_TESTES, "Todos os 6 testes unitários devem ser aprovados.")
	print("------------------------------------------------------------")
	print("TODOS OS %d TESTES DE INIMIGOS, FSM E SAÚDE FORAM APROVADOS!" % TOTAL_TESTES)
	print("------------------------------------------------------------")
	get_tree().quit(0)
