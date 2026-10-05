# ARQUIVO: res://src/levels/test_world_tiles.gd
# ANEXAR AO NODE: TestWorldTiles (Node2D)
# CENA: res://src/levels/test_world_tiles.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://assets/tileset_default.tres, res://src/levels/level_01.tscn, res://src/levels/level_02.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa suíte de validação automatizada para TileSet, TileMapLayer, colisão com CharacterBody2D, conversão de coordenadas e transição de fases.
class_name TestWorldTiles
extends Node2D

@onready var level_instance: Level01 = $Level01

var frame_count: int = 0
var transition_tested: bool = false

func _ready() -> void:
	print("============================================================")
	print("INICIANDO TESTES AUTOMATIZADOS: TILESET E TILEMAPLAYER")
	print("============================================================")
	test_tileset_configuration()
	test_tilemap_layers_presence()
	test_coordinate_conversion()

func test_tileset_configuration() -> void:
	var ts: TileSet = load("res://assets/tileset_default.tres")
	assert(ts != null, "FALHA: Recurso TileSet não encontrado.")
	assert(ts.tile_size == Vector2i(32, 32), "FALHA: Tamanho de célula do TileSet divergente de 32x32.")
	assert(ts.get_physics_layers_count() > 0, "FALHA: Nenhuma physics layer configurada no TileSet.")
	var layer_bits: int = ts.get_physics_layer_collision_layer(0)
	assert(layer_bits == 1, "FALHA: Physics layer 0 deve apontar para camada 1 (world).")
	print("[TESTE 1/5 PASSOU] Recurso TileSet configurado com célula 32x32 e camada de física 'world'.")

func test_tilemap_layers_presence() -> void:
	assert(level_instance != null, "FALHA: Instância de Level01 não encontrada.")
	assert(level_instance.background_layer != null, "FALHA: BackgroundLayer não é TileMapLayer válido.")
	assert(level_instance.world_layer != null, "FALHA: WorldLayer não é TileMapLayer válido.")
	var used_cells: Array[Vector2i] = level_instance.world_layer.get_used_cells()
	assert(not used_cells.is_empty(), "FALHA: WorldLayer não possui células de terreno preenchidas.")
	print("[TESTE 2/5 PASSOU] Múltiplas camadas TileMapLayer validadas com preenchimento ativo.")

func test_coordinate_conversion() -> void:
	var world_layer: TileMapLayer = level_instance.world_layer
	# Testa coordenada de origem do solo (0, 18)
	var map_coord: Vector2i = Vector2i(0, 18)
	var local_pos: Vector2 = world_layer.map_to_local(map_coord)
	# No grid de 32x32, o centro da célula (0, 18) é (16, 18*32 + 16) = (16, 592)
	assert(local_pos == Vector2(16, 592), "FALHA: Conversão map_to_local incorreta.")
	var back_to_map: Vector2i = world_layer.local_to_map(local_pos)
	assert(back_to_map == map_coord, "FALHA: Conversão reversa local_to_map incorreta.")
	print("[TESTE 3/5 PASSOU] Conversão bidirecional map_to_local e local_to_map validada com precisão.")

func _physics_process(_delta: float) -> void:
	frame_count += 1

	# Aguarda 25 quadros de física para o Player cair sobre os tiles sólidos
	if frame_count == 25:
		var p: Player = level_instance.player
		assert(p != null, "FALHA: Player ausente na cena de teste.")
		assert(p.is_on_floor(), "FALHA: Player não colidiu ou não detectou o piso do TileMapLayer.")
		var current_cell: Vector2i = level_instance.world_layer.local_to_map(p.global_position)
		assert(current_cell.y >= 16 and current_cell.y <= 18, "FALHA: Posição do jogador fora da zona de solo esperada.")
		print("[TESTE 4/5 PASSOU] Colisão física entre CharacterBody2D e TileMapLayer validada com sucesso.")

	# No quadro 30, testa o trigger do GoalArea simulando o corpo do jogador
	if frame_count == 30 and not transition_tested:
		transition_tested = true
		# Desconecta para o teste não trocar a cena no meio da asserção
		if level_instance.goal_area.reached.is_connected(level_instance._on_goal_reached):
			level_instance.goal_area.reached.disconnect(level_instance._on_goal_reached)
		level_instance.goal_area.reached.connect(_on_goal_signal_received)
		level_instance.goal_area._on_body_entered(level_instance.player)

func _on_goal_signal_received(target_scene: String) -> void:
	assert(target_scene == "res://src/levels/level_02.tscn", "FALHA: Alvo da transição diverge de level_02.tscn.")
	print("[TESTE 5/5 PASSOU] Sinal GoalArea.reached recebido com destino correto (res://src/levels/level_02.tscn).")
	print("------------------------------------------------------------")
	print("TODOS OS 5 TESTES DE MUNDO, TILES E FASES APROVADOS!")
	print("------------------------------------------------------------")
	get_tree().quit(0)
