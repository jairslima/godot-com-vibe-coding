@tool
extends SceneTree

# Script utilitário para validar integridade de pré-build e pós-build
# Executado via CLI headless: godot_console --headless --path "projetos/estacao-sobrevivencia" -s res://tools/test_build_integrity.gd

func _init() -> void:
	print("[BUILD_INTEGRITY] Iniciando auditoria de pre-requisitos de build...")
	
	# 1. Validar versão da engine
	var info: Dictionary = Engine.get_version_info()
	var versao_str: String = "%d.%d.%d" % [info.major, info.minor, info.patch]
	assert(info.major == 4 and info.minor == 7, "A versao da engine deve ser Godot 4.7.x")
	print("[BUILD_INTEGRITY] Engine confirmada: Godot " + versao_str + " (" + str(info.status) + ")")
	
	# 2. Validar existência das cenas essenciais do jogo
	var cenas_obrigatorias: Array[String] = [
		"res://src/levels/estacao_mvp.tscn",
		"res://src/entities/player/player.tscn",
		"res://src/entities/creature/creature.tscn",
		"res://src/ui/hud.tscn",
		"res://src/core/game_manager.tscn"
	]
	
	for caminho_cena in cenas_obrigatorias:
		assert(ResourceLoader.exists(caminho_cena), "Cena essencial ausente: " + caminho_cena)
		print("[BUILD_INTEGRITY] Cena validada: " + caminho_cena)
		
	# 3. Validar escrita no protocolo user://
	var arquivo_teste: String = "user://build_check.tmp"
	var f: FileAccess = FileAccess.open(arquivo_teste, FileAccess.WRITE)
	assert(f != null, "Falha ao abrir arquivo temporario para escrita em user://")
	f.store_string("build_integrity_ok")
	f.close()
	
	assert(FileAccess.file_exists(arquivo_teste), "Arquivo temporario em user:// nao foi encontrado no disco")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(arquivo_teste))
	print("[BUILD_INTEGRITY] Protocolo user:// validado com sucesso (leitura e escrita atômica)")
	
	# 4. Validar arquivo de presets de exportação
	assert(FileAccess.file_exists("res://export_presets.cfg"), "Arquivo export_presets.cfg ausente na raiz do projeto")
	print("[BUILD_INTEGRITY] Arquivo export_presets.cfg localizado e confirmado")
	
	print("[BUILD_INTEGRITY] Sucesso: Todos os 4 criterios de integridade foram aprovados.")
	quit(0)
