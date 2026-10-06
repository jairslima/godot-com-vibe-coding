class_name TestPlayerAndWorld3D
extends Node3D

## Suíte de testes automatizados headless para homologação dos marcos:
## - station3d-01-player-camera (CharacterBody3D, câmera em primeira pessoa, mouse look e gravidade)
## - station3d-03-environment (Ambiente modular da estação com CSG e colisão sólida)

var passed_assertions: int = 0
var total_assertions: int = 7

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: PLAYER, CÂMERA E MUNDO 3D")
	print("==================================================")
	
	test_player_node_hierarchy()
	test_player_physics_properties()
	test_mouse_look_pitch_clamp()
	test_vector_projection_and_basis()
	test_mouse_capture_toggle()
	test_modular_environment_integrity()
	test_gravity_simulation()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha na suíte de testes de personagem, câmera e mundo 3D!")
		get_tree().quit(1)

func test_player_node_hierarchy() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	assert(player_scene != null, "A cena player.tscn deve existir e ser carregável.")
	
	var player_instance: Node = player_scene.instantiate()
	assert(player_instance is CharacterBody3D, "A raiz do jogador deve herdar de CharacterBody3D.")
	
	var col_shape: CollisionShape3D = player_instance.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert(col_shape != null, "O jogador deve possuir um nó CollisionShape3D.")
	assert(col_shape.shape is CapsuleShape3D, "A forma de colisão do jogador deve ser CapsuleShape3D.")
	
	var head_node: Node3D = player_instance.get_node_or_null("Head") as Node3D
	assert(head_node != null, "O jogador deve possuir um nó pivot Head (Node3D).")
	
	var cam: Camera3D = head_node.get_node_or_null("Camera3D") as Camera3D
	assert(cam != null, "A câmera deve ser filha do nó Head para rotação vertical desacoplada.")
	assert(cam.current == true, "A câmera em primeira pessoa deve estar com current = true.")
	
	var body: CharacterBody3D = player_instance as CharacterBody3D
	assert(body.collision_layer == 2, "O jogador deve pertencer à camada de colisão 2 (player).")
	assert(body.collision_mask == 1, "O jogador deve colidir com a camada 1 (world).")
	
	player_instance.free()
	passed_assertions += 1
	print("[TESTE 1/7 APROVADO] Hierarquia do jogador, colisão em cápsula e câmera em primeira pessoa.")

func test_player_physics_properties() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	
	assert(player.speed > 0.0, "A velocidade de caminhada deve ser positiva.")
	assert(player.sprint_speed > player.speed, "A velocidade de corrida deve ser superior à de caminhada.")
	assert(player.acceleration > 0.0, "A aceleração deve ser positiva.")
	assert(player.friction > 0.0, "O atrito deve ser positivo.")
	assert(player.jump_velocity > 0.0, "A velocidade de salto deve ser positiva.")
	assert(player.mouse_sensitivity > 0.0, "A sensibilidade do mouse deve ser positiva.")
	assert(player.gravity > 0.0, "A aceleração da gravidade deve ser positiva.")
	
	player.free()
	passed_assertions += 1
	print("[TESTE 2/7 APROVADO] Parâmetros físicos e dinâmicos do controlador validados.")

func test_mouse_look_pitch_clamp() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	player._ready()
	
	# Simula movimento vertical extremo para cima (tentando olhar além de 90 graus para cima)
	player.apply_mouse_look(Vector2(0.0, -10000.0))
	var max_pitch_rad: float = deg_to_rad(player.max_pitch_degrees)
	assert(player.head.rotation.x <= max_pitch_rad + 0.001, "A inclinação da cabeça não deve ultrapassar o limite superior permitido.")
	
	# Simula movimento vertical extremo para baixo (olhar para os pés)
	player.apply_mouse_look(Vector2(0.0, 20000.0))
	var min_pitch_rad: float = deg_to_rad(player.min_pitch_degrees)
	assert(player.head.rotation.x >= min_pitch_rad - 0.001, "A inclinação da cabeça não deve ultrapassar o limite inferior permitido.")
	
	player.free()
	passed_assertions += 1
	print("[TESTE 3/7 APROVADO] Trava angular de inclinação vertical (Pitch clamp) validada contra inversões.")

func test_vector_projection_and_basis() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	
	# Sem rotação, o avanço frontal local (0, 0, -1) deve equivaler a Vector3.FORWARD
	var local_fwd: Vector3 = Vector3(0.0, 0.0, -1.0)
	var world_fwd: Vector3 = (player.transform.basis * local_fwd).normalized()
	assert(world_fwd.is_equal_approx(Vector3.FORWARD), "Sem rotação corporal, a projeção frontal deve coincidir com Vector3.FORWARD.")
	
	# Rotaciona o personagem 90 graus para a esquerda em torno do eixo Y
	player.rotate_y(PI / 2.0)
	var rotated_fwd: Vector3 = (player.transform.basis * local_fwd).normalized()
	assert(rotated_fwd.is_equal_approx(Vector3.LEFT), "Após giro de 90 graus, o avanço frontal local deve projetar no eixo Vector3.LEFT do mundo.")
	
	player.free()
	passed_assertions += 1
	print("[TESTE 4/7 APROVADO] Projeção de movimento relativo à orientação corporal com Transform3D Basis.")

func test_mouse_capture_toggle() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	
	var signal_captured_values: Array[bool] = []
	player.mouse_mode_changed.connect(func(is_captured: bool): signal_captured_values.append(is_captured))
	
	player.set_mouse_captured(false)
	assert(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "O modo do cursor deve ser VISIBLE quando captured for falso.")
	
	player.set_mouse_captured(true)
	if DisplayServer.get_name() != "headless":
		assert(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "O modo do cursor deve ser CAPTURED quando captured for verdadeiro.")
	assert(signal_captured_values.size() >= 2, "O sinal mouse_mode_changed deve ser emitido nas alterações de captura.")
	
	# Restaura para modo visível para evitar travamento em execuções de teste
	player.set_mouse_captured(false)
	
	player.free()
	passed_assertions += 1
	print("[TESTE 5/7 APROVADO] Alternância e emissão de sinal de captura do mouse validadas.")

func test_modular_environment_integrity() -> void:
	var corridor_scene: PackedScene = load("res://src/world/modular_corridor.tscn")
	assert(corridor_scene != null, "A cena modular_corridor.tscn deve existir.")
	var corridor_inst: Node3D = corridor_scene.instantiate() as Node3D
	var corridor_floor: CSGBox3D = corridor_inst.get_node("Floor") as CSGBox3D
	assert(corridor_floor.use_collision == true, "O piso do corredor deve ter use_collision ativado.")
	corridor_inst.free()
	
	var room_scene: PackedScene = load("res://src/world/modular_room.tscn")
	assert(room_scene != null, "A cena modular_room.tscn deve existir.")
	var room_inst: Node3D = room_scene.instantiate() as Node3D
	var room_floor: CSGBox3D = room_inst.get_node("Floor") as CSGBox3D
	assert(room_floor.use_collision == true, "O piso da sala modular deve ter use_collision ativado.")
	var north_combiner: CSGCombiner3D = room_inst.get_node("WallNorthCombiner") as CSGCombiner3D
	assert(north_combiner.use_collision == true, "A parede com porta em CSGCombiner3D deve ter colisão sólida.")
	room_inst.free()
	
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub_inst: Node = hub_scene.instantiate()
	var hub_player: Node = hub_inst.get_node_or_null("Player")
	assert(hub_player is Player, "A cena da estação deve conter a instância oficial do nó Player.")
	hub_inst.free()
	
	passed_assertions += 1
	print("[TESTE 6/7 APROVADO] Integridade dos módulos de ambiente CSG e integração na cena principal.")

func test_gravity_simulation() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	
	# Simula estado no ar: velocidade Y inicial zerada
	player.velocity = Vector3.ZERO
	var dt: float = 0.5
	player.apply_gravity(dt)
	
	var expected_fall_speed: float = -player.gravity * dt
	assert(is_equal_approx(player.velocity.y, expected_fall_speed), "A velocidade vertical de queda deve decrescer exatamente gravidade * delta.")
	
	player.free()
	passed_assertions += 1
	print("[TESTE 7/7 APROVADO] Aplicação física da gravidade no eixo vertical tridimensional.")
