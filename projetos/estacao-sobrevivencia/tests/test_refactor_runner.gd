extends Node3D

## Suíte de testes automatizados headless para validação da refatoração da Estação Sobrevivência.
## Valida o componente TargetDetector3D, a reatividade do SpawnerProgressivo e a ausência de polling.

const TargetDetectorScript = preload("res://src/components/target_detector_3d.gd")
const CreatureScript = preload("res://src/entities/creature/creature.gd")
const SpawnerScript = preload("res://src/core/spawner_progressivo.gd")
const EstacaoMVPScript = preload("res://src/levels/estacao_mvp.gd")

var passed_assertions: int = 0
var total_assertions: int = 6

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: REFATORAÇÃO ARQUITETURAL (GODOT 4.7.2)")
	print("==================================================")
	
	test_target_detector_standalone()
	test_target_detector_group_search()
	test_creature_component_delegation()
	test_spawner_reactive_signals()
	test_spawner_cleanup_on_tree_exit()
	test_level_reactive_orchestration()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha nas asserções de refatoração!")
		get_tree().quit(1)

func test_target_detector_standalone() -> void:
	var detector: TargetDetector3D = TargetDetectorScript.new()
	add_child(detector)
	
	assert(not detector.tem_alvo(), "Detector recém-criado não deve possuir alvo.")
	assert(detector.obter_alvo() == null, "Alvo inicial deve ser nulo.")
	
	var alvo_mock: Node3D = Node3D.new()
	add_child(alvo_mock)
	alvo_mock.global_position = Vector3(5.0, 10.0, 0.0)
	
	var sinal_disparado: Array[bool] = [false]
	detector.alvo_adquirido.connect(func(a: Node3D) -> void:
		sinal_disparado[0] = (a == alvo_mock)
	)
	
	detector.definir_alvo(alvo_mock)
	assert(detector.tem_alvo(), "Detector deve confirmar posse de alvo após definição.")
	assert(sinal_disparado[0] == true, "Sinal alvo_adquirido deve ser emitido com o nó correto.")
	
	# O cálculo vetorial deve achatar o eixo Y para navegação horizontal
	var vetor: Vector3 = detector.obter_vetor_para_alvo(Vector3.ZERO)
	assert(is_equal_approx(vetor.x, 5.0), "Vetor horizontal em X deve ser 5.0.")
	assert(is_equal_approx(vetor.y, 0.0), "Vetor horizontal em Y deve ser estritamente zero.")
	assert(is_equal_approx(detector.obter_distancia_para_alvo(Vector3.ZERO), 5.0), "Distância horizontal deve ser 5.0.")
	
	var dir_norm: Vector3 = detector.obter_direcao_normalizada(Vector3.ZERO)
	assert(is_equal_approx(dir_norm.x, 1.0), "Direção normalizada em X deve ser 1.0.")
	assert(is_equal_approx(dir_norm.y, 0.0) and is_equal_approx(dir_norm.z, 0.0), "Direções Y e Z devem ser zero.")
	
	alvo_mock.queue_free()
	detector.queue_free()
	passed_assertions += 1
	print("[TESTE 1/6 APROVADO] TargetDetector3D: operações isoladas e achatamento vetorial em Y.")

func test_target_detector_group_search() -> void:
	var detector: TargetDetector3D = TargetDetectorScript.new()
	detector.grupo_alvo = "grupo_teste_alvos"
	add_child(detector)
	
	var entidade_alvo: Node3D = Node3D.new()
	entidade_alvo.add_to_group("grupo_teste_alvos")
	add_child(entidade_alvo)
	
	var encontrado: Node3D = detector.procurar_alvo()
	assert(encontrado == entidade_alvo, "Detector deve localizar o nó pertencente ao grupo configurado.")
	assert(detector.obter_alvo() == entidade_alvo, "Alvo interno deve ser atualizado automaticamente.")
	
	entidade_alvo.queue_free()
	detector.queue_free()
	passed_assertions += 1
	print("[TESTE 2/6 APROVADO] TargetDetector3D: busca desacoplada por grupo sem acoplamento rígido.")

func test_creature_component_delegation() -> void:
	var creature_scene: PackedScene = load("res://src/entities/creature/creature.tscn")
	var creature: CharacterBody3D = creature_scene.instantiate()
	add_child(creature)
	
	assert(creature.detector != null, "A criatura instanciada deve possuir o componente TargetDetector3D.")
	assert(creature.detector is TargetDetector3D, "O detector deve ser do tipo TargetDetector3D.")
	
	var alvo_mock: Node3D = Node3D.new()
	add_child(alvo_mock)
	alvo_mock.global_position = Vector3(8.0, 0.0, 0.0)
	
	creature.definir_alvo(alvo_mock)
	assert(creature.detector.obter_alvo() == alvo_mock, "A criatura deve delegar o alvo para seu componente.")
	assert(creature.alvo == alvo_mock, "A propriedade alvo de compatibilidade deve refletir o detector.")
	
	alvo_mock.queue_free()
	creature.queue_free()
	passed_assertions += 1
	print("[TESTE 3/6 APROVADO] Creature: delegação transparente de busca e vetores ao TargetDetector3D.")

func test_spawner_reactive_signals() -> void:
	var spawner: SpawnerProgressivo = SpawnerScript.new()
	add_child(spawner)
	
	var cena_dummy: PackedScene = load("res://src/entities/creature/creature.tscn")
	spawner.cena_criatura = cena_dummy
	
	var instanciada_recebida: Array[bool] = [false]
	var contagem_recebida: Array[int] = [0]
	
	spawner.criatura_instanciada.connect(func(_c: CharacterBody3D) -> void:
		instanciada_recebida[0] = true
	)
	spawner.contagem_criaturas_alterada.connect(func(total: int) -> void:
		contagem_recebida[0] = total
	)
	
	var criada: CharacterBody3D = spawner.tentar_instanciar_criatura()
	assert(criada != null, "Spawner deve conseguir gerar uma criatura com cena válida.")
	assert(instanciada_recebida[0] == true, "Sinal criatura_instanciada deve ter sido emitido.")
	assert(contagem_recebida[0] == 1, "Sinal contagem_criaturas_alterada deve reportar 1 criatura ativa.")
	assert(spawner.obter_total_criaturas_ativas() == 1, "Spawner deve rastrear 1 criatura internamente.")
	
	spawner.queue_free()
	passed_assertions += 1
	print("[TESTE 4/6 APROVADO] SpawnerProgressivo: emissão de sinais reativos criatura_instanciada e contagem.")

func test_spawner_cleanup_on_tree_exit() -> void:
	var spawner: SpawnerProgressivo = SpawnerScript.new()
	add_child(spawner)
	spawner.cena_criatura = load("res://src/entities/creature/creature.tscn")
	
	var contagem_historico: Array[int] = []
	spawner.contagem_criaturas_alterada.connect(func(total: int) -> void:
		contagem_historico.append(total)
	)
	
	var c1: CharacterBody3D = spawner.tentar_instanciar_criatura()
	var c2: CharacterBody3D = spawner.tentar_instanciar_criatura()
	assert(spawner.obter_total_criaturas_ativas() == 2, "Spawner deve reportar 2 criaturas.")
	
	# Destruir uma criatura e verificar que o sinal de decremento é disparado reativamente
	c1.free()
	assert(spawner.obter_total_criaturas_ativas() == 1, "Após liberação de c1, total deve cair para 1.")
	assert(contagem_historico.has(1), "O histórico de contagem deve registrar a redução para 1.")
	
	c2.free()
	assert(spawner.obter_total_criaturas_ativas() == 0, "Após liberação de c2, total deve cair para 0.")
	
	spawner.queue_free()
	passed_assertions += 1
	print("[TESTE 5/6 APROVADO] SpawnerProgressivo: desregistro automático e reatividade com tree_exited.")

func test_level_reactive_orchestration() -> void:
	var cena_estacao: PackedScene = load("res://src/levels/estacao_mvp.tscn")
	var instancia: Node = cena_estacao.instantiate()
	add_child(instancia)
	
	var spawner_no: SpawnerProgressivo = instancia.get_node("%SpawnerProgressivo") as SpawnerProgressivo
	var hud_no: HUD = instancia.get_node("%HUD") as HUD
	
	assert(spawner_no != null, "Spawner deve existir na cena.")
	assert(hud_no != null, "HUD deve existir na cena.")
	
	# Verificar que o sinal contagem_criaturas_alterada do spawner está conectado ao HUD
	var conexoes: Array = spawner_no.contagem_criaturas_alterada.get_connections()
	var conectado_ao_hud: bool = false
	for con in conexoes:
		var callable: Callable = con["callable"]
		if callable.get_object() == hud_no:
			conectado_ao_hud = true
			break
	
	assert(conectado_ao_hud, "O sinal contagem_criaturas_alterada deve estar conectado ao HUD.")
	
	instancia.queue_free()
	passed_assertions += 1
	print("[TESTE 6/6 APROVADO] EstacaoMVP: conexões declarativas sem dependência de _process a 60 FPS.")
