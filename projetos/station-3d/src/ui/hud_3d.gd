class_name HUD3D
extends CanvasLayer

## Interface gráfica 3D (checkpoint station3d-07-hud).
## Apresenta mira central, prompts de interação contextual e objetivos da estação.

@onready var prompt_label: Label = %PromptLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var status_banner: Label = %StatusBanner

func _ready() -> void:
	hide_prompt()
	update_objectives(0, 3)
	if status_banner:
		status_banner.text = ""

func show_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.text = text
		prompt_label.visible = true

func hide_prompt() -> void:
	if prompt_label:
		prompt_label.text = ""
		prompt_label.visible = false

func update_objectives(current: int, total: int) -> void:
	if objective_label:
		objective_label.text = "OBJETIVO: Restaurar Energia da Estação\nNúcleos Coletados: %d / %d" % [current, total]

func display_status_message(message: String) -> void:
	if status_banner:
		status_banner.text = message
		status_banner.visible = true
