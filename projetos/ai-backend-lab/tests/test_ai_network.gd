# ARQUIVO: res://tests/test_ai_network.gd
# ANEXAR AO NODE: TestAiNetwork (Node)
# CENA: res://tests/test_ai_network.tscn
# INPUTS NECESSÁRIOS: nenhum (suíte automatizada de testes headless)
# DEPENDÊNCIAS: AiNetworkClient (res://src/ai_network_client.gd)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: validação de 6 asserções de contrato de rede, decodificação JSON e contingência offline
extends Node

var _tests_passed: int = 0
var _tests_failed: int = 0


func _ready() -> void:
	print("==================================================")
	print("INICIANDO SUÍTE DE TESTES: AI Backend Lab (Cap. 38)")
	print("Versão do Motor: %s" % Engine.get_version_info().string)
	print("==================================================")

	_run_all_tests()

	print("==================================================")
	print("RESUMO DOS TESTES: %d aprovados, %d falhas." % [_tests_passed, _tests_failed])
	print("==================================================")

	if _tests_failed == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _run_all_tests() -> void:
	_test_01_client_initialization()
	_test_02_offline_fallback_logic()
	_test_03_http_401_unauthorized_handling()
	_test_04_network_timeout_handling()
	_test_05_successful_json_response_handling()
	_test_06_malformed_json_handling()


func _assert(condition: bool, test_name: String) -> void:
	if condition:
		_tests_passed += 1
		print("  [OK] %s" % test_name)
	else:
		_tests_failed += 1
		printerr("  [FALHA] %s" % test_name)


func _test_01_client_initialization() -> void:
	print("\n[Teste 1] Inicialização e configuração do nó HTTPRequest")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var http_child: HTTPRequest = client.get_node_or_null("HTTPRequest") as HTTPRequest
	_assert(http_child != null, "Nó filho HTTPRequest criado dinamicamente")
	_assert(http_child.timeout == client.request_timeout, "Propriedade timeout propagada corretamente")
	_assert(http_child.use_threads == true, "Multithreading habilitado no HTTPRequest")

	client.queue_free()


func _test_02_offline_fallback_logic() -> void:
	print("\n[Teste 2] Resposta de contingência offline determinística")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var reply_energy: String = client.get_offline_fallback("Como está a energia do reator?", "drone_01")
	_assert("drone_01" in reply_energy, "Nome do NPC preservado na resposta de contingência")
	_assert("energia" in reply_energy.to_lower(), "Palavra-chave de energia identificada no fallback local")

	var reply_default: String = client.get_offline_fallback("Pergunta genérica qualquer", "guarda_02")
	_assert("pré-gravada" in reply_default or "contingência" in reply_default or "alcance" in reply_default, "Resposta padrão retornada para prompt sem palavra-chave")

	client.queue_free()


func _test_03_http_401_unauthorized_handling() -> void:
	print("\n[Teste 3] Tratamento de falha de autenticação (HTTP 401)")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var event_tracker: Dictionary = {
		"failed_emitted": false,
		"fallback_activated": false,
		"error_received": ""
	}

	client.request_failed.connect(func(msg: String, fallback_used: bool, _reply: String) -> void:
		event_tracker["failed_emitted"] = true
		event_tracker["fallback_activated"] = fallback_used
		event_tracker["error_received"] = msg
	)

	# Simula retorno do nó HTTPRequest com status 401
	client._pending_prompt = "Olá"
	client._pending_npc = "npc_01"
	var dummy_headers: PackedStringArray = PackedStringArray()
	var error_body: PackedByteArray = "{\"error\": \"unauthorized\"}".to_utf8_buffer()

	client._on_request_completed(HTTPRequest.RESULT_SUCCESS, 401, dummy_headers, error_body)

	_assert(event_tracker["failed_emitted"] == true, "Sinal request_failed emitido para HTTP 401")
	_assert(event_tracker["fallback_activated"] == true, "Fallback offline ativado após rejeição de credencial")
	_assert("401" in str(event_tracker["error_received"]), "Mensagem de erro contém código HTTP 401")

	client.queue_free()


func _test_04_network_timeout_handling() -> void:
	print("\n[Teste 4] Tratamento de timeout de rede (RESULT_TIMEOUT)")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var event_tracker: Dictionary = {
		"failed_emitted": false,
		"fallback_activated": false,
		"error_received": ""
	}

	client.request_failed.connect(func(msg: String, fallback_used: bool, _reply: String) -> void:
		event_tracker["failed_emitted"] = true
		event_tracker["fallback_activated"] = fallback_used
		event_tracker["error_received"] = msg
	)

	client._pending_prompt = "Preciso de socorro"
	client._pending_npc = "npc_02"
	var dummy_headers: PackedStringArray = PackedStringArray()
	var empty_body: PackedByteArray = PackedByteArray()

	# Simula esgotamento de tempo limite
	client._on_request_completed(HTTPRequest.RESULT_TIMEOUT, 0, dummy_headers, empty_body)

	_assert(event_tracker["failed_emitted"] == true, "Sinal request_failed emitido para timeout")
	_assert(event_tracker["fallback_activated"] == true, "Fallback offline ativado após timeout")
	var err_str: String = str(event_tracker["error_received"]).to_lower()
	_assert("timeout" in err_str or "limite" in err_str, "Mensagem explicita esgotamento do tempo limite")

	client.queue_free()


func _test_05_successful_json_response_handling() -> void:
	print("\n[Teste 5] Decodificação de resposta JSON válida com sucesso (HTTP 200)")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var event_tracker: Dictionary = {
		"success_emitted": false,
		"reply_text": "",
		"tokens_count": 0
	}

	client.response_received.connect(func(reply: String, meta: Dictionary) -> void:
		event_tracker["success_emitted"] = true
		event_tracker["reply_text"] = reply
		event_tracker["tokens_count"] = int(meta.get("tokens_used", 0))
	)

	var valid_json_str: String = JSON.stringify({
		"status": "ok",
		"npc_id": "sentinela_01",
		"reply": "Patrulha sem intercorrências no quadrante C.",
		"tokens_used": 14,
		"cached": false
	})

	var dummy_headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	client._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, dummy_headers, valid_json_str.to_utf8_buffer())

	_assert(event_tracker["success_emitted"] == true, "Sinal response_received emitido para resposta 200 OK")
	_assert(event_tracker["reply_text"] == "Patrulha sem intercorrências no quadrante C.", "Texto decodificado com fidelidade")
	_assert(event_tracker["tokens_count"] == 14, "Metadados de telemetria (tokens) extraídos com sucesso")

	client.queue_free()


func _test_06_malformed_json_handling() -> void:
	print("\n[Teste 6] Resiliência contra payload JSON corrompido ou malformado")
	var client: AiNetworkClient = AiNetworkClient.new()
	add_child(client)

	var event_tracker: Dictionary = {
		"failed_emitted": false,
		"fallback_activated": false
	}

	client.request_failed.connect(func(_msg: String, fallback_used: bool, _reply: String) -> void:
		event_tracker["failed_emitted"] = true
		event_tracker["fallback_activated"] = fallback_used
	)

	client._pending_prompt = "Teste de estresse"
	client._pending_npc = "npc_03"
	var dummy_headers: PackedStringArray = PackedStringArray()
	var corrupted_body: PackedByteArray = "<invalido>corrompido</invalido>".to_utf8_buffer()

	client._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, dummy_headers, corrupted_body)

	_assert(event_tracker["failed_emitted"] == true, "Sinal request_failed emitido para JSON inválido")
	_assert(event_tracker["fallback_activated"] == true, "Fallback offline ativado prevenindo travamento do jogo")

	client.queue_free()
