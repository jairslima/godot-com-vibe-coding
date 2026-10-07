# ARQUIVO: res://src/local_model_provider.gd
# ANEXAR AO NODE: LocalModelProvider (Node)
# CENA: res://src/ui_dialogue_client.tscn ou instanciado via código
# INPUTS NECESSÁRIOS: nenhum (disparado via chamadas de método e sinais)
# DEPENDÊNCIAS: nó HTTPRequest (filho interno)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: abstrai a comunicação com servidores locais de inferência (Ollama, LM Studio, llama.cpp), normalizando endpoints, payloads e extração de respostas com fallback determinístico
class_name LocalModelProvider
extends Node

signal inference_started()
signal inference_completed(reply_text: String, raw_response: Dictionary)
signal inference_failed(error_message: String, fallback_used: bool, fallback_reply: String)

enum ProviderType {
	OLLAMA,
	LM_STUDIO,
	LLAMA_CPP,
	CUSTOM_OPENAI
}

@export var provider_type: ProviderType = ProviderType.LM_STUDIO
@export var base_url: String = ""
@export var model_name: String = "local-model"
@export var timeout_seconds: float = 15.0
@export var temperature: float = 0.7
@export var max_tokens: int = 150

var _http_request: HTTPRequest
var _is_busy: bool = false
var _pending_prompt: String = ""

var _fallback_templates: Dictionary = {
	"reator": "Alerta local de contingência: parâmetros térmicos do reator estabilizados em modo passivo.",
	"seguranca": "Protocolo de segurança local: autorização biométrica requerida no terminal manual.",
	"padrao": "Processamento local de linguagem indisponível. Resposta pré-gravada do sistema de bordo."
}


func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.name = "HTTPRequest"
	_http_request.timeout = timeout_seconds
	_http_request.use_threads = true
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func is_busy() -> bool:
	return _is_busy


func get_default_port(type: ProviderType) -> int:
	match type:
		ProviderType.OLLAMA:
			return 11434
		ProviderType.LM_STUDIO:
			return 1234
		ProviderType.LLAMA_CPP:
			return 8080
		_:
			return 8080


func get_endpoint_url() -> String:
	if not base_url.strip_edges().is_empty():
		var clean_url: String = base_url.strip_edges().trim_suffix("/")
		if provider_type == ProviderType.OLLAMA and not clean_url.ends_with("/api/chat"):
			return clean_url + "/api/chat"
		elif provider_type != ProviderType.OLLAMA and not clean_url.ends_with("/v1/chat/completions"):
			return clean_url + "/v1/chat/completions"
		return clean_url

	var port: int = get_default_port(provider_type)
	match provider_type:
		ProviderType.OLLAMA:
			return "http://127.0.0.1:%d/api/chat" % port
		ProviderType.LM_STUDIO, ProviderType.LLAMA_CPP, ProviderType.CUSTOM_OPENAI:
			return "http://127.0.0.1:%d/v1/chat/completions" % port
		_:
			return "http://127.0.0.1:%d/v1/chat/completions" % port


func build_payload(system_prompt: String, user_prompt: String) -> Dictionary:
	var clean_user: String = user_prompt.strip_edges()
	var clean_system: String = system_prompt.strip_edges()

	var messages: Array[Dictionary] = []
	if not clean_system.is_empty():
		messages.append({"role": "system", "content": clean_system})
	messages.append({"role": "user", "content": clean_user})

	if provider_type == ProviderType.OLLAMA:
		return {
			"model": model_name,
			"messages": messages,
			"stream": false,
			"options": {
				"temperature": temperature,
				"num_predict": max_tokens
			}
		}

	# Padrão compatível com OpenAI (LM Studio, llama-server e backends customizados)
	return {
		"model": model_name,
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"stream": false
	}


func parse_response_text(response_dict: Dictionary) -> String:
	# 1. Esquema nativo do Ollama (/api/chat: {"message": {"content": "..."}})
	if response_dict.has("message"):
		var msg_var: Variant = response_dict["message"]
		if typeof(msg_var) == TYPE_DICTIONARY:
			var msg_dict: Dictionary = msg_var as Dictionary
			if msg_dict.has("content"):
				return str(msg_dict["content"]).strip_edges()

	# 2. Esquema OpenAI (/v1/chat/completions: {"choices": [{"message": {"content": "..."}}]})
	if response_dict.has("choices"):
		var choices_var: Variant = response_dict["choices"]
		if typeof(choices_var) == TYPE_ARRAY:
			var choices_arr: Array = choices_var as Array
			if not choices_arr.is_empty():
				var first_choice: Variant = choices_arr[0]
				if typeof(first_choice) == TYPE_DICTIONARY:
					var choice_dict: Dictionary = first_choice as Dictionary
					if choice_dict.has("message"):
						var inner_msg: Variant = choice_dict["message"]
						if typeof(inner_msg) == TYPE_DICTIONARY:
							var inner_dict: Dictionary = inner_msg as Dictionary
							if inner_dict.has("content"):
								return str(inner_dict["content"]).strip_edges()

	# 3. Esquema direto de texto (llama.cpp /completion ou Ollama /api/generate)
	if response_dict.has("content"):
		return str(response_dict["content"]).strip_edges()
	if response_dict.has("response"):
		return str(response_dict["response"]).strip_edges()

	return ""


func send_inference(user_prompt: String, system_prompt: String = "") -> Error:
	if _is_busy:
		push_warning("LocalModelProvider: inferência anterior ainda em processamento.")
		return ERR_BUSY

	var sanitized_prompt: String = user_prompt.strip_edges()
	if sanitized_prompt.is_empty():
		push_warning("LocalModelProvider: prompt vazio rejeitado.")
		return ERR_INVALID_PARAMETER

	_pending_prompt = sanitized_prompt
	_is_busy = true

	var endpoint: String = get_endpoint_url()
	var payload_dict: Dictionary = build_payload(system_prompt, sanitized_prompt)
	var json_body: String = JSON.stringify(payload_dict)

	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json"
	])

	inference_started.emit()

	var error: Error = _http_request.request(
		endpoint,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		_is_busy = false
		var fallback: String = get_offline_fallback(_pending_prompt)
		inference_failed.emit("Falha ao disparar requisição local (código %d)" % error, true, fallback)
		return error

	return OK


func get_offline_fallback(prompt: String) -> String:
	var prompt_lower: String = prompt.to_lower()
	var fallback_text: String = _fallback_templates.get("padrao", "Subsistema offline.")
	for key: String in _fallback_templates.keys():
		if key != "padrao" and key in prompt_lower:
			fallback_text = str(_fallback_templates[key])
			break
	return "[Fallback Determinado]: %s" % fallback_text


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_busy = false

	if result != HTTPRequest.RESULT_SUCCESS:
		var error_msg: String = "Erro de conexão com o servidor local (código de transporte %d)." % result
		if result == HTTPRequest.RESULT_CANT_CONNECT:
			error_msg = "Não foi possível conectar ao servidor local em loopback (o processo Ollama, LM Studio ou llama.cpp está ativo?)."
		elif result == HTTPRequest.RESULT_TIMEOUT:
			error_msg = "Tempo limite de inferência esgotado (%s s). O hardware local demorou para responder." % str(timeout_seconds)

		var fallback: String = get_offline_fallback(_pending_prompt)
		inference_failed.emit(error_msg, true, fallback)
		return

	if response_code != 200:
		var http_err: String = "Servidor local retornou HTTP %d." % response_code
		var fallback: String = get_offline_fallback(_pending_prompt)
		inference_failed.emit(http_err, true, fallback)
		return

	var body_string: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_string)
	if typeof(parsed) != TYPE_DICTIONARY:
		var fallback: String = get_offline_fallback(_pending_prompt)
		inference_failed.emit("Resposta do modelo local não é um JSON válido.", true, fallback)
		return

	var raw_dict: Dictionary = parsed as Dictionary
	var reply_text: String = parse_response_text(raw_dict)
	if reply_text.is_empty():
		var fallback: String = get_offline_fallback(_pending_prompt)
		inference_failed.emit("Texto de resposta vazio ou esquema não reconhecido.", true, fallback)
		return

	inference_completed.emit(reply_text, raw_dict)
