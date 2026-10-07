# ARQUIVO: res://tools/smoke_test.gd
# ANEXAR AO NODE: Executado como SceneTree autônomo via CLI (-s)
# CENA: Nenhuma (script SceneTree para execução headless)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/core/save_manager.gd, res://src/entities/player/player.tscn, res://src/levels/level_01.tscn, res://src/levels/level_02.tscn, res://assets/tileset_default.tres
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Smoke test headless ultrarrápido que valida carregamento de cenas vitais, recursos, nós centrais e lógica de persistência. Retorna código 0 no sucesso.
extends SceneTree

const CENAS_VITAIS: Array[String] = [
	"res://src/levels/level_01.tscn",
	"res://src/levels/level_02.tscn",
	"res://src/entities/player/player.tscn",
	"res://src/ui/hud.tscn",
	"res://src/ui/pause_menu.tscn"
]

const RECURSOS_VITAIS: Array[String] = [
	"res://assets/tileset_default.tres",
	"res://default_bus_layout.tres"
]

func _init() -> void:
	print("============================================================")
	print("INICIANDO SMOKE TEST HEADLESS: PLATAFORMA 2D")
	print("============================================================")
	
	var falhas: int = 0
	
	# 1. Validar existência e carregamento de cenas vitais
	print("[1/5] Validando integridade de cenas essenciais (.tscn)...")
	for caminho_cena in CENAS_VITAIS:
		if not ResourceLoader.exists(caminho_cena):
			printerr("ERRO CRÍTICO: Cena não encontrada no disco: %s" % caminho_cena)
			falhas += 1
			continue
		var cena: PackedScene = load(caminho_cena) as PackedScene
		if cena == null:
			printerr("ERRO CRÍTICO: Falha ao carregar cena empacotada: %s" % caminho_cena)
			falhas += 1
		else:
			print("  -> OK: %s" % caminho_cena)

	# 2. Validar integridade de arquivos de recursos (.tres)
	print("[2/5] Validando integridade de recursos (.tres)...")
	for caminho_res in RECURSOS_VITAIS:
		if not ResourceLoader.exists(caminho_res):
			printerr("ERRO CRÍTICO: Recurso não encontrado: %s" % caminho_res)
			falhas += 1
			continue
		var res: Resource = load(caminho_res)
		if res == null:
			printerr("ERRO CRÍTICO: Falha ao carregar recurso: %s" % caminho_res)
			falhas += 1
		else:
			print("  -> OK: %s" % caminho_res)

	# 3. Validar instanciação do Player e nós críticos
	print("[3/5] Instanciando nó Player e auditando componentes...")
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn") as PackedScene
	if player_scene != null:
		var player_node: Node = player_scene.instantiate()
		var sprite: Node = player_node.get_node_or_null("%Sprite2D")
		var colisor: Node = player_node.get_node_or_null("%CollisionShape2D")
		var camera: Node = player_node.get_node_or_null("%Camera2D")
		
		if sprite == null or colisor == null or camera == null:
			printerr("ERRO CRÍTICO: Hierarquia interna do Player incompleta (%Sprite2D, %CollisionShape2D ou %Camera2D ausente).")
			falhas += 1
		else:
			print("  -> OK: Player instanciado com nós vitais confirmados.")
		player_node.free()
	else:
		falhas += 1

	# 4. Validar lógica do SaveManager em memória
	print("[4/5] Testando rotinas do SaveManager em memória...")
	var save_script: GDScript = load("res://src/core/save_manager.gd") as GDScript
	if save_script != null:
		var sm: Node = save_script.new()
		sm.reiniciar_sessao()
		
		# Teste defensivo: rejeitar dados com pontuação negativa
		var dados_corrompidos: Dictionary = {
			"version": 2,
			"current_level_path": "res://src/levels/level_01.tscn",
			"player_health": 3,
			"max_health": 3,
			"score": -50,
			"current_checkpoint_id": "",
			"current_spawn_position": [0.0, 0.0]
		}
		var valido: bool = sm.validar_dados(dados_corrompidos)
		if valido:
			printerr("ERRO CRÍTICO: SaveManager aceitou dados com pontuação negativa!")
			falhas += 1
		else:
			print("  -> OK: SaveManager rejeitou corretamente dados com pontuação negativa.")
		sm.free()
	else:
		printerr("ERRO CRÍTICO: Falha ao carregar script do SaveManager.")
		falhas += 1

	# 5. Avaliação do resultado final
	print("[5/5] Consolidando resultado do smoke test...")
	if falhas > 0:
		printerr("------------------------------------------------------------")
		printerr("SMOKE TEST FALHOU COM %d ERRO(S) ENCONTRADO(S)." % falhas)
		printerr("------------------------------------------------------------")
		quit(1)
	else:
		print("------------------------------------------------------------")
		print("SMOKE TEST CONCLUÍDO COM SUCESSO: 0 FALHAS.")
		print("------------------------------------------------------------")
		quit(0)
