class_name TerminalConsole
extends Node3D

## Terminal central de comando da estação espacial.
## Exige núcleos de energia suficientes para restaurar os subsistemas primários.

signal terminal_activated()

@onready var interactable: Interactable3D = %Interactable
@onready var screen_mesh: MeshInstance3D = %ScreenMesh

var is_activated: bool = false

func _ready() -> void:
	if interactable:
		interactable.prompt_message = "Pressione [E] para acessar Terminal Principal"
		interactable.interacted.connect(_on_interacted)

func _on_interacted(player: Node3D) -> void:
	if is_activated:
		return
	
	var objectives: ObjectiveManager = get_tree().get_first_node_in_group("objectives") as ObjectiveManager
	if not objectives:
		return
	
	var stream := AudioSynth3D.create_terminal_beep()
	StationAudioManager.play_spatial_sound(get_tree(), stream, global_position, 4.0, 20.0, 0.0)
	
	if objectives.can_restore_power():
		is_activated = true
		objectives.restore_power()
		interactable.prompt_message = "Terminal ativado: Energia Restaurada"
		terminal_activated.emit()
		update_screen_color(Color(0.2, 0.9, 0.3, 1)) # Verde sucesso
	else:
		objectives.status_message_updated.emit("Acesso negado: Requer 3 núcleos de energia para energizar.")
		update_screen_color(Color(0.9, 0.3, 0.2, 1)) # Vermelho alerta

func update_screen_color(color: Color) -> void:
	if screen_mesh and screen_mesh.material_override:
		var mat: StandardMaterial3D = screen_mesh.material_override as StandardMaterial3D
		if mat:
			mat.emission = color
