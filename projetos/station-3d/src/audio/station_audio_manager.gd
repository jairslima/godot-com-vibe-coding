class_name StationAudioManager
extends RefCounted

## Gerenciador e utilitário de áudio espacial 3D para a Estação Espacial.
## Configura parâmetros de atenuação, ouvinte e instanciamento dinâmico de fontes sonoras tridimensionais.

## Cria e anexa um emissor sonoro tridimensional (AudioStreamPlayer3D) a um nó pai no espaço.
static func attach_spatial_emitter(
	parent: Node3D,
	stream: AudioStream,
	unit_size: float = 5.0,
	max_distance: float = 25.0,
	volume_db: float = 0.0,
	autoplay: bool = true,
	attenuation_model: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.unit_size = unit_size
	player.max_distance = max_distance
	player.volume_db = volume_db
	player.attenuation_model = attenuation_model
	player.panning_strength = 1.0
	player.autoplay = autoplay
	
	parent.add_child(player)
	if autoplay:
		player.play()
	return player

## Toca um efeito sonoro espacial pontual em coordenadas globais tridimensionais, liberando o nó ao terminar.
static func play_spatial_sound(
	tree: SceneTree,
	stream: AudioStream,
	global_pos: Vector3,
	unit_size: float = 4.0,
	max_distance: float = 20.0,
	volume_db: float = 0.0
) -> AudioStreamPlayer3D:
	if tree == null:
		return null
	var parent_target: Node = tree.current_scene if tree.current_scene != null else tree.root
	if parent_target == null:
		return null
		
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.unit_size = unit_size
	player.max_distance = max_distance
	player.volume_db = volume_db
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	
	parent_target.add_child(player)
	if player.is_inside_tree():
		player.global_position = global_pos
	player.finished.connect(player.queue_free)
	player.play()
	return player
