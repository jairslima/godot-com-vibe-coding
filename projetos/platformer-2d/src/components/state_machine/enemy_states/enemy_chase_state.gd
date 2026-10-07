# ARQUIVO: res://src/components/state_machine/enemy_states/enemy_chase_state.gd
# ANEXAR AO NODE: ChaseState (Node herdando de State)
# CENA: Inimigo com FSM orientada a nós
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/state_machine/state.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa a perseguição ao jogador e transita de volta à patrulha se o alvo fugir do alcance.
class_name EnemyChaseState
extends State

@export var speed: float = 110.0
@export var lose_range: float = 240.0

func enter() -> void:
	if character != null and character.has_node("%Sprite2D"):
		var sprite: Sprite2D = character.get_node("%Sprite2D") as Sprite2D
		sprite.modulate = Color(1.0, 0.1, 0.1, 1.0)

func physics_update(_delta: float) -> void:
	if character == null:
		return

	var player: Node = character.get_tree().get_first_node_in_group("player")
	if not (player is CharacterBody2D):
		transitioned.emit("patrolstate")
		return

	var player_body: CharacterBody2D = player as CharacterBody2D
	var dist: float = character.global_position.distance_to(player_body.global_position)
	if dist > lose_range:
		transitioned.emit("patrolstate")
		return

	var dir: float = signf(player_body.global_position.x - character.global_position.x)
	if dir != 0.0 and "facing_direction" in character:
		character.set("facing_direction", int(dir))

	character.velocity.x = dir * speed
