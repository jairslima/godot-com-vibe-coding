class_name DroneThreat
extends CharacterBody3D

## Inimigo autônomo de patrulha e perseguição para a Estação 3D (marcos 05-navigation e 06-threat).
## Implementa máquina de estados, navegação com NavigationAgent3D e proteção anti-enrosco.

enum State {
	PATROL,
	CHASE,
	SEARCH,
	STUCK_RECOVERY
}

signal state_changed(new_state: State)
signal player_detected(player: Node3D)
signal player_lost()

@export_group("Velocidade")
@export var patrol_speed: float = 2.5
@export var chase_speed: float = 4.2
@export var acceleration: float = 10.0

@export_group("IA e Percepção")
@export var search_duration: float = 3.0
@export var stuck_check_interval: float = 1.5
@export var stuck_distance_threshold: float = 0.08
@export var patrol_waypoints: Array[Vector3] = []

@onready var nav_agent: NavigationAgent3D = %NavAgent
@onready var vision_area: Area3D = %VisionArea
@onready var sight_ray: RayCast3D = %SightRay
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D

var current_state: State = State.PATROL
var current_waypoint_index: int = 0
var target_player: CharacterBody3D = null
var last_known_player_position: Vector3 = Vector3.ZERO
var search_timer: float = 0.0

# Watchdog anti-enrosco
var last_checked_position: Vector3 = Vector3.ZERO
var stuck_timer: float = 0.0

func _ready() -> void:
	# Camada 3 (threats = 4), colide com mundo (1) e jogador (2)
	collision_layer = 4
	collision_mask = 3
	
	last_checked_position = global_position
	
	if vision_area:
		vision_area.body_entered.connect(_on_vision_body_entered)
		vision_area.body_exited.connect(_on_vision_body_exited)
	
	# Aguarda sincronização inicial do mapa de navegação no primeiro physics frame
	call_deferred("_setup_initial_navigation")

func _setup_initial_navigation() -> void:
	await get_tree().physics_frame
	if patrol_waypoints.is_empty():
		# Se não houver waypoints definidos, patrulha ao redor da posição inicial
		patrol_waypoints.append(global_position)
		patrol_waypoints.append(global_position + Vector3(4.0, 0.0, 0.0))
		patrol_waypoints.append(global_position + Vector3(0.0, 0.0, -8.0))
	
	set_patrol_destination(current_waypoint_index)

func _physics_process(delta: float) -> void:
	check_stuck_watchdog(delta)
	
	match current_state:
		State.PATROL:
			process_patrol_state(delta)
		State.CHASE:
			process_chase_state(delta)
		State.SEARCH:
			process_search_state(delta)
		State.STUCK_RECOVERY:
			process_stuck_recovery_state(delta)
	
	move_and_slide()

func process_patrol_state(delta: float) -> void:
	if target_player and has_line_of_sight_to(target_player):
		change_state(State.CHASE)
		return
	
	if nav_agent.is_navigation_finished():
		advance_next_patrol_point()
		return
	
	move_along_nav_path(patrol_speed, delta)

func process_chase_state(delta: float) -> void:
	if not target_player:
		change_state(State.SEARCH)
		return
	
	if has_line_of_sight_to(target_player):
		last_known_player_position = target_player.global_position
		nav_agent.target_position = last_known_player_position
	else:
		# Jogador quebrou a linha de visão
		change_state(State.SEARCH)
		return
	
	move_along_nav_path(chase_speed, delta)

func process_search_state(delta: float) -> void:
	if target_player and has_line_of_sight_to(target_player):
		change_state(State.CHASE)
		return
	
	if not nav_agent.is_navigation_finished():
		move_along_nav_path(patrol_speed, delta)
	else:
		# Aguarda no local da última visão
		search_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		
		if search_timer >= search_duration:
			search_timer = 0.0
			player_lost.emit()
			change_state(State.PATROL)
			set_patrol_destination(current_waypoint_index)

func process_stuck_recovery_state(delta: float) -> void:
	# Tenta desbloquear alternando para o próximo ponto de patrulha
	advance_next_patrol_point()
	change_state(State.PATROL)

func move_along_nav_path(target_speed: float, delta: float) -> void:
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var current_pos: Vector3 = global_position
	
	# Direção horizontal ignorando inclinação vertical para evitar capotagem
	var dir: Vector3 = (next_path_pos - current_pos)
	dir.y = 0.0
	
	if dir.length_squared() > 0.001:
		dir = dir.normalized()
		velocity.x = move_toward(velocity.x, dir.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, dir.z * target_speed, acceleration * delta)
		
		# Orienta a malha na direção do movimento
		var target_yaw: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 5.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)

func set_patrol_destination(index: int) -> void:
	if patrol_waypoints.is_empty():
		return
	current_waypoint_index = index % patrol_waypoints.size()
	nav_agent.target_position = patrol_waypoints[current_waypoint_index]

func advance_next_patrol_point() -> void:
	if patrol_waypoints.is_empty():
		return
	current_waypoint_index = (current_waypoint_index + 1) % patrol_waypoints.size()
	set_patrol_destination(current_waypoint_index)

func has_line_of_sight_to(body: Node3D) -> bool:
	if not sight_ray or not body:
		return false
	
	# Configura o raio para mirar no centro do alvo
	var origin: Vector3 = global_position + Vector3(0, 1.0, 0)
	var target: Vector3 = body.global_position + Vector3(0, 1.0, 0)
	sight_ray.global_position = origin
	sight_ray.target_position = sight_ray.to_local(target)
	sight_ray.force_raycast_update()
	
	# Se colidir com algo que não seja o próprio jogador, a visão está obstruída por paredes (layer 1)
	if sight_ray.is_colliding():
		var col: Object = sight_ray.get_collider()
		return (col == body)
	
	return true

func check_stuck_watchdog(delta: float) -> void:
	stuck_timer += delta
	if stuck_timer >= stuck_check_interval:
		stuck_timer = 0.0
		var dist_moved: float = global_position.distance_to(last_checked_position)
		last_checked_position = global_position
		
		# Se deveria estar se movendo mas deslocou menos que o limiar
		if (current_state == State.PATROL or current_state == State.CHASE) and dist_moved < stuck_distance_threshold:
			if not nav_agent.is_navigation_finished():
				change_state(State.STUCK_RECOVERY)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)
	
	# Atualiza cor visual de alerta conforme o estado
	update_state_visual(new_state)

func update_state_visual(state: State) -> void:
	if not mesh_instance or not mesh_instance.material_override:
		return
	var mat: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
	if not mat:
		return
	
	match state:
		State.PATROL:
			mat.emission = Color(0.2, 0.6, 1.0, 1.0) # Azul patrulha
		State.CHASE:
			mat.emission = Color(1.0, 0.1, 0.1, 1.0) # Vermelho alerta
		State.SEARCH:
			mat.emission = Color(1.0, 0.7, 0.1, 1.0) # Amarelo busca
		State.STUCK_RECOVERY:
			mat.emission = Color(0.8, 0.2, 0.8, 1.0) # Magenta recuperação

func _on_vision_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.collision_layer == 2:
		target_player = body as CharacterBody3D
		if has_line_of_sight_to(target_player):
			player_detected.emit(target_player)
			change_state(State.CHASE)

func _on_vision_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null
		if current_state == State.CHASE:
			change_state(State.SEARCH)
