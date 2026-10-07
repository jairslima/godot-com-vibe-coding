# ARQUIVO: res://src/levels/test_save_load.gd
# ANEXAR AO NODE: TestSaveLoad (Node2D)
# CENA: res://src/levels/test_save_load.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/core/save_manager.gd, res://src/components/checkpoint.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa suíte automatizada headless com 5 testes de persistência: I/O JSON com FileAccess, gravação atômica, migração de esquema de versão, validação defensiva contra dados corrompidos e ciclo de respawn por checkpoint.
class_name TestSaveLoad
extends Node2D

const CHECKPOINT_SCRIPT = preload("res://src/components/checkpoint.gd")
const SAVE_MANAGER_SCRIPT = preload("res://src/core/save_manager.gd")
const TEST_SAVE_ATOMIC: String = "user://test_save_atomic.json"
const TEST_SAVE_V1: String = "user://test_save_v1.json"
const TEST_SAVE_CORRUPT: String = "user://test_save_corrupt.json"

var save_manager: Node = null
var testes_passaram: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Obtém ou instancia SaveManager de forma autônoma
	save_manager = get_node_or_null("/root/SaveManager")
	if save_manager == null:
		save_manager = SAVE_MANAGER_SCRIPT.new()
		add_child(save_manager)

	print("============================================================")
	print("INICIANDO SUÍTE HEADLESS: SAVE, CHECKPOINTS E PROGRESSÃO")
	print("============================================================")

	_testar_salvar_e_carregar_json()
	_testar_gravacao_atomica()
	_testar_migracao_de_esquema()
	_testar_sanitizacao_e_dados_invalidos()
	_testar_checkpoint_e_respawn()
	_limpar_arquivos_teste()
	_concluir_testes()

func _testar_salvar_e_carregar_json() -> void:
	# 1. Prepara estado conhecido de sessão
	save_manager.current_level_path = "res://src/levels/level_02.tscn"
	save_manager.current_checkpoint_id = "cp_teste_salvamento"
	save_manager.current_spawn_position = Vector2(320.0, 480.0)
	save_manager.player_health = 2
	save_manager.max_health = 3
	save_manager.score = 250

	# 2. Salva e valida arquivo no disco
	var salvou: bool = save_manager.salvar_jogo(TEST_SAVE_ATOMIC)
	assert(salvou, "SaveManager.salvar_jogo() deve retornar true ao salvar.")
	assert(FileAccess.file_exists(TEST_SAVE_ATOMIC), "O arquivo de save físico deve existir no disco.")

	# 3. Lê o arquivo bruto e valida integridade JSON
	var arq: FileAccess = FileAccess.open(TEST_SAVE_ATOMIC, FileAccess.READ)
	assert(arq != null, "Arquivo de save deve abrir para leitura.")
	var texto: String = arq.get_as_text()
	arq.close()

	var dados: Variant = JSON.parse_string(texto)
	assert(dados is Dictionary, "Conteúdo do save deve ser um Dictionary válido.")
	var d: Dictionary = dados as Dictionary
	assert(int(d["version"]) == save_manager.CURRENT_VERSION, "Versão do save deve ser igual a CURRENT_VERSION.")
	assert(str(d["level_path"]) == "res://src/levels/level_02.tscn", "level_path salvo incorretamente.")
	assert(str(d["checkpoint_id"]) == "cp_teste_salvamento", "checkpoint_id salvo incorretamente.")
	assert(is_equal_approx(float(d["spawn_x"]), 320.0), "spawn_x divergente.")
	assert(is_equal_approx(float(d["spawn_y"]), 480.0), "spawn_y divergente.")
	assert(int(d["player_health"]) == 2, "player_health divergente.")
	assert(int(d["score"]) == 250, "score divergente.")

	# 4. Reseta a sessão e recarrega via SaveManager
	save_manager.reiniciar_sessao()
	assert(save_manager.score == 0, "Reiniciar sessão deve zerar a pontuação.")
	assert(save_manager.current_level_path == save_manager.DEFAULT_LEVEL, "Deve voltar ao nível padrão.")

	var carregou: bool = save_manager.carregar_jogo(TEST_SAVE_ATOMIC)
	assert(carregou, "SaveManager.carregar_jogo() deve retornar true.")
	assert(save_manager.current_level_path == "res://src/levels/level_02.tscn", "Fase restaurada incorretamente.")
	assert(save_manager.current_checkpoint_id == "cp_teste_salvamento", "Checkpoint restaurado incorretamente.")
	assert(save_manager.player_health == 2, "Vida restaurada incorretamente.")
	assert(save_manager.score == 250, "Pontuação restaurada incorretamente.")

	testes_passaram += 1
	print("[TESTE 1/5 PASSOU] Salvar e carregar com FileAccess e JSON validado com sucesso.")

func _testar_gravacao_atomica() -> void:
	var caminho_tmp: String = TEST_SAVE_ATOMIC + ".tmp"

	# Salva novamente para garantir substituição atômica limpa
	var salvou: bool = save_manager.salvar_jogo(TEST_SAVE_ATOMIC)
	assert(salvou, "Gravação atômica deve ter sucesso.")
	assert(not FileAccess.file_exists(caminho_tmp), "Arquivo temporário .tmp deve ter sido renomeado, não pode restar no disco.")
	assert(FileAccess.file_exists(TEST_SAVE_ATOMIC), "Arquivo final deve existir após substituição.")

	testes_passaram += 1
	print("[TESTE 2/5 PASSOU] Gravação atômica com substituição segura e remoção de arquivo temporário homologada.")

func _testar_migracao_de_esquema() -> void:
	# Simula um save legado gerado na versão 1 (sem level_path, sem score, sem checkpoint_id)
	var dados_v1: Dictionary = {
		"version": 1,
		"level": "02",
		"player_health": 1,
		"max_health": 3
	}

	# Testa a função de migração direta
	var dados_migrados: Dictionary = save_manager.migrar_dados(dados_v1)
	assert(int(dados_migrados["version"]) == 2, "Versão migrada deve ser 2.")
	assert(str(dados_migrados["level_path"]) == "res://src/levels/level_02.tscn", "Migração de 'level' para 'level_path' falhou.")
	assert(int(dados_migrados["score"]) == 0, "Score padrão deve ser 0 na migração.")
	assert(str(dados_migrados["checkpoint_id"]) == "", "Checkpoint padrão deve ser vazio na migração.")

	# Salva o arquivo em formato v1 no disco e executa carregar_jogo
	var arq: FileAccess = FileAccess.open(TEST_SAVE_V1, FileAccess.WRITE)
	assert(arq != null, "Deve abrir arquivo v1 para escrita.")
	arq.store_string(JSON.stringify(dados_v1))
	arq.close()

	save_manager.reiniciar_sessao()
	var carregou: bool = save_manager.carregar_jogo(TEST_SAVE_V1)
	assert(carregou, "carregar_jogo deve executar migração transparente sem falhas.")
	assert(save_manager.current_level_path == "res://src/levels/level_02.tscn", "Fase migrada carregada incorretamente.")
	assert(save_manager.player_health == 1, "Vida v1 preservada incorretamente.")
	assert(save_manager.score == 0, "Score migrado incorretamente.")

	testes_passaram += 1
	print("[TESTE 3/5 PASSOU] Migração de esquema (Versão 1 -> Versão 2) validada com sucesso.")

func _testar_sanitizacao_e_dados_invalidos() -> void:
	# Cenário A: Arquivo com string que não é JSON
	var arq_corrupt: FileAccess = FileAccess.open(TEST_SAVE_CORRUPT, FileAccess.WRITE)
	assert(arq_corrupt != null, "Deve abrir arquivo corrompido para teste.")
	arq_corrupt.store_string("{ ISSO NÃO É UM JSON VÁLIDO: 999 }")
	arq_corrupt.close()

	var carregou_corrupt: bool = save_manager.carregar_jogo(TEST_SAVE_CORRUPT)
	assert(not carregou_corrupt, "carregar_jogo deve rejeitar JSON corrompido e retornar false sem crash.")

	# Cenário B: Dados com nível inexistente
	var dados_fase_fantasma: Dictionary = {
		"version": 2,
		"level_path": "res://src/levels/fase_fantasma_inexistente.tscn",
		"player_health": 3,
		"max_health": 3,
		"score": 100
	}
	assert(not save_manager.validar_dados(dados_fase_fantasma), "Validação deve reprovar level_path inexistente.")

	# Cenário C: Dados com vida negativa ou zero
	var dados_vida_morta: Dictionary = {
		"version": 2,
		"level_path": "res://src/levels/level_01.tscn",
		"player_health": 0,
		"max_health": 3,
		"score": 100
	}
	assert(not save_manager.validar_dados(dados_vida_morta), "Validação deve reprovar vida zerada ou negativa.")

	# Cenário D: Pontuação negativa
	var dados_score_negativo: Dictionary = {
		"version": 2,
		"level_path": "res://src/levels/level_01.tscn",
		"player_health": 3,
		"max_health": 3,
		"score": -50
	}
	assert(not save_manager.validar_dados(dados_score_negativo), "Validação deve reprovar pontuação negativa.")

	testes_passaram += 1
	print("[TESTE 4/5 PASSOU] Sanitização e rejeição defensiva de dados inválidos ou corrompidos homologada.")

func _testar_checkpoint_e_respawn() -> void:
	# Cria e instancia um nó de Checkpoint via script pré-carregado
	var cp: Area2D = CHECKPOINT_SCRIPT.new()
	cp.checkpoint_id = "cp_unit_test"
	cp.global_position = Vector2(750.0, 500.0)
	cp.spawn_offset = Vector2(0.0, -10.0)
	add_child(cp)

	save_manager.reiniciar_sessao()
	assert(save_manager.current_checkpoint_id == "", "Sessão nova não deve ter checkpoint ativo.")

	# Ativa o checkpoint diretamente
	cp.ativar(false)
	save_manager.registrar_checkpoint(cp.checkpoint_id, cp.obter_spawn_position(), false)

	assert(save_manager.current_checkpoint_id == "cp_unit_test", "ID do checkpoint deve ser registrado.")
	assert(save_manager.current_spawn_position == Vector2(750.0, 490.0), "Posição de respawn deve incluir offset.")

	# Testa o método obter_ponto_respawn
	var respawn: Vector2 = save_manager.obter_ponto_respawn(Vector2.ZERO)
	assert(respawn == Vector2(750.0, 490.0), "obter_ponto_respawn deve retornar o checkpoint registrado.")

	cp.queue_free()

	testes_passaram += 1
	print("[TESTE 5/5 PASSOU] Ativação de checkpoints, cálculo de respawn e registro de sessão homologados.")

func _limpar_arquivos_teste() -> void:
	if FileAccess.file_exists(TEST_SAVE_ATOMIC):
		DirAccess.remove_absolute(TEST_SAVE_ATOMIC)
	if FileAccess.file_exists(TEST_SAVE_ATOMIC + ".tmp"):
		DirAccess.remove_absolute(TEST_SAVE_ATOMIC + ".tmp")
	if FileAccess.file_exists(TEST_SAVE_V1):
		DirAccess.remove_absolute(TEST_SAVE_V1)
	if FileAccess.file_exists(TEST_SAVE_CORRUPT):
		DirAccess.remove_absolute(TEST_SAVE_CORRUPT)

func _concluir_testes() -> void:
	assert(testes_passaram == 5, "Todos os 5 testes de persistência devem passar.")
	print("------------------------------------------------------------")
	print("TODOS OS %d TESTES DE PERSISTÊNCIA, CHECKPOINTS E PROGRESSÃO APROVADOS COM SUCESSO." % testes_passaram)
	print("------------------------------------------------------------")
	get_tree().quit(0)
