class_name Player
extends CharacterBody3D

## Controlador de personagem tridimensional em primeira pessoa para a Estação 3D.
## Gerencia movimentação com inércia, rotação de câmera com mouse look e interação por RayCast3D.

signal mouse_mode_changed(is_captured: bool)
signal interaction_prompt_changed(prompt_text: String, is_visible: bool)

@export_group("Movimento")
@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 12.0
@export var friction: float = 14.0
@export var jump_velocity: float = 4.5

@export_group("Câmera")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch_degrees: float = -89.0
@export var max_pitch_degrees: float = 89.0

@export_group("Interação")
@export var interaction_range: float = 2.5

@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera3D
@onready var collision_shape: CollisionShape3D = %CollisionShape3D
@onready var interaction_ray: RayCast3D = %InteractionRayCast

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var is_sprinting: bool = false
var last_interactable: Node = null

func _ready() -> void:
	# Em modo headless com drivers dummy, não capturamos o mouse para evitar chamadas de SO desnecessárias
	if not DisplayServer.get_name().is_empty() and DisplayServer.get_name() != "headless":
		set_mouse_captured(true)
	
	if interaction_ray:
		interaction_ray.target_position = Vector3(0, 0, -interaction_range)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_mouse_look(event.relative)
	
	if event.is_action_pressed("pause"):
		toggle_mouse_capture()
	
	if event.is_action_pressed("interact"):
		attempt_interaction()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	process_interaction_ray()

func apply_mouse_look(relative_motion: Vector2) -> void:
	# Rotação horizontal (Yaw): rotaciona o corpo inteiro do personagem em torno do eixo Y global
	rotate_y(-relative_motion.x * mouse_sensitivity)
	
	# Rotação vertical (Pitch): rotaciona apenas o nó pivot Head em torno de seu eixo X local
	if head:
		head.rotate_x(-relative_motion.y * mouse_sensitivity)
		var min_rad: float = deg_to_rad(min_pitch_degrees)
		var max_rad: float = deg_to_rad(max_pitch_degrees)
		head.rotation.x = clampf(head.rotation.x, min_rad, max_rad)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# No Godot 3D, move_forward aponta para -Z (profundidade).
	# A multiplicação por transform.basis projeta o vetor local nos eixos mundiais do personagem.
	var local_direction: Vector3 = Vector3(input_dir.x, 0.0, input_dir.y)
	var move_direction: Vector3 = (transform.basis * local_direction).normalized()
	
	var current_target_speed: float = sprint_speed if is_sprinting else speed
	
	if move_direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, move_direction.x * current_target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, move_direction.z * current_target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)

func process_interaction_ray() -> void:
	if not interaction_ray or not interaction_ray.is_colliding():
		clear_interaction_target()
		return
	
	var collider: Object = interaction_ray.get_collider()
	if not collider:
		clear_interaction_target()
		return
	
	var current_node: Node = collider as Node
	if current_node == last_interactable:
		return
	
	clear_interaction_target()
	
	if current_node and current_node.has_method("get_prompt"):
		last_interactable = current_node
		var prompt: String = current_node.call("get_prompt") as String
		interaction_prompt_changed.emit(prompt, true)
		if current_node.has_method("set_highlight"):
			current_node.call("set_highlight", true)

func clear_interaction_target() -> void:
	if last_interactable:
		if is_instance_valid(last_interactable) and last_interactable.has_method("set_highlight"):
			last_interactable.call("set_highlight", false)
		last_interactable = null
		interaction_prompt_changed.emit("", false)

func attempt_interaction() -> void:
	if not interaction_ray or not interaction_ray.is_colliding():
		return
	
	var collider: Object = interaction_ray.get_collider()
	if collider and collider.has_method("interact"):
		collider.call("interact", self)

func set_mouse_captured(captured: bool) -> void:
	if captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_mode_changed.emit(captured)

func toggle_mouse_capture() -> void:
	var new_state: bool = (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED)
	set_mouse_captured(new_state)
