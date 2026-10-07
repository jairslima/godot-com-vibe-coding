# ARQUIVO:
# res://tests/test_license_manager.gd
#
# ANEXAR AO NODE:
# TestLicenseManager (Node)
#
# CENA:
# res://tests/test_license_manager.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum.
#
# DEPENDÊNCIAS:
# res://src/core/license_manager.gd e res://assets/LICENSES.md
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Executa 6 asserções automatizadas em modo headless validando a extração da licença MIT do Godot,
# o catálogo de licenças de terceiros, a leitura e auditoria estrutural do Asset Ledger (LICENSES.md)
# e encerra com código de saída 0.

extends Node

const LicenseManagerScript = preload("res://src/core/license_manager.gd")

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: AUDITORIA DE LICENÇAS E ASSETS (GODOT 4.7.2)")
	print("==================================================")
	
	var manager = LicenseManagerScript.new()
	add_child(manager)
	
	var falhas: int = 0
	
	# Teste 1: Validação do texto da licença MIT do Godot Engine
	var texto_mit: String = manager.obter_licenca_godot()
	if not texto_mit.is_empty() and texto_mit.contains("Godot Engine") and texto_mit.contains("MIT"):
		print("[TESTE 1/6 APROVADO] Licença MIT da engine extraída com sucesso via Engine.get_license_text().")
	else:
		push_error("[TESTE 1/6 FALHOU] Texto da licença MIT do Godot inválido ou vazio.")
		falhas += 1
	
	# Teste 2: Catálogo de bibliotecas de terceiros compiladas
	var licencas_terceiros: Array[String] = manager.obter_resumo_terceiros()
	if licencas_terceiros.size() >= 5:
		print("[TESTE 2/6 APROVADO] Mapeamento de %d licenças de terceiros obtido via Engine.get_license_info()." % licencas_terceiros.size())
	else:
		push_error("[TESTE 2/6 FALHOU] Lista de licenças de terceiros insuficiente (esperado >= 5).")
		falhas += 1
	
	# Teste 3: Metadados detalhados de copyright do motor
	var copyright_info: Array[Dictionary] = manager.obter_detalhes_copyright()
	if copyright_info.size() > 0 and copyright_info[0].has("name"):
		print("[TESTE 3/6 APROVADO] Informações de copyright de %d componentes obtidas com sucesso." % copyright_info.size())
	else:
		push_error("[TESTE 3/6 FALHOU] Estrutura de copyright da engine ausente ou incompatível.")
		falhas += 1
	
	# Teste 4: Leitura física do Asset Ledger no disco virtual
	var conteudo_ledger: String = manager.carregar_ledger()
	if not conteudo_ledger.is_empty() and conteudo_ledger.contains("Registro de Procedência de Assets"):
		print("[TESTE 4/6 APROVADO] Arquivo res://assets/LICENSES.md carregado com integridade.")
	else:
		push_error("[TESTE 4/6 FALHOU] Falha ao carregar res://assets/LICENSES.md.")
		falhas += 1
	
	# Teste 5: Auditoria estrutural e conformidade de status comercial do Ledger
	var auditoria: Dictionary = manager.auditar_ledger()
	if auditoria["valido"] and auditoria["total_assets"] >= 8 and auditoria["aprovados"] >= 8 and auditoria["erros"].size() == 0:
		print("[TESTE 5/6 APROVADO] Auditoria do Asset Ledger: %d ativos aprovados, 0 erros e estrutura conforme." % auditoria["total_assets"])
	else:
		push_error("[TESTE 5/6 FALHOU] Auditoria do Asset Ledger reprovada: %s" % str(auditoria))
		falhas += 1
	
	# Teste 6: Geração de texto consolidado de créditos para o jogo
	var texto_creditos: String = manager.gerar_texto_creditos()
	if texto_creditos.contains("ESTAÇÃO SOBREVIVÊNCIA") and texto_creditos.contains("AVISO DE LICENÇA DO GODOT ENGINE") and texto_creditos.contains("BIBLIOTECAS DE TERCEIROS"):
		print("[TESTE 6/6 APROVADO] Documento de créditos e licenças gerado corretamente para UI e distribuição.")
	else:
		push_error("[TESTE 6/6 FALHOU] Formatação de créditos incompleta ou corrompida.")
		falhas += 1
	
	print("--------------------------------------------------")
	if falhas == 0:
		print("RESULTADO: 6/6 asserções aprovadas com sucesso.")
		print("==================================================")
		get_tree().quit(0)
	else:
		push_error("RESULTADO: %d falha(s) detectada(s) na auditoria de licenças." % falhas)
		print("==================================================")
		get_tree().quit(1)
