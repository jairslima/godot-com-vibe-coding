# ARQUIVO: res://src/ui_dialogue_client.gd
# ANEXAR AO NODE: UIDialogueClient (Control)
# CENA: res://src/ui_dialogue_client.tscn
# INPUTS NECESSÁRIOS: nenhum (interação via mouse/teclado nos nós Control)
# DEPENDÊNCIAS: AiNetworkClient (res://src/ai_network_client.gd)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: envia mensagens digitadas ao backend mock e exibe resposta ou fallback na interface
class_name UIDialogueClient
extends Control

@onready var network_client: AiNetworkClient = %AiNetworkClient
@onready var prompt_edit: LineEdit = %PromptEdit
@onready var send_button: Button = %SendButton
@onready var status_label: Label = %StatusLabel
@onready var output_label: Label = %OutputLabel
@onready var metadata_label: Label = %MetadataLabel

var _start_time_msec: int = 0


func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	prompt_edit.text_submitted.connect(_on_prompt_submitted)

	network_client.request_started.connect(_on_request_started)
	network_client.response_received.connect(_on_response_received)
	network_client.request_failed.connect(_on_request_failed)

	status_label.text = "Status: Conectado ao canal local."
	metadata_label.text = "Telemetria: aguardando primeira transmissão."


func _on_prompt_submitted(_new_text: String) -> void:
	_on_send_pressed()


func _on_send_pressed() -> void:
	var prompt_text: String = prompt_edit.text.strip_edges()
	if prompt_text.is_empty():
		status_label.text = "Aviso: insira um texto antes de enviar."
		return

	_start_time_msec = Time.get_ticks_msec()
	var err: Error = network_client.send_dialogue_request(prompt_text, "sentinela_01")
	if err != OK:
		status_label.text = "Erro imediato ao disparar: %d" % err


func _on_request_started() -> void:
	send_button.disabled = true
	prompt_edit.editable = false
	status_label.text = "Status: Aguardando resposta do backend..."


func _on_response_received(reply: String, metadata: Dictionary) -> void:
	var elapsed_msec: int = Time.get_ticks_msec() - _start_time_msec
	send_button.disabled = false
	prompt_edit.editable = true

	output_label.text = "Resposta:\n" + reply
	status_label.text = "Status: Transmissão concluída com sucesso."

	var tokens: int = int(metadata.get("tokens_used", 0))
	var npc: String = str(metadata.get("npc_id", "desconhecido"))
	metadata_label.text = "NPC: %s | Tokens: %d | Latência: %d ms | Fallback: Não" % [npc, tokens, elapsed_msec]


func _on_request_failed(error_message: String, fallback_used: bool, fallback_reply: String) -> void:
	var elapsed_msec: int = Time.get_ticks_msec() - _start_time_msec
	send_button.disabled = false
	prompt_edit.editable = true

	status_label.text = "Falha: %s" % error_message
	if fallback_used:
		output_label.text = "Resposta de Contingência:\n" + fallback_reply
		metadata_label.text = "Latência: %d ms | Fallback Local: Ativo" % elapsed_msec
	else:
		output_label.text = "Nenhuma resposta disponível."
