class_name StationHub
extends Node3D

## Controlador de inicialização do setor central da estação espacial.
## Responsável pela orquestração dos setores modulares, HUD, objetivos e ameaça autônoma.

@onready var world_env: WorldEnvironment = %WorldEnvironment
@onready var sun_light: DirectionalLight3D = %DirectionalLight3D
@onready var player: Player = %Player
@onready var hud: HUD3D = %HUD3D
@onready var objectives: ObjectiveManager = %ObjectiveManager
@onready var nav_region: NavigationRegion3D = %NavigationRegion3D
@onready var drone_threat: DroneThreat = %DroneThreat

func _ready() -> void:
	print("--- ESTAÇÃO ESPACIAL: SISTEMAS DE INTERAÇÃO E IA ATIVOS ---")
	print("Setor central, navegação 3D e objetivos inicializados.")
	
	setup_signals()

func setup_signals() -> void:
	if player and hud:
		player.interaction_prompt_changed.connect(_on_player_interaction_prompt_changed)
	
	if objectives and hud:
		objectives.core_count_updated.connect(hud.update_objectives)
		objectives.status_message_updated.connect(hud.display_status_message)
		objectives.power_restored.connect(_on_power_restored)

func _on_player_interaction_prompt_changed(prompt_text: String, is_visible: bool) -> void:
	if not hud:
		return
	if is_visible:
		hud.show_prompt(prompt_text)
	else:
		hud.hide_prompt()

func _on_power_restored() -> void:
	print("ENERGIA RESTAURADA: Portas de pressurização liberadas.")
	if hud:
		hud.display_status_message("MISSÃO CUMPRIDA: Subsistemas da estação reativados!")
