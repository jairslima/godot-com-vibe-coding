# ARQUIVO: res://src/components/goal_area.gd
# ANEXAR AO NODE: GoalArea (Area2D)
# CENA: res://src/levels/level_01.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta quando o jogador alcança a meta e emite o sinal reached para carregar a próxima fase.
class_name GoalArea
extends Area2D

signal reached(next_scene_path: String)

@export_file("*.tscn") var target_scene: String = ""

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Detecta Player (camada 2)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("GoalArea atingida pelo jogador. Transição para: ", target_scene)
		reached.emit(target_scene)
