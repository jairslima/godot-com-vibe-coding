# ARQUIVO: res://src/npc_dialogue_view.gd
# ANEXAR AO NODE: NpcDialogueView (Control)
# CENA: res://src/npc_dialogue_view.tscn
# INPUTS NECESSÁRIOS: nenhum (interação via mouse/teclado nos nós Control)
# DEPENDÊNCIAS: ConversationalNpc (res://src/conversational_npc.gd) e AiNetworkClient (res://src/ai_network_client.gd)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: interface visual de diálogo com NPC conversacional, exibindo falas, emoção, ações autorizadas, memória e feedback de segurança
class_name NpcDialogueView
extends Control

@onready var conversational_npc: ConversationalNpc = %ConversationalNpc
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var role_label: Label = %RoleLabel
@onready var speech_label: Label = %SpeechLabel
@onready var emotion_label: Label = %EmotionLabel
@onready var action_label: Label = %ActionLabel
@onready var prompt_edit: LineEdit = %PromptEdit
@onready var send_button: Button = %SendButton
@onready var memory_status_label: Label = %MemoryStatusLabel
@onready var security_alert_label: Label = %SecurityAlertLabel

var _last_action_triggered: String = "nenhuma"


func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	prompt_edit.text_submitted.connect(_on_prompt_submitted)

	conversational_npc.dialogue_started.connect(_on_dialogue_started)
	conversational_npc.speech_delivered.connect(_on_speech_delivered)
	conversational_npc.action_triggered.connect(_on_action_triggered)
	conversational_npc.action_rejected.connect(_on_action_rejected)
	conversational_npc.fallback_triggered.connect(_on_fallback_triggered)

	if conversational_npc.persona != null:
		speaker_name_label.text = conversational_npc.persona.display_name
		role_label.text = conversational_npc.persona.role_description

	speech_label.text = "Canal de comunicação aberto. Digite uma mensagem para iniciar o diálogo."
	emotion_label.text = "Estado Emocional: [Neutro]"
	action_label.text = "Última Ação do Jogo: Nenhuma"
	memory_status_label.text = "Memória Curta: 0 turnos armazenados"
	security_alert_label.text = ""


func _on_prompt_submitted(_text: String) -> void:
	_on_send_pressed()


func _on_send_pressed() -> void:
	var player_text: String = prompt_edit.text.strip_edges()
	if player_text.is_empty():
		return

	prompt_edit.clear()
	security_alert_label.text = ""
	conversational_npc.interact(player_text)


func _on_dialogue_started(_prompt: String) -> void:
	send_button.disabled = true
	prompt_edit.editable = false
	speech_label.text = "Aguardando transmissão do droide..."


func _on_speech_delivered(speaker_name: String, speech: String, emotion: String) -> void:
	send_button.disabled = false
	prompt_edit.editable = true
	speaker_name_label.text = speaker_name
	speech_label.text = speech
	emotion_label.text = "Estado Emocional: [%s]" % emotion.capitalize()
	_update_memory_display()


func _on_action_triggered(action_name: String, parameters: Dictionary) -> void:
	_last_action_triggered = action_name
	var params_text: String = JSON.stringify(parameters) if not parameters.is_empty() else "sem parâmetros"
	action_label.text = "Ação Autorizada Executada: '%s' (%s)" % [action_name, params_text]


func _on_action_rejected(action_name: String, reason: String) -> void:
	security_alert_label.text = "ALERTA DE SEGURANÇA: Ação '%s' rejeitada pelo motor (%s)" % [action_name, reason]


func _on_fallback_triggered(reason: String, _speech: String) -> void:
	security_alert_label.text = "AVISO DE CONTINGÊNCIA: Fallback local acionado (%s)" % reason


func _update_memory_display() -> void:
	var history_count: int = conversational_npc.get_history_size()
	var max_entries: int = conversational_npc.persona.max_memory_turns * 2 if conversational_npc.persona != null else 8
	memory_status_label.text = "Memória Curta: %d/%d entradas ativas na janela deslizante" % [history_count, max_entries]
