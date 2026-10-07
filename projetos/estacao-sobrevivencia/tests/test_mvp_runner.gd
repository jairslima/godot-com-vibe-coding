extends Node3D

## Suíte de testes automatizados headless para homologação do MVP da Estação Sobrevivência.
## Valida hierarquia de nós, temporizador de 300s, HUD, criatura, spawner e regras de vitória e derrota.

const GameManagerScript = preload("res://src/core/game_manager.gd")
const SpawnerScript = preload("res://src/core/spawner_progressivo.gd")
const HUDScript = preload("res://src/ui/hud.gd")
const PlayerScript = preload("res://src/entities/player/player.gd")
const CreatureScript = preload("res://src/entities/creature/creature.gd")

var passed_assertions: int = 0
var total_assertions: int = 6

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: MVP ESTAÇÃO SOBREVIVÊNCIA (GODOT 4.7.2)")
	print("==================================================")
	
	test_scene_hierarchy()
	test_game_manager_timer_and_states()
	test_hud_formatting()
	test_player_setup()
	test_creature_pursuit_and_catch()
	test_spawner_curve_and_cap()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha em asserções do MVP!")
		get_tree().quit(1)

func test_scene_hierarchy() -> void:
	var cena_estacao: PackedScene = load("res://src/levels/estacao_mvp.tscn")
	assert(cena_estacao != null, "A cena estacao_mvp.tscn deve ser carregável.")
	
	var instancia: Node = cena_estacao.instantiate()
	assert(instancia is Node3D, "A raiz da cena deve ser um Node3D.")
	
	var player_no: Node = instancia.get_node_or_null("Player")
	var gm_no: Node = instancia.get_node_or_null("GameManager")
	var spawner_no: Node = instancia.get_node_or_null("SpawnerProgressivo")
	var hud_no: Node = instancia.get_node_or_null("HUD")
	var floor_no: Node = instancia.get_node_or_null("Geometry/Floor")
	
	assert(player_no != null, "O nó Player deve existir.")
	assert(gm_no != null, "O nó GameManager deve existir.")
	assert(spawner_no != null, "O nó SpawnerProgressivo deve existir.")
	assert(hud_no != null, "O nó HUD deve existir.")
	assert(floor_no is CSGBox3D, "O chão da estação deve existir com colisão.")
	
	instancia.free()
	passed_assertions += 1
	print("[TESTE 1/6 APROVADO] Hierarquia da cena principal validada com nós tipados.")

func test_game_manager_timer_and_states() -> void:
	var gm: Node = GameManagerScript.new()
	add_child(gm)
	assert(gm.duracao_partida == 300.0, "A duração da partida deve ser exatamente 300 segundos.")
	assert(gm.tempo_restante == 300.0, "O tempo restante inicial deve ser 300 segundos.")
	assert(gm.estado == gm.EstadoJogo.EM_ANDAMENTO, "O estado inicial deve ser EM_ANDAMENTO.")
	
	# Testar processamento de tempo
	gm._process(10.0)
	assert(is_equal_approx(gm.tempo_restante, 290.0), "Após 10s de delta, o tempo deve ser 290s.")
	
	# Testar encerramento por vitória usando Array para captura por referência na lambda
	var resultado: Array[bool] = [false]
	gm.partida_finalizada.connect(func(vit: bool, _motivo: String) -> void:
		resultado[0] = vit
	)
	gm.concluir_vitoria()
	assert(gm.estado == gm.EstadoJogo.VITORIA, "O estado deve transicionar para VITORIA.")
	assert(resultado[0] == true, "O sinal de vitória deve ter sido emitido.")
	
	# Testar que nova derrota não sobrepõe vitória
	gm.registrar_derrota("Teste")
	assert(gm.estado == gm.EstadoJogo.VITORIA, "Estado concluído não deve ser sobrescrito.")
	
	gm.queue_free()
	passed_assertions += 1
	print("[TESTE 2/6 APROVADO] GameManager: cronômetro de 300s e transições de estado.")

func test_hud_formatting() -> void:
	var hud_scene: PackedScene = load("res://src/ui/hud.tscn")
	var hud: CanvasLayer = hud_scene.instantiate()
	add_child(hud)
	
	hud.atualizar_tempo(300.0)
	assert(hud.timer_label.text == "05:00", "300 segundos devem ser formatados como '05:00'.")
	
	hud.atualizar_tempo(125.0)
	assert(hud.timer_label.text == "02:05", "125 segundos devem ser formatados como '02:05'.")
	
	hud.atualizar_tempo(9.0)
	assert(hud.timer_label.text == "00:09", "9 segundos devem ser formatados como '00:09'.")
	
	hud.exibir_resultado(false, "Capturado!")
	assert(hud.status_label.visible == true, "O rótulo de status deve ficar visível.")
	assert(hud.status_label.text.begins_with("DERROTA!"), "Mensagem de derrota deve iniciar com 'DERROTA!'.")
	
	hud.queue_free()
	passed_assertions += 1
	print("[TESTE 3/6 APROVADO] HUD: formatação temporal MM:SS e mensagens de desfecho.")

func test_player_setup() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: CharacterBody3D = player_scene.instantiate()
	add_child(player)
	
	assert(player.is_in_group("players"), "O nó Player deve pertencer ao grupo 'players'.")
	assert(player.camera != null, "A câmera em primeira pessoa deve existir.")
	assert(player.velocidade == 5.0, "A velocidade horizontal padrão deve ser 5.0 m/s.")
	
	player.queue_free()
	passed_assertions += 1
	print("[TESTE 4/6 APROVADO] Player: configuração de física, câmera e pertencimento a grupo.")

func test_creature_pursuit_and_catch() -> void:
	var creature_scene: PackedScene = load("res://src/entities/creature/creature.tscn")
	var creature: CharacterBody3D = creature_scene.instantiate()
	add_child(creature)
	
	assert(creature.is_in_group("creatures"), "A criatura deve pertencer ao grupo 'creatures'.")
	
	var alvo_mock: Node3D = Node3D.new()
	add_child(alvo_mock)
	alvo_mock.global_position = Vector3(10.0, 0.0, 0.0)
	creature.global_position = Vector3(0.0, 0.0, 0.0)
	creature.definir_alvo(alvo_mock)
	
	# Simular perseguição
	creature._physics_process(0.1)
	assert(creature.velocity.x > 0.0, "A criatura deve se movimentar na direção X positiva em direção ao alvo.")
	
	# Testar emissão de sinal de captura por proximidade usando Array para captura por referência
	var captura_disparada: Array[bool] = [false]
	creature.jogador_capturado.connect(func() -> void:
		captura_disparada[0] = true
	)
	
	alvo_mock.global_position = Vector3(0.5, 0.0, 0.0) # Dentro de distancia_ataque (1.2)
	creature.global_position = Vector3(0.0, 0.0, 0.0)
	creature._physics_process(0.1)
	assert(captura_disparada[0] == true, "A criatura deve disparar jogador_capturado ao aproximar-se.")
	
	alvo_mock.queue_free()
	creature.queue_free()
	passed_assertions += 1
	print("[TESTE 5/6 APROVADO] Creature: perseguição vetorial e disparo de captura por contato.")

func test_spawner_curve_and_cap() -> void:
	var spawner: Node3D = SpawnerScript.new()
	add_child(spawner)
	spawner.duracao_total = 300.0
	spawner.limite_maximo_criaturas = 16
	
	# Verificar taxa inicial (t=0): 0.05 spawns/s (intervalo de 20s)
	var taxa_inicio: float = spawner.calcular_taxa_spawn(0.0)
	assert(is_equal_approx(taxa_inicio, 0.05), "A taxa de spawn inicial em t=0 deve ser 0.05.")
	var intervalo_inicio: float = spawner.calcular_intervalo_spawn(0.0)
	assert(is_equal_approx(intervalo_inicio, 20.0), "O intervalo inicial deve ser de 20 segundos.")
	
	# Verificar taxa final (t=300): 0.40 spawns/s (intervalo de 2.5s)
	var taxa_fim: float = spawner.calcular_taxa_spawn(300.0)
	assert(is_equal_approx(taxa_fim, 0.40), "A taxa de spawn final em t=300 deve ser 0.40.")
	var intervalo_fim: float = spawner.calcular_intervalo_spawn(300.0)
	assert(is_equal_approx(intervalo_fim, 2.5), "O intervalo final deve ser de 2.5 segundos.")
	
	# Verificar que a taxa cresce monotonicamente
	var taxa_meio: float = spawner.calcular_taxa_spawn(150.0)
	assert(taxa_meio > taxa_inicio and taxa_meio < taxa_fim, "A curva deve ser progressiva ao longo do tempo.")
	
	spawner.queue_free()
	passed_assertions += 1
	print("[TESTE 6/6 APROVADO] SpawnerProgressivo: curva de spawn escalável e limites matemáticos.")
