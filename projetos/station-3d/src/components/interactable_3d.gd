class_name Interactable3D
extends Area3D

## Componente base de interação espacial para objetos da estação 3D.
## Registra-se na camada física de interativos (camada 4) e processa gatilhos e avisos de interface.

signal interacted(player: Node3D)
signal highlight_changed(is_highlighted: bool)

@export var prompt_message: String = "Pressione [E] para interagir"
@export var is_active: bool = true

func _ready() -> void:
	# Camada 4 (interactables): valor binário 1 << 3 = 8
	collision_layer = 8
	collision_mask = 0
	monitoring = false
	monitorable = true

func get_prompt() -> String:
	return prompt_message

func interact(player: Node3D = null) -> void:
	if not is_active:
		return
	interacted.emit(player)

func set_highlight(active: bool) -> void:
	highlight_changed.emit(active)
