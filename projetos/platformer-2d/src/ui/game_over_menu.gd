# ARQUIVO: res://src/ui/game_over_menu.gd
# ANEXAR AO NODE: GameOverMenu (CanvasLayer)
# CENA: res://src/ui/game_over_menu.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/ui/main_menu.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Exibe tela modal de fim de jogo ao receber o sinal de derrota, pausando a árvore e oferecendo opções de reinício.
class_name GameOverMenu
extends CanvasLayer

@onready var overlay: Control = %Overlay
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if overlay != null:
		overlay.visible = false
	if retry_button != null:
		retry_button.pressed.connect(_on_retry_pressed)
	if menu_button != null:
		menu_button.pressed.connect(_on_menu_pressed)

func exibir() -> void:
	get_tree().paused = true
	if overlay != null:
		overlay.visible = true
	if retry_button != null:
		retry_button.grab_focus()

func ocultar() -> void:
	if overlay != null:
		overlay.visible = false

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")
