# ARQUIVO: res://src/levels/level_01.gd
# ANEXAR AO NODE: Level01 (Node2D)
# CENA: res://src/levels/level_01.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.tscn, res://src/components/hazard_area.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Inicializa o nível de teste com suporte a movimento, salto, câmera e zona de perigo.
class_name Level01
extends Node2D

@onready var hazard_area: HazardArea = $HazardArea
@onready var player: Player = $Player

func _ready() -> void:
	if hazard_area:
		hazard_area.player_entered.connect(_on_player_hazard)
	print("Level 01 inicializado com sucesso (platformer-01-movement e platformer-02-jump-and-camera).")

func _on_player_hazard(_p: Player) -> void:
	print("Jogador atingiu a zona de perigo e foi reposicionado.")
