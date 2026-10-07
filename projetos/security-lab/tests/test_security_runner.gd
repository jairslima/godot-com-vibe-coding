# ARQUIVO: res://tests/test_security_runner.gd
# ANEXAR AO NODE: TestSecurityRunner (Node)
# CENA: res://tests/test_security_runner.tscn
# INPUTS NECESSARIOS: Nenhum
# DEPENDENCIAS: res://src/score_service.gd
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: 6 assercoes de persistencia segura e defensiva aprovadas
extends Node

const ScoreService = preload("res://src/score_service.gd")

func _ready() -> void:
	print("--- INICIANDO TESTES DO SECURITY LAB ---")
	
	# Garante estado limpo inicial
	ScoreService.limpar_registros()
	
	# Teste 1: Rejeicao de pontuacao negativa
	var resultado_negativo: bool = ScoreService.registrar_pontuacao("Alice", -50)
	assert(not resultado_negativo, "Assercao 1 Falhou: Pontuacao negativa nao deve ser aceita.")
	print("[PASSOU] Teste 1: Pontuacao negativa rejeitada com sucesso.")
	
	# Teste 2: Sanitizacao e truncamento de nome longo
	var nome_longo: String = "JogadorSuperLongoDemaisParaCaberNoRegistro"
	var sucesso_salvar: bool = ScoreService.registrar_pontuacao(nome_longo, 100)
	assert(sucesso_salvar, "Assercao 2 Falhou: Salvamento legitimo deve retornar true.")
	var lista_1: Array = ScoreService.carregar_pontuacoes()
	assert(lista_1.size() == 1, "Assercao 2 Falhou: Deve haver exatamente 1 registro.")
	assert(lista_1[0]["nome"].length() <= 16, "Assercao 2 Falhou: Nome deve ter no maximo 16 caracteres.")
	print("[PASSOU] Teste 2: Nome longo truncado defensivamente.")
	
	# Teste 3: Ordenacao correta decrescente
	ScoreService.registrar_pontuacao("Bob", 250)
	ScoreService.registrar_pontuacao("Carlos", 180)
	var lista_2: Array = ScoreService.carregar_pontuacoes()
	assert(lista_2.size() == 3, "Assercao 3 Falhou: Deve haver 3 registros.")
	assert(lista_2[0]["pontos"] == 250, "Assercao 3 Falhou: O topo deve ser 250 pontos.")
	assert(lista_2[1]["pontos"] == 180, "Assercao 3 Falhou: A segunda posicao deve ser 180 pontos.")
	assert(lista_2[2]["pontos"] == 100, "Assercao 3 Falhou: A terceira posicao deve ser 100 pontos.")
	print("[PASSOU] Teste 3: Ordenacao decrescente validada.")
	
	# Teste 4: Limite maximo de entradas
	for i in range(15):
		ScoreService.registrar_pontuacao("Player_" + str(i), 10 + i)
	var lista_max: Array = ScoreService.carregar_pontuacoes()
	assert(lista_max.size() == ScoreService.MAX_ENTRIES, "Assercao 4 Falhou: Nao deve exceder o limite de 10 entradas.")
	print("[PASSOU] Teste 4: Limite maximo de entradas respeitado.")
	
	# Teste 5: Dados ausentes ou inexistentes retornam array vazio seguro
	ScoreService.limpar_registros()
	var lista_vazia: Array = ScoreService.carregar_pontuacoes()
	assert(lista_vazia.is_empty(), "Assercao 5 Falhou: Arquivo inexistente deve retornar array vazio sem travar.")
	print("[PASSOU] Teste 5: Carregamento defensivo sem falha em arquivo inexistente.")
	
	# Teste 6: Limpeza final confirmada
	assert(not FileAccess.file_exists(ScoreService.SAVE_PATH), "Assercao 6 Falhou: Arquivo deve ter sido removido.")
	print("[PASSOU] Teste 6: Limpeza de registros confirmada.")
	
	print("[SUCESSO] Todas as 6 assercoes do Security Lab foram aprovadas!")
	get_tree().quit(0)
