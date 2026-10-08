# ARQUIVO:
# res://tests/test_compliance_manager.gd
#
# ANEXAR AO NODE:
# TestComplianceManager (Node)
#
# CENA:
# res://tests/test_compliance_manager.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum.
#
# DEPENDÊNCIAS:
# res://src/core/compliance_manager.gd e res://docs/PROVENANCE.md
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Executa 6 asserções de conformidade jurídica, declaração para Steamworks Content Survey
# e validação de privacidade LGPD/GDPR com retorno limpo no terminal e código de saída 0.

extends Node

## Inventário FICTÍCIO usado só para demonstrar o auditor (o registro real do projeto está em docs/PROVENANCE.md).
const PROVENANCE_EXEMPLO: String = "res://tests/fixtures/PROVENANCE_exemplo.md"

const ComplianceManagerScript = preload("res://src/core/compliance_manager.gd")

func _ready() -> void:
	print("--- INICIANDO TESTES DO COMPLIANCE MANAGER (CAPÍTULO 48) ---")
	
	var manager = ComplianceManagerScript.new()
	add_child(manager)
	
	# Teste 1: Licença do Godot Engine
	var licenca: String = manager.obter_licenca_engine()
	assert(not licenca.is_empty(), "Falha: O texto da licença MIT do Godot Engine não deve ser vazio.")
	assert(licenca.contains("Permission is hereby granted"), "Falha: O texto deve conter a cláusula padrão da licença MIT.")
	print("[OK] Teste 1: Licença oficial do Godot Engine extraída com sucesso.")
	
	# Teste 2: Auditoria de procedência sobre o inventário de exemplo (fictício, com 8 ativos)
	var auditoria: Dictionary = manager.auditar_provenance(PROVENANCE_EXEMPLO)
	assert(auditoria["valido"] == true, "Falha: A auditoria do arquivo PROVENANCE.md deve ser válida.")
	assert(auditoria["total_ativos"] == 8, "Falha: O total de ativos catalogados deve ser 8.")
	assert(auditoria["pre_gerados"] == 2, "Falha: Devem constar exatamente 2 ativos com categoria pré-gerada.")
	assert(auditoria["gerados_ao_vivo"] == 0, "Falha: O projeto atual não possui geração ao vivo em runtime.")
	assert(auditoria["aprovados"] == 8, "Falha: Todos os 8 ativos devem estar com status APROVADO.")
	print("[OK] Teste 2: Auditoria do PROVENANCE.md concluiu com contagem exata e conformidade.")
	
	# Teste 3: Geração de declaração para Steamworks Content Survey
	var declaracao: Dictionary = manager.gerar_declaracao_steam_survey(auditoria)
	assert(declaracao["uses_ai_content"] == true, "Falha: O jogo deve declarar uso de IA.")
	assert(declaracao["has_pre_generated_content"] == true, "Falha: Deve indicar conteúdo pré-gerado.")
	assert(declaracao["has_live_generated_content"] == false, "Falha: Não deve indicar geração ao vivo.")
	assert(declaracao["adult_only_live_content"] == false, "Falha: Conteúdo adulto ao vivo deve ser falso.")
	assert(declaracao["store_page_disclosure"].length() > 50, "Falha: O texto de divulgação da loja deve ser detalhado.")
	print("[OK] Teste 3: Declaração para Steamworks Content Survey gerada com sucesso.")
	
	# Teste 4: Telemetria anônima conforme (LGPD/GDPR)
	var payload_anonimo: Dictionary = {
		"session_uuid": "550e8400-e29b-41d4-a716-446655440000",
		"wave_maxima": 12,
		"duracao_segundos": 340.5,
		"pontuacao": 1850
	}
	var res_privacidade_ok: Dictionary = manager.validar_privacidade_telemetria(payload_anonimo)
	assert(res_privacidade_ok["conforme"] == true, "Falha: Payload anônimo deve ser aprovado.")
	assert(res_privacidade_ok["violacoes"].is_empty(), "Falha: Não deve haver violações de PII no payload anônimo.")
	print("[OK] Teste 4: Minimização de dados de telemetria validada com sucesso.")
	
	# Teste 5: Detecção de dados sensíveis proibidos (PII)
	var payload_sensivel: Dictionary = {
		"session_uuid": "abc-123",
		"email": "jogador@exemplo.com",
		"steam_id_usuario": "76561198000000000",
		"pontuacao": 500
	}
	var res_privacidade_falha: Dictionary = manager.validar_privacidade_telemetria(payload_sensivel)
	assert(res_privacidade_falha["conforme"] == false, "Falha: Payload com email e steam_id deve ser rejeitado.")
	assert(res_privacidade_falha["violacoes"].size() >= 2, "Falha: Devem ser detectadas pelo menos 2 violações de PII.")
	print("[OK] Teste 5: Chaves sensíveis proibidas identificadas e bloqueadas com sucesso.")
	
	# Teste 6: Simulação de cenário com IA Live-Generated e guardrails
	var auditoria_simulada_live: Dictionary = {
		"pre_gerados": 1,
		"gerados_ao_vivo": 1,
		"humanos_ou_hibridos": 2
	}
	var declaracao_live: Dictionary = manager.gerar_declaracao_steam_survey(auditoria_simulada_live)
	assert(declaracao_live["has_live_generated_content"] == true, "Falha: Deve indicar conteúdo ao vivo.")
	assert(declaracao_live["guardrails_description"].contains("Filtro de vocabulário"), "Falha: Guardrails devem ser descritos.")
	print("[OK] Teste 6: Simulação de Live-Generated e guardrails estruturada com sucesso.")
	
	manager.queue_free()
	print("--- TODOS OS 6 TESTES DO COMPLIANCE MANAGER PASSARAM COM SUCESSO ---")
	get_tree().quit(0)
