# ARQUIVO: res://src/ui/main_menu.gd
# ANEXAR AO NODE: MainMenu (Control)
# CENA: res://src/ui/main_menu.tscn
# INPUTS NECESSÁRIOS: ui_up, ui_down, ui_accept
# DEPENDÊNCIAS: res://src/levels/level_01.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Tela inicial do jogo com layout adaptativo por containers e navegação por teclado e gamepad.
class_name MainMenu
extends Control

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	if start_button != null:
		start_button.pressed.connect(_on_start_pressed)
		start_button.grab_focus()
	if quit_button != null:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://src/levels/level_01.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
