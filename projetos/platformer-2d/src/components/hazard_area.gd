# ARQUIVO: res://src/components/hazard_area.gd
# ANEXAR AO NODE: HazardArea (Area2D)
# CENA: res://src/levels/level_01.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta quando um corpo do tipo Player entra na área de perigo, emite sinal e reposiciona a entidade.
class_name HazardArea
extends Area2D

signal player_entered(player: Player)

@export var reset_position: Vector2 = Vector2(640.0, 400.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(body)
		body.global_position = reset_position
		body.velocity = Vector2.ZERO
