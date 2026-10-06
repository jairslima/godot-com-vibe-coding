# ARQUIVO: res://src/entities/player/player.gd
# ANEXAR AO NODE: Player (CharacterBody2D)
# CENA: res://src/entities/player/player.tscn
# INPUTS NECESSÁRIOS: move_left, move_right, jump
# DEPENDÊNCIAS: res://src/components/health_component.gd, res://src/audio/sound_manager.gd, res://src/components/dust_particles.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Personagem executa movimentação, animação por estados, game feel com squash & stretch via Tween, partículas de poeira, efeitos sonoros no bus SFX, screen shake e hitstop ao sofrer dano.
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

@export_group("Screen Shake (Câmera)")
@export var trauma_decay: float = 3.5
@export var max_shake_offset: Vector2 = Vector2(14.0, 10.0)

const DUST_PARTICLES_SCENE = preload("res://src/components/dust_particles.tscn")

@onready var health_component: HealthComponent = get_node_or_null("%HealthComponent")
@onready var sprite: Sprite2D = get_node_or_null("%Sprite2D")
@onready var camera: Camera2D = get_node_or_null("%Camera2D")
@onready var anim_player: AnimationPlayer = get_node_or_null("%AnimationPlayer")

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var trauma: float = 0.0
var base_sprite_scale: Vector2 = Vector2(0.25, 0.375)
var current_tween: Tween = null

func _ready() -> void:
	if sprite != null:
		base_sprite_scale = sprite.scale

	if health_component != null:
		health_component.damaged.connect(_on_health_damaged)
		health_component.died.connect(_on_health_died)

	was_on_floor = is_on_floor()

func _process(delta: float) -> void:
	_processar_screen_shake(delta)
	_atualizar_animacao()

func _physics_process(delta: float) -> void:
	_atualizar_timers(delta)
	_aplicar_gravidade(delta)
	_processar_salto()
	_processar_movimento_horizontal(delta)
	move_and_slide()

	# Detecção precisa de aterrissagem para acionar game feel
	if not was_on_floor and is_on_floor():
		_ao_aterrissar()

	was_on_floor = is_on_floor()

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

		# Feedback audiovisual de salto
		_ao_saltar()

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

func _processar_movimento_horizontal(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		var current_accel: float = acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * max_speed, current_accel * delta)
		if sprite != null:
			sprite.flip_h = direction < 0.0
	else:
		var current_friction: float = friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

func rebater_salto() -> void:
	velocity.y = jump_velocity * 0.75
	_ao_saltar()

# --- FEEDBACK VISUAL, AUDITIVO E GAME FEEL ---

func _ao_saltar() -> void:
	SoundManager.tocar_som(self, SoundManager.obter_som_pulo(), 0.95, 1.05, -2.0)
	_aplicar_squash_stretch(Vector2(0.75, 1.35), 0.14)
	_emitir_poeira()

func _ao_aterrissar() -> void:
	SoundManager.tocar_som(self, SoundManager.obter_som_pouso(), 0.90, 1.10, -4.0)
	_aplicar_squash_stretch(Vector2(1.35, 0.75), 0.16)
	_emitir_poeira()

func _emitir_poeira() -> void:
	if DUST_PARTICLES_SCENE == null:
		return
	var dust: CPUParticles2D = DUST_PARTICLES_SCENE.instantiate()
	dust.global_position = global_position + Vector2(0, 24)
	get_parent().add_child(dust)

func _aplicar_squash_stretch(fator: Vector2, duracao: float) -> void:
	if sprite == null:
		return
	if current_tween != null and current_tween.is_valid():
		current_tween.kill()

	current_tween = create_tween()
	sprite.scale = Vector2(base_sprite_scale.x * fator.x, base_sprite_scale.y * fator.y)
	current_tween.tween_property(sprite, "scale", base_sprite_scale, duracao)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _atualizar_animacao() -> void:
	if anim_player == null:
		return

	if not is_on_floor():
		if anim_player.has_animation("jump"):
			anim_player.play("jump")
	elif absf(velocity.x) > 10.0:
		if anim_player.has_animation("run"):
			anim_player.play("run")
	else:
		if anim_player.has_animation("idle"):
			anim_player.play("idle")

# --- SCREEN SHAKE E HITSTOP ---

func aplicar_shake(intensidade: float) -> void:
	trauma = clampf(trauma + intensidade, 0.0, 1.0)

func _processar_screen_shake(delta: float) -> void:
	if camera == null:
		return

	if trauma > 0.0:
		trauma = maxf(0.0, trauma - trauma_decay * delta)
		var tremor: float = trauma * trauma # Não linearidade quadrática
		camera.offset = Vector2(
			randf_range(-max_shake_offset.x, max_shake_offset.x) * tremor,
			randf_range(-max_shake_offset.y, max_shake_offset.y) * tremor
		)
	else:
		camera.offset = Vector2.ZERO

func aplicar_hitstop(duracao: float = 0.06, escala: float = 0.05) -> void:
	Engine.time_scale = escala
	await get_tree().create_timer(duracao, true, false, true).timeout
	Engine.time_scale = 1.0

# --- SINAIS E REAÇÕES A DANO ---

func _on_health_damaged(_amount: int) -> void:
	if health_component != null:
		player_damaged.emit(health_component.current_health, health_component.max_health)

	SoundManager.tocar_som(self, SoundManager.obter_som_impacto(), 0.92, 1.04, 0.0)
	aplicar_shake(0.6)
	aplicar_hitstop(0.05, 0.05)

	if sprite != null:
		sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _on_health_died() -> void:
	aplicar_shake(1.0)
	player_died.emit()
