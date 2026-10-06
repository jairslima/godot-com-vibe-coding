class_name TestInteractionAndNpcs3D
extends Node3D

## Suíte de testes automatizados headless para homologação dos marcos do Capítulo 34:
## - station3d-02-interaction (RayCast3D, Interactable3D, PowerCore)
## - station3d-04-objectives (ObjectiveManager, fluxo de missões)
## - station3d-05-navigation (NavigationRegion3D, parâmetros de malha)
## - station3d-06-threat (DroneThreat, FSM, Line of Sight, Watchdog anti-enrosco)
## - station3d-07-hud (HUD3D, retículo, prompts contextuais e objetivos)

var passed_assertions: int = 0
var total_assertions: int = 9

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: INTERAÇÃO, OBJETIVOS, NAVEGAÇÃO E NPCS 3D")
	print("==================================================")
	
	test_raycast_interaction_setup()
	test_interactable_3d_protocol()
	test_power_core_collection()
	test_objective_manager_progression()
	test_navigation_mesh_configuration()
	test_drone_threat_setup_and_fsm()
	test_drone_vision_and_los()
	test_drone_stuck_watchdog()
	test_hud_3d_integration()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha na suíte de testes de física, interação e NPCs 3D!")
		get_tree().quit(1)

func test_raycast_interaction_setup() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	assert(player_scene != null, "A cena player.tscn deve existir.")
	
	var player_inst: Node = player_scene.instantiate()
	var ray: RayCast3D = player_inst.get_node_or_null("Head/Camera3D/InteractionRayCast") as RayCast3D
	assert(ray != null, "InteractionRayCast deve ser filho direto de Camera3D sob Head.")
	assert(ray.collision_mask == 8, "InteractionRayCast deve consultar a camada 4 (interactables, valor binário 8).")
	assert(ray.target_position.z < 0.0, "O raio deve apontar para frente no eixo -Z tridimensional.")
	assert(ray.collide_with_areas == true, "InteractionRayCast deve detectar nós Area3D.")
	
	player_inst.free()
	passed_assertions += 1
	print("[TESTE 1/9 APROVADO] Configuração do RayCast3D de interação em primeira pessoa.")

func test_interactable_3d_protocol() -> void:
	var interactable := Interactable3D.new()
	add_child(interactable)
	
	assert(interactable.collision_layer == 8, "Interactable3D deve se registrar na camada física 4 (8).")
	assert(interactable.get_prompt() == "Pressione [E] para interagir", "Prompt padrão do interactable deve ser válido.")
	
	var received_events: Array[Node3D] = []
	interactable.interacted.connect(func(p: Node3D) -> void: received_events.append(p))
	
	var dummy_player := Node3D.new()
	interactable.interact(dummy_player)
	assert(received_events.size() == 1, "O método interact() deve disparar o sinal interacted.")
	
	dummy_player.free()
	interactable.free()
	passed_assertions += 1
	print("[TESTE 2/9 APROVADO] Protocolo e sinalização da classe base Interactable3D.")

func test_power_core_collection() -> void:
	var core_scene: PackedScene = load("res://src/props/power_core.tscn")
	assert(core_scene != null, "A cena power_core.tscn deve existir.")
	
	var core_inst: PowerCore = core_scene.instantiate() as PowerCore
	add_child(core_inst)
	
	var interactable_node: Interactable3D = core_inst.get_node_or_null("Interactable") as Interactable3D
	assert(interactable_node != null, "PowerCore deve possuir um filho Interactable3D.")
	
	var collected_events: Array[PowerCore] = []
	core_inst.collected.connect(func(c: PowerCore) -> void: collected_events.append(c))
	
	core_inst._on_interacted(null)
	assert(core_inst.is_collected == true, "PowerCore deve marcar is_collected = true ao interagir.")
	assert(collected_events.size() == 1, "PowerCore deve emitir o sinal collected ao ser coletado.")
	
	passed_assertions += 1
	print("[TESTE 3/9 APROVADO] Coleta e sinalização do prop PowerCore.")

func test_objective_manager_progression() -> void:
	var obj_mgr := ObjectiveManager.new()
	obj_mgr.required_cores = 3
	add_child(obj_mgr)
	
	assert(obj_mgr.collected_cores == 0, "Contagem inicial de núcleos deve ser zero.")
	assert(obj_mgr.can_restore_power() == false, "Não deve permitir restaurar energia com 0 núcleos.")
	
	obj_mgr.register_core_collected()
	obj_mgr.register_core_collected()
	assert(obj_mgr.collected_cores == 2, "Contagem de núcleos deve ser 2 após duas coletas.")
	assert(obj_mgr.can_restore_power() == false, "Não deve permitir restaurar energia com menos de 3 núcleos.")
	
	obj_mgr.register_core_collected()
	assert(obj_mgr.collected_cores == 3, "Contagem de núcleos deve atingir o requisito (3).")
	assert(obj_mgr.can_restore_power() == true, "Deve permitir restaurar energia com 3 núcleos.")
	
	var power_events: Array[bool] = []
	obj_mgr.power_restored.connect(func() -> void: power_events.append(true))
	var restore_result: bool = obj_mgr.restore_power()
	
	assert(restore_result == true, "restore_power() deve retornar true com requisitos satisfeitos.")
	assert(power_events.size() == 1, "restore_power() deve emitir o sinal power_restored.")
	assert(obj_mgr.is_power_active == true, "is_power_active deve ser true após restauração.")
	
	obj_mgr.free()
	passed_assertions += 1
	print("[TESTE 4/9 APROVADO] Ciclo de progressão e requisitos do ObjectiveManager.")

func test_navigation_mesh_configuration() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	assert(hub_scene != null, "A cena station_hub.tscn deve existir.")
	
	var hub_inst: Node = hub_scene.instantiate()
	var nav_region: NavigationRegion3D = hub_inst.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	assert(nav_region != null, "A cena station_hub deve conter um nó NavigationRegion3D.")
	
	var nav_mesh: NavigationMesh = nav_region.navigation_mesh
	assert(nav_mesh != null, "NavigationRegion3D deve possuir um recurso NavigationMesh atribuído.")
	assert(is_equal_approx(nav_mesh.agent_radius, 0.5), "agent_radius deve ser calibrado para 0.5 metros.")
	assert(is_equal_approx(nav_mesh.agent_height, 1.8), "agent_height deve corresponder à altura métrica de 1.8m.")
	assert(is_equal_approx(nav_mesh.agent_max_slope, 45.0), "agent_max_slope deve permitir rampas até 45 graus.")
	
	hub_inst.free()
	passed_assertions += 1
	print("[TESTE 5/9 APROVADO] Configuração de NavigationRegion3D e propriedades de NavigationMesh.")

func test_drone_threat_setup_and_fsm() -> void:
	var drone_scene: PackedScene = load("res://src/entities/drone/drone_threat.tscn")
	assert(drone_scene != null, "A cena drone_threat.tscn deve existir.")
	
	var drone: DroneThreat = drone_scene.instantiate() as DroneThreat
	add_child(drone)
	
	assert(drone is CharacterBody3D, "DroneThreat deve ser derivado de CharacterBody3D.")
	assert(drone.collision_layer == 4, "DroneThreat deve pertencer à camada 3 (threats, valor binário 4).")
	assert(drone.collision_mask == 3, "DroneThreat deve colidir com camada 1 (world) e camada 2 (player).")
	
	var nav_agent: NavigationAgent3D = drone.get_node_or_null("NavAgent") as NavigationAgent3D
	assert(nav_agent != null, "DroneThreat deve possuir um nó NavigationAgent3D (%NavAgent).")
	assert(is_equal_approx(nav_agent.path_desired_distance, 0.8), "path_desired_distance deve ser 0.8m.")
	assert(is_equal_approx(nav_agent.target_desired_distance, 1.2), "target_desired_distance deve ser 1.2m.")
	
	assert(drone.current_state == DroneThreat.State.PATROL, "Estado inicial do drone deve ser PATROL.")
	
	var recorded_states: Array[DroneThreat.State] = []
	drone.state_changed.connect(func(s: DroneThreat.State) -> void: recorded_states.append(s))
	
	drone.change_state(DroneThreat.State.CHASE)
	assert(drone.current_state == DroneThreat.State.CHASE, "Drone deve transitar para o estado CHASE.")
	assert(recorded_states.has(DroneThreat.State.CHASE), "Transição de estado deve emitir state_changed.")
	
	drone.change_state(DroneThreat.State.SEARCH)
	assert(drone.current_state == DroneThreat.State.SEARCH, "Drone deve transitar para SEARCH.")
	
	drone.change_state(DroneThreat.State.STUCK_RECOVERY)
	assert(drone.current_state == DroneThreat.State.STUCK_RECOVERY, "Drone deve transitar para STUCK_RECOVERY.")
	
	drone.free()
	passed_assertions += 1
	print("[TESTE 6/9 APROVADO] Estrutura do DroneThreat, nós de física e máquina de estados finitos (FSM).")

func test_drone_vision_and_los() -> void:
	var drone_scene: PackedScene = load("res://src/entities/drone/drone_threat.tscn")
	var drone: DroneThreat = drone_scene.instantiate() as DroneThreat
	add_child(drone)
	
	var vision_area: Area3D = drone.get_node_or_null("VisionArea") as Area3D
	assert(vision_area != null, "DroneThreat deve possuir sensor esférico VisionArea.")
	assert(vision_area.collision_mask == 2, "VisionArea deve monitorar a camada 2 (player).")
	
	var sight_ray: RayCast3D = drone.get_node_or_null("SightRay") as RayCast3D
	assert(sight_ray != null, "DroneThreat deve possuir nó SightRay para checagem de oclusão de visão.")
	assert(sight_ray.collision_mask == 3, "SightRay deve testar obstáculos contra mundo (1) e jogador (2).")
	
	drone.free()
	passed_assertions += 1
	print("[TESTE 7/9 APROVADO] Sensores de visão esférica e raio de linha de visão (LoS).")

func test_drone_stuck_watchdog() -> void:
	var drone_scene: PackedScene = load("res://src/entities/drone/drone_threat.tscn")
	var drone: DroneThreat = drone_scene.instantiate() as DroneThreat
	add_child(drone)
	
	drone.current_state = DroneThreat.State.PATROL
	drone.global_position = Vector3(10.0, 0.0, 10.0)
	drone.last_checked_position = Vector3(10.0, 0.0, 10.0)
	
	# Força destino distante para que is_navigation_finished() seja falso
	drone.nav_agent.target_position = Vector3(50.0, 0.0, 50.0)
	
	# Desloca menos que o limiar de 0.08m
	drone.global_position = Vector3(10.01, 0.0, 10.01)
	
	# Dispara o intervalo de verificação (stuck_check_interval = 1.5s)
	drone.check_stuck_watchdog(1.6)
	assert(drone.current_state == DroneThreat.State.STUCK_RECOVERY, "Watchdog anti-enrosco deve ativar STUCK_RECOVERY quando deslocamento < limiar.")
	
	drone.free()
	passed_assertions += 1
	print("[TESTE 8/9 APROVADO] Watchdog de monitoramento anti-enrosco do NPC.")

func test_hud_3d_integration() -> void:
	var hud_scene: PackedScene = load("res://src/ui/hud_3d.tscn")
	assert(hud_scene != null, "A cena hud_3d.tscn deve existir.")
	
	var hud: HUD3D = hud_scene.instantiate() as HUD3D
	add_child(hud)
	
	var prompt_lbl: Label = hud.get_node_or_null("%PromptLabel") as Label
	assert(prompt_lbl != null, "HUD deve conter nó %PromptLabel.")
	assert(prompt_lbl.visible == false, "Prompt deve iniciar oculto.")
	
	hud.show_prompt("Pressione [E] para coletar")
	assert(prompt_lbl.visible == true, "show_prompt deve tornar o label visível.")
	assert(prompt_lbl.text == "Pressione [E] para coletar", "show_prompt deve definir o texto correto.")
	
	hud.hide_prompt()
	assert(prompt_lbl.visible == false, "hide_prompt deve ocultar o label.")
	
	var obj_lbl: Label = hud.get_node_or_null("%ObjectiveLabel") as Label
	assert(obj_lbl != null, "HUD deve conter nó %ObjectiveLabel.")
	hud.update_objectives(2, 3)
	assert(obj_lbl.text.contains("2 / 3"), "update_objectives deve formatar a contagem atualizada no label.")
	
	hud.free()
	passed_assertions += 1
	print("[TESTE 9/9 APROVADO] Interface HUD 3D: mira central, prompts contextuais e objetivos.")
