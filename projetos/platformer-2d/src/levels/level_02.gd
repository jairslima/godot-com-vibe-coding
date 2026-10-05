# ARQUIVO: res://src/levels/level_02.gd
# ANEXAR AO NODE: Level02 (Node2D)
# CENA: res://src/levels/level_02.tscn
# INPUTS NECESSÁRIOS: move_left, move_right, jump
# DEPENDÊNCIAS: res://src/entities/player/player.tscn, res://src/components/hazard_area.gd, res://src/components/goal_area.gd, res://assets/tileset_default.tres
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Gerencia o segundo nível do jogo, com progressão vertical por plataformas suspensas em TileMapLayer e zona de espinhos.
class_name Level02
extends Node2D

@onready var background_layer: TileMapLayer = $BackgroundLayer
@onready var world_layer: TileMapLayer = $WorldLayer
@onready var hazard_area: HazardArea = $HazardArea
@onready var goal_area: GoalArea = $GoalArea
@onready var player: Player = $Player

func _ready() -> void:
	if hazard_area:
		hazard_area.player_entered.connect(_on_player_hazard)
	if goal_area:
		goal_area.reached.connect(_on_goal_reached)

	if world_layer and world_layer.get_used_cells().is_empty():
		construir_layout_fase()

	print("Level 02 inicializado com sucesso (segunda fase em TileMapLayer).")

func construir_layout_fase() -> void:
	# 1. Parede de fundo decorativa
	for x in range(0, 25):
		for y in range(4, 18):
			background_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

	# 2. Solo inicial seguro à esquerda
	for x in range(0, 8):
		world_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 0))
		world_layer.set_cell(Vector2i(x, 19), 0, Vector2i(1, 0))

	# 3. Solo inferior com espinhos perigosos
	for x in range(8, 16):
		world_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 1)) # Espinhos na superfície
		world_layer.set_cell(Vector2i(x, 19), 0, Vector2i(1, 0)) # Base rochosa

	# 4. Plataformas em subida vertical (unidirecionais)
	# Degrau 1
	for x in range(6, 10):
		world_layer.set_cell(Vector2i(x, 15), 0, Vector2i(2, 0))
	# Degrau 2
	for x in range(11, 15):
		world_layer.set_cell(Vector2i(x, 12), 0, Vector2i(2, 0))
	# Degrau 3
	for x in range(7, 11):
		world_layer.set_cell(Vector2i(x, 9), 0, Vector2i(2, 0))
	# Plataforma de chegada no topo
	for x in range(13, 19):
		world_layer.set_cell(Vector2i(x, 6), 0, Vector2i(0, 0))
		world_layer.set_cell(Vector2i(x, 7), 0, Vector2i(1, 0))

func _on_player_hazard(_p: Player) -> void:
	print("Jogador atingiu a zona de perigo no Level 02 e foi reposicionado.")

func _on_goal_reached(next_scene_path: String) -> void:
	print("Parabéns! Nível 02 concluído com sucesso.")
	if not next_scene_path.is_empty() and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
