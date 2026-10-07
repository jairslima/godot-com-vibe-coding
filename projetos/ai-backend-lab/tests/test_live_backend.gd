# ARQUIVO: res://tests/test_live_backend.gd
# ANEXAR AO NODE: TestLiveBackend (Node)
# CENA: res://tests/test_live_backend.tscn
# INPUTS NECESSÁRIOS: nenhum (teste automatizado de integração de rede)
# DEPENDÊNCIAS: AiNetworkClient (res://src/ai_network_client.gd), servidor server/mock_ai_server.py ativo
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: validação de integração ponta a ponta com servidor mock local em loopback HTTP
extends Node

@onready var client: AiNetworkClient = $AiNetworkClient

var _step: int = 0
var _success: bool = false


func _ready() -> void:
	print("==================================================")
	print("INICIANDO TESTE DE INTEGRAÇÃO: Loopback HTTP Real")
	print("==================================================")

	client.response_received.connect(_on_response_received)
	client.request_failed.connect(_on_request_failed)

	_run_step_1_valid_request()


func _run_step_1_valid_request() -> void:
	_step = 1
	print("[Etapa 1] Disparando requisição real de diálogo sobre porta 8088...")
	var err: Error = client.send_dialogue_request("Status da energia", "sentinela_01")
	if err != OK:
		printerr("Erro ao disparar etapa 1: %d" % err)
		get_tree().quit(1)


func _run_step_2_invalid_token() -> void:
	_step = 2
	print("\n[Etapa 2] Disparando requisição com token incorreto (esperando 401)...")
	client.auth_token = "token-falso-invalido"
	var err: Error = client.send_dialogue_request("Mensagem de teste", "sentinela_01")
	if err != OK:
		printerr("Erro ao disparar etapa 2: %d" % err)
		get_tree().quit(1)


func _on_response_received(reply: String, metadata: Dictionary) -> void:
	if _step == 1:
		print("  [OK] Resposta recebida do servidor mock: %s" % reply)
		print("  [OK] Metadados: tokens=%s, npc=%s" % [metadata.get("tokens_used"), metadata.get("npc_id")])
		assert("geradores" in reply.to_lower() or "setor" in reply.to_lower())
		# Aguarda breve intervalo e roda etapa 2
		await get_tree().create_timer(0.4).timeout
		_run_step_2_invalid_token()
	else:
		printerr("  [FALHA] Resposta inesperada recebida no passo %d" % _step)
		get_tree().quit(1)


func _on_request_failed(error_message: String, fallback_used: bool, fallback_reply: String) -> void:
	if _step == 2:
		print("  [OK] Falha esperada recebida: %s" % error_message)
		print("  [OK] Fallback offline ativado: %s" % fallback_reply)
		assert(fallback_used == true)
		assert("401" in error_message)
		print("\n==================================================")
		print("INTEGRAÇÃO PONTA A PONTA HOMOLOGADA COM SUCESSO!")
		print("==================================================")
		get_tree().quit(0)
	else:
		printerr("  [FALHA] Falha na etapa 1: %s (fallback: %s)" % [error_message, fallback_reply])
		get_tree().quit(1)
