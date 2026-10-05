# ARQUIVO: res://src/levels/level_01.gd
# ANEXAR AO NODE: Level01 (Node2D)
# CENA: res://src/levels/level_01.tscn
# INPUTS NECESSÁRIOS: move_left, move_right, jump
# DEPENDÊNCIAS: res://src/entities/player/player.tscn, res://src/components/hazard_area.gd, res://src/components/goal_area.gd, res://assets/tileset_default.tres
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Gerencia o primeiro nível com TileMapLayer de fundo e terreno, jogador, zona de perigo e transição para o nível 02.
class_name Level01
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

	# Se a camada de terreno estiver vazia (execução inicial ou headless), gerar o layout base
	if world_layer and world_layer.get_used_cells().is_empty():
		construir_layout_fase()

	print("Level 01 inicializado com sucesso (TileMapLayer ativo).")

func construir_layout_fase() -> void:
	# 1. Parede de fundo (BackgroundLayer)
	# Preenche um painel decorativo de tijolos escuros (atlas 3,0)
	for x in range(2, 28):
		for y in range(10, 18):
			background_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

	# 2. Terreno sólido (WorldLayer)
	# Solo inicial (colunas 0 a 14 na linha 18, com subsolo na linha 19)
	for x in range(0, 15):
		world_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 0)) # Superfície
		world_layer.set_cell(Vector2i(x, 19), 0, Vector2i(1, 0)) # Subsolo

	# Vão / Abismo entre x=15 e x=18

	# Plataforma suspensa unidirecional (atlas 2,0) sobre o abismo
	for x in range(15, 18):
		world_layer.set_cell(Vector2i(x, 15), 0, Vector2i(2, 0))

	# Segundo trecho de solo sólido (colunas 18 a 32 na linha 18)
	for x in range(18, 33):
		world_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 0))
		world_layer.set_cell(Vector2i(x, 19), 0, Vector2i(1, 0))

	# Plataformas elevadas para alcançar a saída
	for x in range(24, 27):
		world_layer.set_cell(Vector2i(x, 14), 0, Vector2i(2, 0))
	for x in range(28, 31):
		world_layer.set_cell(Vector2i(x, 11), 0, Vector2i(2, 0))

func _on_player_hazard(_p: Player) -> void:
	print("Jogador caiu na zona de perigo e foi reposicionado.")

func _on_goal_reached(next_scene_path: String) -> void:
	print("Nível 01 concluído. Carregando: ", next_scene_path)
	if not next_scene_path.is_empty() and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
