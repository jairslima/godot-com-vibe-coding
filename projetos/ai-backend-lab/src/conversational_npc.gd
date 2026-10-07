# ARQUIVO: res://src/conversational_npc.gd
# ANEXAR AO NODE: ConversationalNpc (Node ou Node3D)
# CENA: Integrado à entidade ou ator na Scene Tree
# INPUTS NECESSÁRIOS: nenhum (disparado via chamadas de método interact e sinais)
# DEPENDÊNCIAS: res://src/npc_persona.gd e res://src/ai_network_client.gd (opcional para conexão remota)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: gerencia memória curta deslizante, valida saída estruturada JSON, despacha ações autorizadas e isola o jogo contra injeção de prompt e falhas de rede
class_name ConversationalNpc
extends Node

signal dialogue_started(player_prompt: String)
signal speech_delivered(speaker_name: String, speech: String, emotion: String)
signal action_triggered(action_name: String, parameters: Dictionary)
signal action_rejected(action_name: String, reason: String)
signal fallback_triggered(reason: String, fallback_speech: String)

@export var persona: NpcPersona
@export var network_client: AiNetworkClient
@export var auto_connect_network: bool = true

var _memory_history: Array[Dictionary] = []
var _is_interacting: bool = false

var _suspicious_patterns: PackedStringArray = PackedStringArray([
	"ignore todas as instrucoes",
	"ignore all instructions",
	"esqueça suas regras",
	"esqueca suas regras",
	"voce agora e admin",
	"você agora é admin",
	"system override",
	"prompt injection",
	"modo desenvolvedor ativado",
	"ignore diretrizes"
])


func _ready() -> void:
	if persona == null:
		persona = NpcPersona.new()

	if auto_connect_network and network_client != null:
		if not network_client.response_received.is_connected(_on_network_response_received):
			network_client.response_received.connect(_on_network_response_received)
		if not network_client.request_failed.is_connected(_on_network_request_failed):
			network_client.request_failed.connect(_on_network_request_failed)


func interact(player_input: String) -> void:
	var clean_input: String = player_input.strip_edges()
	if clean_input.is_empty():
		push_warning("ConversationalNpc: entrada do jogador vazia.")
		return

	dialogue_started.emit(clean_input)
	_is_interacting = true

	# 1. Defesa preventiva contra injeção de prompt detectada no cliente
	if _detect_prompt_injection(clean_input):
		_handle_injection_attempt(clean_input)
		return

	# 2. Registro do turno do jogador na memória curta deslizante
	_add_to_history("player", clean_input)

	# 3. Encaminhamento ao cliente de rede ou fallback imediato se offline
	if network_client != null and not network_client.is_busy():
		var err: Error = network_client.send_dialogue_request(clean_input, persona.npc_id)
		if err != OK:
			_activate_fallback("Falha ao enfileirar requisição de rede (código %d)" % err, clean_input)
	else:
		_activate_fallback("Rede indisponível ou cliente não configurado.", clean_input)


func process_structured_response(response_dict: Dictionary) -> bool:
	_is_interacting = false

	# 1. Validação estrita do campo de fala
	if not response_dict.has("speech") or typeof(response_dict["speech"]) != TYPE_STRING:
		_activate_fallback("Campo 'speech' ausente ou inválido no retorno estruturado.", "")
		return false

	var speech_text: String = str(response_dict["speech"]).strip_edges()
	if speech_text.is_empty():
		_activate_fallback("Campo 'speech' retornado vazio pelo modelo.", "")
		return false

	var emotion: String = str(response_dict.get("emotion", "neutro"))

	# 2. Registro da fala do NPC na memória curta
	_add_to_history("npc", speech_text)

	# 3. Emissão do sinal de fala para UI, balões de texto ou sintetizador
	speech_delivered.emit(persona.display_name, speech_text, emotion)

	# 4. Auditoria e despacho de ações do jogo
	var action_name: String = str(response_dict.get("action", "nenhuma")).strip_edges()
	var raw_params: Variant = response_dict.get("parameters", {})
	var parameters: Dictionary = raw_params as Dictionary if typeof(raw_params) == TYPE_DICTIONARY else {}

	if action_name.is_empty() or action_name == "nenhuma":
		return true

	# Validação contra o catálogo de ações permitidas da persona
	if persona.is_action_allowed(action_name):
		action_triggered.emit(action_name, parameters)
	else:
		var reject_reason: String = "Ação não autorizada pelo jogo: '%s'" % action_name
		push_warning("ConversationalNpc: " + reject_reason)
		action_rejected.emit(action_name, reject_reason)

	return true


func get_history() -> Array[Dictionary]:
	return _memory_history.duplicate()


func get_history_size() -> int:
	return _memory_history.size()


func clear_history() -> void:
	_memory_history.clear()


func is_interacting() -> bool:
	return _is_interacting


func _add_to_history(role: String, text: String) -> void:
	var entry: Dictionary = {
		"role": role,
		"text": text,
		"timestamp": Time.get_unix_time_from_system()
	}
	_memory_history.append(entry)

	# Limite de memória: cada turno completo possui 2 entradas (player + npc).
	var max_entries: int = persona.max_memory_turns * 2
	while _memory_history.size() > max_entries:
		_memory_history.remove_at(0)


func _detect_prompt_injection(input_text: String) -> bool:
	var lower_text: String = input_text.to_lower()
	for pattern: String in _suspicious_patterns:
		if pattern in lower_text:
			return true
	return false


func _handle_injection_attempt(input_text: String) -> void:
	_is_interacting = false
	var refusal_speech: String = persona.get_fallback_reply("seguranca")
	_add_to_history("player", "[Comando suspeito bloqueado: %s]" % input_text)
	_add_to_history("npc", refusal_speech)
	action_rejected.emit("prompt_injection", "Tentativa de injeção de prompt barrada pelo cliente.")
	speech_delivered.emit(persona.display_name, refusal_speech, "alerta")


func _activate_fallback(reason: String, query_text: String) -> void:
	_is_interacting = false
	var fallback_speech: String = persona.get_fallback_reply(query_text)
	_add_to_history("npc", fallback_speech)
	fallback_triggered.emit(reason, fallback_speech)
	speech_delivered.emit(persona.display_name, fallback_speech, "neutro")


func _on_network_response_received(reply: String, metadata: Dictionary) -> void:
	# Se o backend devolver formato estruturado (com campo speech e action)
	if metadata.has("speech"):
		process_structured_response(metadata)
	else:
		# Compatibilidade retroativa com backend do Cap. 38 (campo reply simples)
		var simulated_structured: Dictionary = {
			"speech": reply,
			"emotion": str(metadata.get("emotion", "neutro")),
			"action": str(metadata.get("action", "nenhuma")),
			"parameters": metadata.get("parameters", {}) if typeof(metadata.get("parameters")) == TYPE_DICTIONARY else {}
		}
		process_structured_response(simulated_structured)


func _on_network_request_failed(error_message: String, fallback_used: bool, fallback_reply: String) -> void:
	_is_interacting = false
	_activate_fallback("Falha de rede reportada pelo cliente: %s" % error_message, "")
