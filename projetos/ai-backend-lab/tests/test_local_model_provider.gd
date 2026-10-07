# ARQUIVO: res://tests/test_local_model_provider.gd
# ANEXAR AO NODE: TestLocalModelProvider (Node)
# CENA: res://tests/test_local_model_provider.tscn
# INPUTS NECESSÁRIOS: nenhum (validação de asserções em modo headless)
# DEPENDÊNCIAS: res://src/local_model_provider.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: validação de contratos, portas padrão, montagem de payloads e extração de esquemas de Ollama, LM Studio e llama.cpp
class_name TestLocalModelProvider
extends Node

const LocalModelProviderClass = preload("res://src/local_model_provider.gd")

var _tests_passed: int = 0
var _tests_failed: int = 0


func _ready() -> void:
	print("[TestLocalModelProvider] Iniciando testes do provedor de modelos locais...")
	_run_all_tests()
	_print_summary()
	if _tests_failed == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _run_all_tests() -> void:
	test_default_ports_and_endpoints()
	test_custom_url_override()
	test_payload_construction_ollama()
	test_payload_construction_openai_compat()
	test_response_parsing_ollama()
	test_response_parsing_openai_and_lmstudio()
	test_response_parsing_llamacpp_direct()
	test_offline_fallback_logic()
	test_malformed_response_handling()


func _assert_true(condition: bool, test_name: String) -> void:
	if condition:
		_tests_passed += 1
		print("  [OK] %s" % test_name)
	else:
		_tests_failed += 1
		printerr("  [FALHA] %s" % test_name)


func test_default_ports_and_endpoints() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	# Ollama
	provider.provider_type = LocalModelProviderClass.ProviderType.OLLAMA
	_assert_true(provider.get_default_port(provider.provider_type) == 11434, "Porta padrão do Ollama é 11434")
	_assert_true(provider.get_endpoint_url() == "http://127.0.0.1:11434/api/chat", "Endpoint padrão do Ollama é /api/chat na porta 11434")

	# LM Studio
	provider.provider_type = LocalModelProviderClass.ProviderType.LM_STUDIO
	_assert_true(provider.get_default_port(provider.provider_type) == 1234, "Porta padrão do LM Studio é 1234")
	_assert_true(provider.get_endpoint_url() == "http://127.0.0.1:1234/v1/chat/completions", "Endpoint padrão do LM Studio é /v1/chat/completions na porta 1234")

	# llama.cpp
	provider.provider_type = LocalModelProviderClass.ProviderType.LLAMA_CPP
	_assert_true(provider.get_default_port(provider.provider_type) == 8080, "Porta padrão do llama.cpp é 8080")
	_assert_true(provider.get_endpoint_url() == "http://127.0.0.1:8080/v1/chat/completions", "Endpoint padrão do llama.cpp é /v1/chat/completions na porta 8080")

	provider.queue_free()


func test_custom_url_override() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	provider.provider_type = LocalModelProviderClass.ProviderType.CUSTOM_OPENAI
	provider.base_url = "http://192.168.1.50:9000"
	_assert_true(provider.get_endpoint_url() == "http://192.168.1.50:9000/v1/chat/completions", "URL customizada recebe o caminho /v1/chat/completions")

	provider.provider_type = LocalModelProviderClass.ProviderType.OLLAMA
	provider.base_url = "http://localhost:11434"
	_assert_true(provider.get_endpoint_url() == "http://localhost:11434/api/chat", "URL customizada Ollama recebe o caminho /api/chat")

	provider.queue_free()


func test_payload_construction_ollama() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	provider.provider_type = LocalModelProviderClass.ProviderType.OLLAMA
	provider.model_name = "llama3.2:latest"
	provider.temperature = 0.5
	provider.max_tokens = 200

	var payload: Dictionary = provider.build_payload("Você é um robô de manutenção.", "Qual o estado do setor B?")
	_assert_true(payload["model"] == "llama3.2:latest", "Payload Ollama define o modelo correto")
	_assert_true(payload["stream"] == false, "Payload Ollama define stream como falso para requisição bloqueante")

	var msgs: Array = payload["messages"]
	_assert_true(msgs.size() == 2, "Payload possui duas mensagens (system e user)")
	_assert_true(msgs[0]["role"] == "system" and msgs[1]["role"] == "user", "Papéis system e user estão ordenados")

	var opts: Dictionary = payload["options"]
	_assert_true(opts["temperature"] == 0.5, "Opção temperature repassada corretamente ao Ollama")
	_assert_true(opts["num_predict"] == 200, "Opção num_predict repassada corretamente ao Ollama")

	provider.queue_free()


func test_payload_construction_openai_compat() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	provider.provider_type = LocalModelProviderClass.ProviderType.LM_STUDIO
	provider.model_name = "meta-llama-3-8b-instruct"
	provider.temperature = 0.8
	provider.max_tokens = 100

	var payload: Dictionary = provider.build_payload("", "Status do escudo.")
	_assert_true(payload["model"] == "meta-llama-3-8b-instruct", "Payload compatível define modelo")
	_assert_true(payload["max_tokens"] == 100, "Payload compatível define max_tokens na raiz")
	_assert_true(payload["temperature"] == 0.8, "Payload compatível define temperature na raiz")

	var msgs: Array = payload["messages"]
	_assert_true(msgs.size() == 1, "Sem prompt de sistema, payload possui apenas 1 mensagem do usuário")
	_assert_true(msgs[0]["content"] == "Status do escudo.", "Conteúdo do usuário preservado")

	provider.queue_free()


func test_response_parsing_ollama() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	var mock_ollama_resp: Dictionary = {
		"model": "llama3.2",
		"created_at": "2026-10-06T06:00:00Z",
		"message": {
			"role": "assistant",
			"content": "Setor B operando em estabilidade térmica."
		},
		"done": true
	}

	var parsed: String = provider.parse_response_text(mock_ollama_resp)
	_assert_true(parsed == "Setor B operando em estabilidade térmica.", "Texto extraído com precisão do esquema nativo do Ollama")

	provider.queue_free()


func test_response_parsing_openai_and_lmstudio() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	var mock_openai_resp: Dictionary = {
		"id": "chatcmpl-local-42",
		"object": "chat.completion",
		"choices": [
			{
				"index": 0,
				"message": {
					"role": "assistant",
					"content": "Pressão dos tanques em níveis nominais."
				},
				"finish_reason": "stop"
			}
		]
	}

	var parsed: String = provider.parse_response_text(mock_openai_resp)
	_assert_true(parsed == "Pressão dos tanques em níveis nominais.", "Texto extraído com precisão do esquema padrão OpenAI / LM Studio / llama.cpp")

	provider.queue_free()


func test_response_parsing_llamacpp_direct() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	var mock_llama_direct: Dictionary = {
		"content": "Gerador auxiliar ativado com sucesso.",
		"stop": true
	}

	var parsed: String = provider.parse_response_text(mock_llama_direct)
	_assert_true(parsed == "Gerador auxiliar ativado com sucesso.", "Texto extraído de endpoint direto de completion do llama.cpp")

	provider.queue_free()


func test_offline_fallback_logic() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	var fallback_reator: String = provider.get_offline_fallback("Verificar reator de dobra")
	_assert_true(fallback_reator.contains("reator"), "Fallback acionado por palavra-chave 'reator'")

	var fallback_seg: String = provider.get_offline_fallback("Nível de seguranca da eclusa")
	_assert_true(fallback_seg.contains("segurança"), "Fallback acionado por palavra-chave 'seguranca'")

	var fallback_padrao: String = provider.get_offline_fallback("Pergunta genérica sem correspondência")
	_assert_true(fallback_padrao.contains("Resposta pré-gravada"), "Fallback padrão acionado quando sem palavras-chave")

	provider.queue_free()


func test_malformed_response_handling() -> void:
	var provider = LocalModelProviderClass.new()
	add_child(provider)

	var empty_dict: Dictionary = {}
	var result_empty: String = provider.parse_response_text(empty_dict)
	_assert_true(result_empty.is_empty(), "Dicionário vazio retorna string vazia sem lançar exceção")

	var invalid_schema: Dictionary = {"error": "unsupported", "code": 500}
	var result_invalid: String = provider.parse_response_text(invalid_schema)
	_assert_true(result_invalid.is_empty(), "Esquema sem campos textuais válidos retorna string vazia")

	provider.queue_free()


func _print_summary() -> void:
	print("--------------------------------------------------")
	print("[TestLocalModelProvider] Resultados:")
	print("  Aprovados: %d" % _tests_passed)
	print("  Falhas:    %d" % _tests_failed)
	print("--------------------------------------------------")
