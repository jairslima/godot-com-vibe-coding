# ARQUIVO: res://src/levels/level_01.gd
# ANEXAR AO NODE: Level01 (Node2D)
# CENA: res://src/levels/level_01.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Inicializa o nível de teste e confirma a presença do jogador.
class_name Level01
extends Node2D

func _ready() -> void:
	print("Level 01 inicializado com sucesso (platformer-00-bootstrap).")
