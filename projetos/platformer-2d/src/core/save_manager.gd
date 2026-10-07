# ARQUIVO: res://src/core/save_manager.gd
# ANEXAR AO NODE: SaveManager (Autoload no project.godot)
# CENA: Autoload global (res://src/core/save_manager.gd)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma (opera exclusivamente com tipos primitivos e I/O seguro)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Gerencia persistência em user:// com FileAccess e JSON, gravação atômica, versionamento e migração de dados, controle de checkpoints e transições de fase desacopladas.
extends Node

signal game_saved()
signal game_loaded()
signal checkpoint_updated(id: String, pos: Vector2)
signal level_changed(level_path: String)

const SAVE_PATH: String = "user://savegame.json"
const SAVE_TMP_PATH: String = "user://savegame.tmp"
const CURRENT_VERSION: int = 2
const DEFAULT_LEVEL: String = "res://src/levels/level_01.tscn"

# Estado de sessão em memória (apenas dados puros, sem nós visuais acoplados)
var current_level_path: String = DEFAULT_LEVEL
var current_checkpoint_id: String = ""
var current_spawn_position: Vector2 = Vector2.ZERO
var player_health: int = 3
var max_health: int = 3
var score: int = 0

func salvar_jogo(caminho: String = SAVE_PATH) -> bool:
	var dados: Dictionary = obter_dicionario_estado()
	var json_texto: String = JSON.stringify(dados, "\t")
	var caminho_tmp: String = caminho + ".tmp"

	# 1. Gravação defensiva em arquivo temporário
	var arquivo_tmp: FileAccess = FileAccess.open(caminho_tmp, FileAccess.WRITE)
	if arquivo_tmp == null:
		var erro: Error = FileAccess.get_open_error()
		push_error("Falha ao abrir arquivo temporário para escrita: %s (Erro: %d)" % [caminho_tmp, erro])
		return false

	arquivo_tmp.store_string(json_texto)
	arquivo_tmp.close()

	# 2. Substituição atômica do arquivo definitivo
	if FileAccess.file_exists(caminho):
		DirAccess.remove_absolute(caminho)

	var erro_rename: Error = DirAccess.rename_absolute(caminho_tmp, caminho)
	if erro_rename != OK:
		push_error("Falha ao renomear arquivo temporário para o save definitivo: %d" % erro_rename)
		return false

	print("Jogo salvo com sucesso em: ", caminho, " (Versão: ", CURRENT_VERSION, ")")
	game_saved.emit()
	return true

func carregar_jogo(caminho: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(caminho):
		print("Nenhum arquivo de save encontrado em: ", caminho)
		return false

	var arquivo: FileAccess = FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		var erro: Error = FileAccess.get_open_error()
		push_error("Falha ao abrir arquivo de save para leitura: %s (Erro: %d)" % [caminho, erro])
		return false

	var conteudo: String = arquivo.get_as_text()
	arquivo.close()

	var parse_resultado: Variant = JSON.parse_string(conteudo)
	if not (parse_resultado is Dictionary):
		push_error("Arquivo de save corrompido ou formato inválido: %s" % caminho)
		return false

	var dados: Dictionary = parse_resultado as Dictionary

	# 1. Versionamento e migração transparente de versões antigas
	var versao_save: int = int(dados.get("version", 1))
	if versao_save < CURRENT_VERSION:
		print("Migrando dados de save da versão %d para a versão %d..." % [versao_save, CURRENT_VERSION])
		dados = migrar_dados(dados)

	# 2. Validação e sanitização defensiva contra dados impossíveis
	if not validar_dados(dados):
		push_error("Dados de save rejeitados pela validação de integridade.")
		return false

	# 3. Aplicação do estado validado à sessão em memória
	aplicar_dicionario_estado(dados)
	print("Save carregado com sucesso. Fase: %s | Checkpoint: %s | Vida: %d | Pontos: %d" % [
		current_level_path, current_checkpoint_id, player_health, score
	])
	game_loaded.emit()
	return true

func existe_save(caminho: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(caminho)

func apagar_save(caminho: String = SAVE_PATH) -> bool:
	if FileAccess.file_exists(caminho):
		var erro: Error = DirAccess.remove_absolute(caminho)
		return erro == OK
	return true

func obter_dicionario_estado() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"level_path": current_level_path,
		"checkpoint_id": current_checkpoint_id,
		"spawn_x": current_spawn_position.x,
		"spawn_y": current_spawn_position.y,
		"player_health": player_health,
		"max_health": max_health,
		"score": score
	}

func aplicar_dicionario_estado(dados: Dictionary) -> void:
	current_level_path = str(dados.get("level_path", DEFAULT_LEVEL))
	current_checkpoint_id = str(dados.get("checkpoint_id", ""))
	var sx: float = float(dados.get("spawn_x", 0.0))
	var sy: float = float(dados.get("spawn_y", 0.0))
	current_spawn_position = Vector2(sx, sy)
	max_health = maxi(1, int(dados.get("max_health", 3)))
	player_health = clampi(int(dados.get("player_health", 3)), 1, max_health)
	score = maxi(0, int(dados.get("score", 0)))

func migrar_dados(dados: Dictionary) -> Dictionary:
	var versao: int = int(dados.get("version", 1))

	# Migração da Versão 1 para Versão 2:
	# Na v1, o campo de fase era chamado "level" e não havia suporte a score nem checkpoint_id
	if versao == 1:
		var dados_v2: Dictionary = dados.duplicate()
		dados_v2["version"] = 2
		if not dados_v2.has("level_path"):
			var level_antigo: String = str(dados_v2.get("level", "01"))
			if level_antigo == "02":
				dados_v2["level_path"] = "res://src/levels/level_02.tscn"
			else:
				dados_v2["level_path"] = DEFAULT_LEVEL
		if not dados_v2.has("checkpoint_id"):
			dados_v2["checkpoint_id"] = ""
		if not dados_v2.has("spawn_x"):
			dados_v2["spawn_x"] = 0.0
			dados_v2["spawn_y"] = 0.0
		if not dados_v2.has("score"):
			dados_v2["score"] = 0
		if not dados_v2.has("max_health"):
			dados_v2["max_health"] = 3
		return dados_v2

	return dados

func validar_dados(dados: Dictionary) -> bool:
	if not dados.has("level_path"):
		return false

	var fase_path: String = str(dados.get("level_path", ""))
	if fase_path.is_empty() or not ResourceLoader.exists(fase_path):
		push_error("Validação falhou: cena de nível inexistente no projeto: %s" % fase_path)
		return false

	var vida: int = int(dados.get("player_health", 0))
	var vida_max: int = int(dados.get("max_health", 3))
	if vida <= 0 or vida_max <= 0:
		push_error("Validação falhou: valores de saúde inválidos no save.")
		return false

	var pontos: int = int(dados.get("score", 0))
	if pontos < 0:
		push_error("Validação falhou: pontuação negativa no save.")
		return false

	return true

func registrar_checkpoint(id: String, pos: Vector2, salvar_auto: bool = true) -> void:
	current_checkpoint_id = id
	current_spawn_position = pos
	print("SaveManager registrou checkpoint ativo: %s na coordenada %s" % [id, str(pos)])
	checkpoint_updated.emit(id, pos)
	if salvar_auto:
		salvar_jogo()

func obter_ponto_respawn(fallback_default: Vector2) -> Vector2:
	if current_spawn_position != Vector2.ZERO:
		return current_spawn_position
	return fallback_default

func trocar_de_fase(novo_caminho: String, salvar_auto: bool = true) -> void:
	if not ResourceLoader.exists(novo_caminho):
		push_error("Tentativa de transição para nível inexistente: %s" % novo_caminho)
		return

	current_level_path = novo_caminho
	current_checkpoint_id = ""
	current_spawn_position = Vector2.ZERO

	if salvar_auto:
		salvar_jogo()

	level_changed.emit(novo_caminho)
	get_tree().change_scene_to_file(novo_caminho)

func reiniciar_sessao() -> void:
	current_level_path = DEFAULT_LEVEL
	current_checkpoint_id = ""
	current_spawn_position = Vector2.ZERO
	max_health = 3
	player_health = 3
	score = 0
