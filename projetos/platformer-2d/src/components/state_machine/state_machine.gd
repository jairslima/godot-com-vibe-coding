# ARQUIVO: res://src/components/state_machine/state_machine.gd
# ANEXAR AO NODE: StateMachine (Node)
# CENA: Qualquer entidade que utilize FSM modular por nós
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/state_machine/state.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Gerencia a troca de estados discretos entre nós filhos, invocando métodos de ciclo de vida e garantindo um único estado ativo.
class_name StateMachine
extends Node

signal state_changed(old_state_name: String, new_state_name: String)

@export var initial_state: State

var current_state: State = null
var states: Dictionary = {}

func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			var state_node: State = child as State
			states[child.name.to_lower()] = state_node
			state_node.state_machine = self
			if owner is CharacterBody2D:
				state_node.character = owner as CharacterBody2D
			state_node.transitioned.connect(_on_state_transitioned)

	if initial_state != null:
		transition_to(initial_state.name)
	elif get_child_count() > 0 and get_child(0) is State:
		transition_to(get_child(0).name)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)

func transition_to(target_state_name: String) -> void:
	var key: String = target_state_name.to_lower()
	if not states.has(key):
		push_warning("StateMachine: estado desconhecido '%s'." % target_state_name)
		return

	var new_state: State = states[key]
	if new_state == current_state:
		return

	var old_name: String = current_state.name if current_state != null else ""
	if current_state != null:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	state_changed.emit(old_name, current_state.name)

func _on_state_transitioned(new_state_name: String) -> void:
	transition_to(new_state_name)
