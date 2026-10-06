class_name PowerCore
extends Node3D

## Núcleo de energia coletável da estação espacial.
## Possui componente Interactable3D para detecção de mira em primeira pessoa.

signal collected(core_node: PowerCore)

@export var core_id: String = "core_01"
@export var prompt_text: String = "Pressione [E] para coletar Núcleo de Energia"

@onready var interactable: Interactable3D = %Interactable
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D

var is_collected: bool = false

func _ready() -> void:
	if interactable:
		interactable.prompt_message = prompt_text
		interactable.interacted.connect(_on_interacted)
		interactable.highlight_changed.connect(_on_highlight_changed)

func _process(delta: float) -> void:
	# Efeito sutil de flutuação e rotação visual no espaço
	if mesh_instance and not is_collected:
		mesh_instance.rotate_y(1.5 * delta)

func _on_interacted(_player: Node3D = null) -> void:
	if is_collected:
		return
	
	is_collected = true
	collected.emit(self)
	
	# Busca gerenciador de objetivos no grupo se estiver na árvore de cena
	if is_inside_tree():
		var tree: SceneTree = get_tree()
		if tree:
			var pos: Vector3 = global_position
			var stream := AudioSynth3D.create_core_pickup()
			StationAudioManager.play_spatial_sound(tree, stream, pos, 4.0, 20.0, 0.0)
			var objectives: ObjectiveManager = tree.get_first_node_in_group("objectives") as ObjectiveManager
			if objectives:
				objectives.register_core_collected()
	
	queue_free()

func _on_highlight_changed(highlighted: bool) -> void:
	if mesh_instance and mesh_instance.material_override:
		var mat: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = 3.0 if highlighted else 1.5
