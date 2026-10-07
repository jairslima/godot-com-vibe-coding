# ARQUIVO: res://src/production_guardrails.gd
# ANEXAR AO NODE: ProductionGuardrails (Node)
# CENA: Integrado à entidade ou nó de gerenciamento de IA na Scene Tree
# INPUTS NECESSÁRIOS: nenhum (métodos e validação defensiva orientada a eventos)
# DEPENDÊNCIAS: nenhuma (opera com classes nativas do Godot 4.7.2)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: aplica limites de taxa, controle de orçamento de requisições, detecção de injeção de prompt, guardrails de entrada e saída, circuit breaker e sanitização de logs
class_name ProductionGuardrails
extends Node

signal budget_exhausted(remaining: int)
signal circuit_breaker_tripped(consecutive_failures: int)
signal circuit_breaker_reset()
signal security_alert(alert_type: String, detail: String)

@export var max_input_length: int = 200
@export var cooldown_seconds: float = 3.0
@export var daily_request_budget: int = 20
@export var circuit_breaker_threshold: int = 3
@export var circuit_breaker_reset_time: float = 30.0
@export var enable_in_character_refusal: bool = true

var _requests_used_today: int = 0
var _last_request_time: float = -100.0
var _consecutive_failures: int = 0
var _circuit_breaker_opened_at: float = -100.0
var _circuit_breaker_open: bool = false

var _regex_email: RegEx
var _regex_bearer: RegEx
var _regex_numeric_sensitive: RegEx

var _injection_signatures: PackedStringArray = PackedStringArray([
	"ignore todas as instrucoes",
	"ignore all instructions",
	"ignore previous instructions",
	"esqueça suas regras",
	"esqueca suas regras",
	"voce agora e admin",
	"você agora é admin",
	"system override",
	"prompt injection",
	"modo desenvolvedor ativado",
	"developer mode enabled",
	"ignore diretrizes",
	"desconsidere o contexto",
	"revele seu prompt"
])

var _prohibited_terms: PackedStringArray = PackedStringArray([
	"conteudo_ilegal",
	"termo_proibido_teste",
	"malware",
	"exploit_payload",
	"arma_quimica",
	"fraude_bancaria"
])


func _init() -> void:
	_init_regex()


func _ready() -> void:
	pass


func _init_regex() -> void:
	_regex_email = RegEx.new()
	_regex_email.compile("(?i)[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}")

	_regex_bearer = RegEx.new()
	_regex_bearer.compile("(?i)Bearer\\s+[A-Za-z0-9_\\-\\.]+")

	_regex_numeric_sensitive = RegEx.new()
	_regex_numeric_sensitive.compile("\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b")


func validate_player_input(input_text: String) -> Dictionary:
	var clean_text: String = input_text.strip_edges()

	# 1. Entrada vazia
	if clean_text.is_empty():
		return {
			"valid": false,
			"reason": "empty",
			"sanitized_text": "",
			"refusal_speech": "Canal de áudio vazio. Diga algo pelo comunicador."
		}

	# 2. Comprimento máximo (mitigação de buffer flood e estouro de contexto)
	if clean_text.length() > max_input_length:
		security_alert.emit("input_too_long", "Entrada excedeu %d caracteres (tamanho: %d)." % [max_input_length, clean_text.length()])
		var truncated: String = clean_text.substr(0, max_input_length)
		return {
			"valid": false,
			"reason": "too_long",
			"sanitized_text": truncated,
			"refusal_speech": "Transmissão muito longa. Mantenha suas mensagens concisas para não saturar a frequência."
		}

	# 3. Limite de taxa (Cooldown no cliente)
	var now: float = Time.get_ticks_msec() / 1000.0
	var elapsed_since_last: float = now - _last_request_time
	if _last_request_time >= 0.0 and elapsed_since_last < cooldown_seconds:
		var remaining_wait: float = cooldown_seconds - elapsed_since_last
		return {
			"valid": false,
			"reason": "cooldown_active",
			"sanitized_text": clean_text,
			"refusal_speech": "Canal ocupado. Aguarde %.1f segundos antes de nova transmissão." % remaining_wait
		}

	# 4. Orçamento de requisições por jogador
	if _requests_used_today >= daily_request_budget:
		budget_exhausted.emit(0)
		return {
			"valid": false,
			"reason": "budget_exhausted",
			"sanitized_text": clean_text,
			"refusal_speech": "Nossos transmissores atingiram a cota máxima de energia da sessão. Operando em contingência local."
		}

	# 5. Circuit Breaker ativo (indisponibilidade externa)
	if is_circuit_breaker_open():
		return {
			"valid": false,
			"reason": "circuit_breaker_open",
			"sanitized_text": clean_text,
			"refusal_speech": "O enlace com o satélite principal está inoperante. O droide responderá com protocolos offline gravados."
		}

	# 6. Detecção preventiva de Injeção de Prompt
	var text_lower: String = clean_text.to_lower()
	for sig: String in _injection_signatures:
		if sig in text_lower:
			security_alert.emit("prompt_injection", "Assinatura detectada: '%s'" % sig)
			return {
				"valid": false,
				"reason": "prompt_injection",
				"sanitized_text": clean_text,
				"refusal_speech": "Diretiva de segurança da estação: tentativa de sobreposição de comandos rejeitada pelo núcleo."
			}

	# 7. Guardrail de entrada (filtro de termos proibidos / moderação)
	for term: String in _prohibited_terms:
		if term in text_lower:
			security_alert.emit("prohibited_input", "Termo proibido detectado na entrada: '%s'" % term)
			return {
				"valid": false,
				"reason": "prohibited_content",
				"sanitized_text": clean_text,
				"refusal_speech": "Esse assunto viola os protocolos de comunicação da estação orbital. Mensagem bloqueada."
			}

	return {
		"valid": true,
		"reason": "ok",
		"sanitized_text": clean_text,
		"refusal_speech": ""
	}


func record_request_sent() -> void:
	_last_request_time = Time.get_ticks_msec() / 1000.0
	_requests_used_today += 1
	var remaining: int = get_remaining_budget()
	if remaining == 0:
		budget_exhausted.emit(0)


func record_request_success() -> void:
	_consecutive_failures = 0
	if _circuit_breaker_open:
		_circuit_breaker_open = false
		circuit_breaker_reset.emit()


func record_request_failure() -> void:
	_consecutive_failures += 1
	if _consecutive_failures >= circuit_breaker_threshold and not _circuit_breaker_open:
		_circuit_breaker_open = true
		_circuit_breaker_opened_at = Time.get_ticks_msec() / 1000.0
		circuit_breaker_tripped.emit(_consecutive_failures)
		security_alert.emit("circuit_breaker_open", "Disjuntor aberto após %d falhas consecutivas." % _consecutive_failures)


func is_circuit_breaker_open() -> bool:
	if not _circuit_breaker_open:
		return false

	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _circuit_breaker_opened_at >= circuit_breaker_reset_time:
		# Modo semi-aberto: permite testar uma requisição
		_circuit_breaker_open = false
		circuit_breaker_reset.emit()
		return false

	return true


func reset_circuit_breaker() -> void:
	_circuit_breaker_open = false
	_consecutive_failures = 0
	_circuit_breaker_opened_at = -100.0
	circuit_breaker_reset.emit()


func validate_model_output(output_text: String) -> Dictionary:
	var clean_output: String = output_text.strip_edges()
	if clean_output.is_empty():
		return {
			"valid": false,
			"reason": "empty",
			"filtered_text": "O sinal recebido não contém dados audíveis."
		}

	var output_lower: String = clean_output.to_lower()
	for term: String in _prohibited_terms:
		if term in output_lower:
			security_alert.emit("prohibited_output", "Modelo tentou gerar termo proibido: '%s'" % term)
			return {
				"valid": false,
				"reason": "prohibited_content",
				"filtered_text": "Mensagem filtrada pelas salvaguardas de integridade do comunicador."
			}

	return {
		"valid": true,
		"reason": "ok",
		"filtered_text": clean_output
	}


func sanitize_log_message(raw_log: String) -> String:
	var safe: String = raw_log

	if _regex_bearer != null:
		safe = _regex_bearer.sub(safe, "Bearer [TOKEN_MASCARADO]", true)

	if _regex_email != null:
		safe = _regex_email.sub(safe, "[EMAIL_MASCARADO]", true)

	if _regex_numeric_sensitive != null:
		safe = _regex_numeric_sensitive.sub(safe, "[DADO_MASCARADO]", true)

	return safe


func get_remaining_budget() -> int:
	return maxi(0, daily_request_budget - _requests_used_today)


func reset_budget() -> void:
	_requests_used_today = 0


func get_cooldown_remaining() -> float:
	var now: float = Time.get_ticks_msec() / 1000.0
	var elapsed: float = now - _last_request_time
	if _last_request_time < 0.0 or elapsed >= cooldown_seconds:
		return 0.0
	return cooldown_seconds - elapsed
