# ARQUIVO: res://src/entities/enemies/enemy_patrol.gd
# ANEXAR AO NODE: EnemyPatrol (CharacterBody2D)
# CENA: res://src/entities/enemies/enemy_patrol.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/health_component.gd, res://src/components/hitbox_component.gd, res://src/components/hurtbox_component.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Inimigo de patrulha 2D com FSM via enum, sensores de abismo e parede, detecção reativa e integração com componentes de vida e dano.
class_name EnemyPatrol
extends CharacterBody2D

enum AIState {
	PATROL,
	CHASE,
	HURT,
	DEAD
}

signal state_changed(old_state: AIState, new_state: AIState)
signal enemy_died()

@export_group("Movimento e Física")
@export var patrol_speed: float = 60.0
@export var chase_speed: float = 110.0
@export var gravity: float = 980.0
@export var facing_direction: int = 1

@export_group("Detecção e Reatividade")
@export var detection_radius: float = 160.0
@export var lose_interest_radius: float = 240.0
@export var hurt_duration: float = 0.25

@export_group("Estado Inicial")
@export var current_state: AIState = AIState.PATROL

@onready var sprite: Sprite2D = %Sprite2D
@onready var floor_detector: RayCast2D = %FloorDetector
@onready var wall_detector: RayCast2D = %WallDetector
@onready var health_component: HealthComponent = %HealthComponent
@onready var hitbox: HitboxComponent = %HitboxComponent
@onready var hurtbox: HurtboxComponent = %HurtboxComponent

var target_player: CharacterBody2D = null
var hurt_timer: float = 0.0

func _ready() -> void:
	definir_direcao(facing_direction)
	if health_component != null:
		health_component.damaged.connect(_on_health_damaged)
		health_component.died.connect(_on_health_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		AIState.PATROL:
			_processar_patrulha(delta)
		AIState.CHASE:
			_processar_perseguicao(delta)
		AIState.HURT:
			_processar_dano(delta)
		AIState.DEAD:
			_processar_morte(delta)

	move_and_slide()

func _processar_patrulha(_delta: float) -> void:
	_procurar_jogador()
	if target_player != null:
		change_state(AIState.CHASE)
		return

	velocity.x = facing_direction * patrol_speed

	# Detecta borda da plataforma ou parede sólida
	if is_on_floor():
		var sem_chao_a_frente: bool = (floor_detector != null and not floor_detector.is_colliding())
		var parede_a_frente: bool = is_on_wall() or (wall_detector != null and wall_detector.is_colliding())
		if sem_chao_a_frente or parede_a_frente:
			inverter_direcao()

func _processar_perseguicao(_delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		change_state(AIState.PATROL)
		return

	var distancia: float = global_position.distance_to(target_player.global_position)
	if distancia > lose_interest_radius:
		change_state(AIState.PATROL)
		return

	var direcao_x: float = signf(target_player.global_position.x - global_position.x)
	if direcao_x != 0.0 and int(direcao_x) != facing_direction:
		definir_direcao(int(direcao_x))

	# Comportamento reativo: se houver abismo, não salta no vazio
	if is_on_floor() and floor_detector != null and not floor_detector.is_colliding():
		velocity.x = 0.0
	else:
		velocity.x = facing_direction * chase_speed

func _processar_dano(delta: float) -> void:
	hurt_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	if hurt_timer <= 0.0:
		if health_component != null and health_component.is_dead():
			change_state(AIState.DEAD)
		else:
			change_state(AIState.PATROL)

func _processar_morte(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)

func change_state(new_state: AIState) -> void:
	if current_state == new_state:
		return

	var old_state: AIState = current_state
	current_state = new_state

	match current_state:
		AIState.PATROL:
			target_player = null
			if sprite != null:
				sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
		AIState.CHASE:
			if sprite != null:
				sprite.modulate = Color(1.0, 0.1, 0.1, 1.0)
		AIState.HURT:
			hurt_timer = hurt_duration
			if sprite != null:
				sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		AIState.DEAD:
			if sprite != null:
				sprite.modulate = Color(0.4, 0.4, 0.4, 0.5)
			set_deferred("collision_layer", 0)
			set_deferred("collision_mask", 1)
			if hitbox != null:
				hitbox.set_deferred("monitoring", false)
				hitbox.set_deferred("monitorable", false)
			if hurtbox != null:
				hurtbox.set_deferred("monitoring", false)
				hurtbox.set_deferred("monitorable", false)
			enemy_died.emit()

	state_changed.emit(old_state, current_state)

func inverter_direcao() -> void:
	definir_direcao(-facing_direction)

func definir_direcao(nova_direcao: int) -> void:
	facing_direction = nova_direcao if nova_direcao != 0 else 1
	if sprite != null:
		sprite.flip_h = (facing_direction < 0)
	if floor_detector != null:
		floor_detector.position.x = 16.0 * facing_direction
	if wall_detector != null:
		wall_detector.target_position.x = 20.0 * facing_direction

func _procurar_jogador() -> void:
	var jogadores: Array[Node] = get_tree().get_nodes_in_group("player")
	for node: Node in jogadores:
		if node is CharacterBody2D:
			var candidato: CharacterBody2D = node as CharacterBody2D
			var dist: float = global_position.distance_to(candidato.global_position)
			if dist <= detection_radius:
				target_player = candidato
				return
	target_player = null

func _on_health_damaged(_amount: int) -> void:
	change_state(AIState.HURT)

func _on_health_died() -> void:
	change_state(AIState.DEAD)
