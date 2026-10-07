extends Node

# Suíte de testes automatizados headless para a camada de serviços de loja (StoreManager)
# Executada via CLI headless: godot_console --headless --path "projetos/estacao-sobrevivencia" --scene res://tests/test_store_manager.tscn --quit-after 10

const StoreManagerClass = preload("res://src/core/store_manager.gd")

var _conquista_recebida: String = ""
var _stat_recebida: String = ""
var _valor_stat_recebido: int = 0
var _sincronizacao_recebida: bool = false

func _ready() -> void:
	print("[TEST_STORE_MANAGER] Iniciando validacao da camada de servicos de loja...")
	
	var store_mgr = StoreManagerClass.new()
	add_child(store_mgr)
	
	store_mgr.conquista_desbloqueada.connect(func(id: String): _conquista_recebida = id)
	store_mgr.estatistica_atualizada.connect(func(id: String, val: int):
		_stat_recebida = id
		_valor_stat_recebido = val
	)
	store_mgr.sincronizacao_concluida.connect(func(sucesso: bool): _sincronizacao_recebida = sucesso)
	
	# Asserção 1: Inicialização em contingência/modo simulado quando GDExtension não está presente
	assert(store_mgr.esta_em_modo_simulado() == true, "Em ambiente headless/sem Steamworks nativo, StoreManager deve operar em modo simulado")
	print("[TEST_STORE_MANAGER] Assercao 1 aprovada: Modo simulado de contingencia ativado.")
	
	# Asserção 2: Desbloqueio de conquista inicial
	var res_conquista: bool = store_mgr.desbloquear_conquista("PRIMEIRA_ONDA")
	assert(res_conquista == true, "Desbloqueio de conquista valida deve retornar true")
	assert(_conquista_recebida == "PRIMEIRA_ONDA", "Sinal de conquista deve emitir o identificador correto")
	print("[TEST_STORE_MANAGER] Assercao 2 aprovada: Conquista desbloqueada e sinal capturado.")
	
	# Asserção 3: Idempotência de conquista (evitar duplicação)
	var res_conquista_rep: bool = store_mgr.desbloquear_conquista("PRIMEIRA_ONDA")
	assert(res_conquista_rep == true, "Re-desbloqueio de conquista deve ser tolerado com sucesso")
	var conquistas: Array[String] = store_mgr.obter_conquistas()
	assert(conquistas.size() == 1, "Conquistas nao devem ser duplicadas no inventario local")
	print("[TEST_STORE_MANAGER] Assercao 3 aprovada: Idempotencia de conquistas confirmada.")
	
	# Asserção 4: Atualização e recuperação de estatística
	var res_stat: bool = store_mgr.definir_estatistica("CRIATURAS_DISPERSAS", 25)
	assert(res_stat == true, "Gravacao de estatistica deve retornar true")
	assert(_stat_recebida == "CRIATURAS_DISPERSAS" and _valor_stat_recebido == 25, "Sinal de estatistica deve refletir os novos valores")
	assert(store_mgr.obter_estatistica("CRIATURAS_DISPERSAS") == 25, "Valor recuperado deve corresponder ao valor gravado")
	print("[TEST_STORE_MANAGER] Assercao 4 aprovada: Estatisticas de jogo atualizadas com sucesso.")
	
	# Asserção 5: Sincronização em nuvem e persistência em user://
	var res_sync: bool = store_mgr.sincronizar_nuvem()
	assert(res_sync == true, "Sincronizacao deve retornar true")
	assert(_sincronizacao_recebida == true, "Sinal de sincronizacao concluida deve ser emitido")
	
	var caminho_dados: String = "user://mock_store_data.json"
	assert(FileAccess.file_exists(caminho_dados), "Arquivo de persistencia simulada de loja deve existir em user://")
	print("[TEST_STORE_MANAGER] Assercao 5 aprovada: Sincronizacao e persistencia local confirmadas.")
	
	# Asserção 6: Validação do conteúdo JSON persistido
	var f: FileAccess = FileAccess.open(caminho_dados, FileAccess.READ)
	assert(f != null, "Falha ao abrir arquivo de dados de loja em user://")
	var conteudo: String = f.get_as_text()
	f.close()
	var json_parsed = JSON.parse_string(conteudo)
	assert(json_parsed is Dictionary, "Conteudo persistido deve ser um dicionario JSON valido")
	assert(json_parsed.has("conquistas") and json_parsed["conquistas"].has("PRIMEIRA_ONDA"), "JSON deve conter a conquista registrada")
	print("[TEST_STORE_MANAGER] Assercao 6 aprovada: Integridade estrutural do arquivo JSON confirmada.")
	
	# Limpeza de rascunhos de teste
	DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho_dados))
	print("[TEST_STORE_MANAGER] Limpeza de arquivo temporario de teste concluida.")
	
	print("[TEST_STORE_MANAGER] SUCESSO: Todas as 6 assercoes da camada de loja foram aprovadas.")
	store_mgr.queue_free()
	get_tree().quit(0)
