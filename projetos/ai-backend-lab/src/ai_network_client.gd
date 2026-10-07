# ARQUIVO: res://src/ai_network_client.gd
# ANEXAR AO NODE: AiNetworkClient (Node)
# CENA: res://src/ui_dialogue_client.tscn
# INPUTS NECESSÁRIOS: nenhum (comunicação por chamada de método e sinais)
# DEPENDÊNCIAS: nó HTTPRequest (criado dinamicamente ou filho)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: envia requisições HTTP seguras a um backend intermediário e aciona fallback offline em falhas
class_name AiNetworkClient
extends Node

signal request_started()
signal response_received(reply: String, metadata: Dictionary)
signal request_failed(error_message: String, fallback_used: bool, fallback_reply: String)

@export var server_url: String = "http://127.0.0.1:8088/api/v1/dialogue"
@export var auth_token: String = "mock-session-token-xyz"
@export var request_timeout: float = 3.0
@export var player_id: String = "player_01"

var _http_request: HTTPRequest
var _pending_prompt: String = ""
var _pending_npc: String = ""
var _is_busy: bool = false

var _fallback_replies: Dictionary = {
	"energia": "O subsistema de contingência local informa: reservas de energia em nível mínimo.",
	"ajuda": "Terminal local em modo de emergência. Aguarde na zona protegida.",
	"padrao": "Canal de rádio fora de alcance. Mensagem pré-gravada: continue a missão."
}


func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.name = "HTTPRequest"
	_http_request.timeout = request_timeout
	_http_request.use_threads = true
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func is_busy() -> bool:
	return _is_busy


func send_dialogue_request(prompt: String, npc_id: String = "sentinela_01") -> Error:
	if _is_busy:
		push_warning("AiNetworkClient: requisição anterior ainda em andamento.")
		return ERR_BUSY

	var sanitized_prompt: String = prompt.strip_edges()
	if sanitized_prompt.is_empty():
		push_warning("AiNetworkClient: prompt vazio ignorado.")
		return ERR_INVALID_PARAMETER

	_pending_prompt = sanitized_prompt
	_pending_npc = npc_id
	_is_busy = true

	var payload_dict: Dictionary = {
		"player_id": player_id,
		"npc_id": npc_id,
		"prompt": sanitized_prompt,
		"client_timestamp": Time.get_unix_time_from_system()
	}

	var json_body: String = JSON.stringify(payload_dict)
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + auth_token
	])

	request_started.emit()

	var error: Error = _http_request.request(
		server_url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		_is_busy = false
		var fallback: String = get_offline_fallback(_pending_prompt, _pending_npc)
		request_failed.emit("Falha ao iniciar requisição HTTP: código %d" % error, true, fallback)
		return error

	return OK


func get_offline_fallback(prompt: String, npc_id: String) -> String:
	var prompt_lower: String = prompt.to_lower()
	var fallback_text: String = _fallback_replies.get("padrao", "Sem conexão com o subsistema central.")
	for key: String in _fallback_replies.keys():
		if key != "padrao" and key in prompt_lower:
			fallback_text = str(_fallback_replies[key])
			break
	return "[%s - Fallback Local]: %s" % [npc_id, fallback_text]


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_busy = false

	# 1. Validação de integridade de transporte de rede
	if result != HTTPRequest.RESULT_SUCCESS:
		var error_desc: String = _describe_transport_error(result)
		var fallback: String = get_offline_fallback(_pending_prompt, _pending_npc)
		request_failed.emit("Erro de rede (%s)" % error_desc, true, fallback)
		return

	# 2. Validação do código de status HTTP
	if response_code != 200:
		var error_msg: String = "Status HTTP inesperado: %d" % response_code
		if response_code == 401:
			error_msg = "Falha de autenticação (HTTP 401). Token de sessão inválido."
		elif response_code == 429:
			error_msg = "Limite de taxa excedido (HTTP 429). Aguarde antes de reenviar."
		elif response_code >= 500:
			error_msg = "Erro interno no backend (HTTP %d)." % response_code

		var fallback: String = get_offline_fallback(_pending_prompt, _pending_npc)
		request_failed.emit(error_msg, true, fallback)
		return

	# 3. Decodificação e validação do payload JSON
	var body_string: String = body.get_string_from_utf8()
	var json_parsed: Variant = JSON.parse_string(body_string)

	if typeof(json_parsed) != TYPE_DICTIONARY:
		var fallback: String = get_offline_fallback(_pending_prompt, _pending_npc)
		request_failed.emit("Resposta não contém um objeto JSON válido.", true, fallback)
		return

	var response_data: Dictionary = json_parsed as Dictionary
	if not response_data.has("reply"):
		var fallback: String = get_offline_fallback(_pending_prompt, _pending_npc)
		request_failed.emit("Campo 'reply' ausente no JSON do backend.", true, fallback)
		return

	var reply_text: String = str(response_data.get("reply", ""))
	response_received.emit(reply_text, response_data)


func _describe_transport_error(result: int) -> String:
	match result:
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "Incompatibilidade no tamanho do corpo chunked"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "Não foi possível conectar ao host"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "Não foi possível resolver o endereço DNS"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "Erro durante a conexão (leitura/escrita)"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "Erro de handshake TLS"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "Servidor não enviou resposta"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "Limite de tamanho do corpo excedido"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "Falha na descompressão do corpo"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "Falha geral na requisição"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			return "Não foi possível abrir arquivo de download"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			return "Erro ao gravar arquivo de download"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "Limite de redirecionamentos atingido"
		HTTPRequest.RESULT_TIMEOUT:
			return "Tempo limite (timeout) esgotado"
		_:
			return "Código de erro de transporte desconhecido: %d" % result
