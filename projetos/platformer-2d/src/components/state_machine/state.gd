# ARQUIVO: res://src/components/state_machine/state.gd
# ANEXAR AO NODE: Nós filhos dentro de uma StateMachine
# CENA: Qualquer máquina de estados orientada a nós
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Classe base abstrata para estados individuais em uma FSM por nós, com ciclo de vida enter, exit e physics_update.
class_name State
extends Node

signal transitioned(new_state_name: String)

var state_machine: Node = null
var character: CharacterBody2D = null

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
