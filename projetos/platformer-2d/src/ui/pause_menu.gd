# ARQUIVO: res://src/ui/pause_menu.gd
# ANEXAR AO NODE: PauseMenu (CanvasLayer)
# CENA: res://src/ui/pause_menu.tscn
# INPUTS NECESSÁRIOS: pause
# DEPENDÊNCIAS: res://src/ui/main_menu.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Controla a pausa do jogo via get_tree().paused, com process_mode = PROCESS_MODE_ALWAYS e foco automático para acessibilidade.
class_name PauseMenu
extends CanvasLayer

signal paused_state_changed(is_paused: bool)

@onready var overlay: Control = %Overlay
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if overlay != null:
		overlay.visible = false
	if resume_button != null:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button != null:
		quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		alternar_pausa()
		get_viewport().set_input_as_handled()

func alternar_pausa() -> void:
	if get_tree().paused:
		despausar()
	else:
		pausar()

func pausar() -> void:
	get_tree().paused = true
	if overlay != null:
		overlay.visible = true
	if resume_button != null:
		resume_button.grab_focus()
	paused_state_changed.emit(true)

func despausar() -> void:
	get_tree().paused = false
	if overlay != null:
		overlay.visible = false
	paused_state_changed.emit(false)

func _on_resume_pressed() -> void:
	despausar()

func _on_restart_pressed() -> void:
	despausar()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	despausar()
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")
