# ARQUIVO: res://src/entities/player/player.gd
# ANEXAR AO NODE: Player (CharacterBody2D)
# CENA: res://src/entities/player/player.tscn
# INPUTS NECESSÁRIOS: move_left, move_right, jump
# DEPENDÊNCIAS: res://src/components/health_component.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Personagem executa movimentação horizontal, salto refinado, tolerâncias de borda e gerencia vida e reações a dano via HealthComponent.
class_name Player
extends CharacterBody2D

signal player_damaged(current: int, max_val: int)
signal player_died()

@export_group("Movimento Horizontal")
@export var max_speed: float = 240.0
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0
@export var air_acceleration: float = 800.0
@export var air_friction: float = 200.0

@export_group("Salto e Gravidade")
@export var jump_velocity: float = -380.0
@export var fall_gravity_multiplier: float = 1.6
@export var jump_cut_multiplier: float = 0.5

@export_group("Tolerâncias (Game Feel)")
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.10

@onready var health_component: HealthComponent = get_node_or_null("%HealthComponent")
@onready var sprite: Sprite2D = get_node_or_null("%Sprite2D")

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _ready() -> void:
	if health_component != null:
		health_component.damaged.connect(_on_health_damaged)
		health_component.died.connect(_on_health_died)

func _physics_process(delta: float) -> void:
	_atualizar_timers(delta)
	_aplicar_gravidade(delta)
	_processar_salto()
	_processar_movimento_horizontal(delta)
	move_and_slide()

func _atualizar_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

func _aplicar_gravidade(delta: float) -> void:
	if not is_on_floor():
		if velocity.y > 0.0:
			velocity.y += gravity * fall_gravity_multiplier * delta
		else:
			velocity.y += gravity * delta

func _processar_salto() -> void:
	if jump_buffer_timer > 0.0 and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

func _processar_movimento_horizontal(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		var current_accel: float = acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * max_speed, current_accel * delta)
	else:
		var current_friction: float = friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

func rebater_salto() -> void:
	velocity.y = jump_velocity * 0.75

func _on_health_damaged(_amount: int) -> void:
	if health_component != null:
		player_damaged.emit(health_component.current_health, health_component.max_health)
	if sprite != null:
		sprite.modulate = Color(1.0, 0.4, 0.4, 1.0)
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

func _on_health_died() -> void:
	player_died.emit()
