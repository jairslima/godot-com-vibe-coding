# ARQUIVO: res://src/components/state_machine/enemy_states/enemy_patrol_state.gd
# ANEXAR AO NODE: PatrolState (Node herdando de State)
# CENA: Inimigo com FSM orientada a nós
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/state_machine/state.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa a rotina de patrulha autônoma e emite transição para perseguição ao detectar o jogador.
class_name EnemyPatrolState
extends State

@export var speed: float = 60.0
@export var detection_range: float = 160.0

func enter() -> void:
	if character != null and character.has_node("%Sprite2D"):
		var sprite: Sprite2D = character.get_node("%Sprite2D") as Sprite2D
		sprite.modulate = Color(1.0, 0.4, 0.4, 1.0)

func physics_update(_delta: float) -> void:
	if character == null:
		return

	var player: Node = character.get_tree().get_first_node_in_group("player")
	if player is CharacterBody2D:
		var dist: float = character.global_position.distance_to((player as CharacterBody2D).global_position)
		if dist <= detection_range:
			transitioned.emit("chasestate")
			return

	character.velocity.x = character.get("facing_direction") * speed if "facing_direction" in character else speed
