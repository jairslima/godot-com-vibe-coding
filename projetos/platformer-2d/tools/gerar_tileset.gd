# ARQUIVO: res://tools/gerar_tileset.gd
# DESCRIÇÃO: Utilitário para gerar a textura do atlas e o recurso TileSet configurado.
extends SceneTree

func _init() -> void:
	print("--- CONFIGURANDO TILESET ---")
	gerar_textura()
	gerar_recurso_tileset()
	quit(0)

func gerar_textura() -> void:
	var width: int = 128
	var height: int = 64
	var img: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tile (0, 0): Bloco de Superfície (Grama e Terra)
	for x in range(0, 32):
		for y in range(0, 32):
			if y < 8:
				img.set_pixel(x, y, Color(0.25, 0.65, 0.28, 1.0))
			elif y < 10:
				img.set_pixel(x, y, Color(0.20, 0.50, 0.22, 1.0))
			else:
				var shade: float = 0.35 + (float((x * 7 + y * 13) % 10) / 100.0)
				img.set_pixel(x, y, Color(shade, shade * 0.6, shade * 0.3, 1.0))

	# Tile (1, 0): Bloco Subterrâneo (Rocha sólida)
	for x in range(32, 64):
		for y in range(0, 32):
			var noise: float = 0.28 + (float((x * 11 + y * 17) % 15) / 100.0)
			img.set_pixel(x, y, Color(noise, noise * 0.95, noise * 1.05, 1.0))
			if x == 32 or x == 63 or y == 0 or y == 31:
				img.set_pixel(x, y, Color(0.20, 0.20, 0.22, 1.0))

	# Tile (2, 0): Plataforma Flutuante (Viga metálica com rebites)
	for x in range(64, 96):
		for y in range(0, 32):
			if y >= 8 and y <= 24:
				img.set_pixel(x, y, Color(0.55, 0.40, 0.25, 1.0))
				if y == 8 or y == 24 or x == 64 or x == 95:
					img.set_pixel(x, y, Color(0.35, 0.25, 0.15, 1.0))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	# Tile (3, 0): Parede de Fundo (Tijolos escuros, sem colisão)
	for x in range(96, 128):
		for y in range(0, 32):
			var is_mortar: bool = (y % 8 == 0) or ((y / 8) % 2 == 0 and x % 16 == 0) or ((y / 8) % 2 == 1 and (x + 8) % 16 == 0)
			if is_mortar:
				img.set_pixel(x, y, Color(0.12, 0.12, 0.15, 1.0))
			else:
				img.set_pixel(x, y, Color(0.20, 0.18, 0.24, 1.0))

	# Tile (0, 1): Espinhos / Perigo
	for x in range(0, 32):
		for y in range(32, 64):
			var local_y: int = y - 32
			var spike1: bool = (local_y >= 31 - (x % 16) * 2) and (x % 16 < 8)
			var spike2: bool = (local_y >= 31 - (15 - (x % 16)) * 2) and (x % 16 >= 8)
			if spike1 or spike2:
				img.set_pixel(x, y, Color(0.85, 0.25, 0.20, 1.0))
				if local_y == 31:
					img.set_pixel(x, y, Color(0.40, 0.10, 0.10, 1.0))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	var dir: DirAccess = DirAccess.open("res://")
	if not dir.dir_exists("assets/sprites"):
		dir.make_dir_recursive("assets/sprites")
	var err: Error = img.save_png("res://assets/sprites/tileset_atlas.png")
	if err == OK:
		print("Textura gravada em res://assets/sprites/tileset_atlas.png")

func gerar_recurso_tileset() -> void:
	var ts: TileSet = TileSet.new()
	ts.tile_size = Vector2i(32, 32)

	# 1. Configurar camadas do TileSet ANTES de vincular ao atlas
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1) # Layer 1 = World
	ts.set_physics_layer_collision_mask(0, 0)

	ts.add_occlusion_layer()
	ts.add_navigation_layer()

	# 2. Criar Atlas Source com a textura importada
	var atlas_source: TileSetAtlasSource = TileSetAtlasSource.new()
	var tex: Texture2D = load("res://assets/sprites/tileset_atlas.png")
	atlas_source.texture = tex
	atlas_source.texture_region_size = Vector2i(32, 32)

	# 3. Adicionar atlas ao TileSet para que o TileSet injete a estrutura de camadas no Source
	ts.add_source(atlas_source, 0)

	# 4. Polígonos de colisão
	var full_box: PackedVector2Array = PackedVector2Array([
		Vector2(-16, -16),
		Vector2(16, -16),
		Vector2(16, 16),
		Vector2(-16, 16)
	])

	var platform_box: PackedVector2Array = PackedVector2Array([
		Vector2(-16, -8),
		Vector2(16, -8),
		Vector2(16, 8),
		Vector2(-16, 8)
	])

	var spike_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-16, 16),
		Vector2(-8, -12),
		Vector2(0, 16),
		Vector2(8, -12),
		Vector2(16, 16)
	])

	# 5. Criar tiles e definir propriedades
	# Tile (0, 0): Superfície
	atlas_source.create_tile(Vector2i(0, 0))
	var data_00: TileData = atlas_source.get_tile_data(Vector2i(0, 0), 0)
	data_00.set_collision_polygons_count(0, 1)
	data_00.set_collision_polygon_points(0, 0, full_box)

	# Tile (1, 0): Subsolo sólido
	atlas_source.create_tile(Vector2i(1, 0))
	var data_10: TileData = atlas_source.get_tile_data(Vector2i(1, 0), 0)
	data_10.set_collision_polygons_count(0, 1)
	data_10.set_collision_polygon_points(0, 0, full_box)

	# Tile (2, 0): Plataforma com one-way collision
	atlas_source.create_tile(Vector2i(2, 0))
	var data_20: TileData = atlas_source.get_tile_data(Vector2i(2, 0), 0)
	data_20.set_collision_polygons_count(0, 1)
	data_20.set_collision_polygon_points(0, 0, platform_box)
	data_20.set_collision_polygon_one_way(0, 0, true)

	# Tile (3, 0): Fundo (parede sem colisão)
	atlas_source.create_tile(Vector2i(3, 0))

	# Tile (0, 1): Espinhos
	atlas_source.create_tile(Vector2i(0, 1))
	var data_01: TileData = atlas_source.get_tile_data(Vector2i(0, 1), 0)
	data_01.set_collision_polygons_count(0, 1)
	data_01.set_collision_polygon_points(0, 0, spike_poly)

	var err: Error = ResourceSaver.save(ts, "res://assets/tileset_default.tres")
	if err == OK:
		print("TileSet configurado com sucesso e salvo em res://assets/tileset_default.tres")
	else:
		printerr("Erro ao salvar TileSet: ", err)
