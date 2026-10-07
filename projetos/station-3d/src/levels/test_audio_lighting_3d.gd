class_name TestAudioLighting3D
extends Node3D

## Suíte de testes automatizados headless para homologação do marco do Capítulo 35:
## - station3d-08-audio-lighting (Iluminação PBR, WorldEnvironment, StandardMaterial3D, AudioStreamPlayer3D e AudioListener3D)

var passed_assertions: int = 0
var total_assertions: int = 8

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: ILUMINAÇÃO, MATERIAIS E ÁUDIO 3D")
	print("==================================================")
	
	test_audio_listener_setup()
	test_world_environment_configuration()
	test_lighting_and_shadow_hierarchy()
	test_standard_materials_pbr()
	test_procedural_audio_synth()
	test_spatial_audio_manager_attachment()
	test_station_audio_integration()
	test_interactive_audio_events()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha na suíte de testes de áudio, iluminação e atmosfera 3D!")
		get_tree().quit(1)

func test_audio_listener_setup() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	assert(player_scene != null, "A cena player.tscn deve existir.")
	
	var player_inst: Node = player_scene.instantiate()
	var listener: AudioListener3D = player_inst.get_node_or_null("Head/Camera3D/AudioListener3D") as AudioListener3D
	assert(listener != null, "AudioListener3D deve ser filho direto de Camera3D sob Head no Player.")
	
	player_inst.free()
	passed_assertions += 1
	print("[TESTE 1/8 APROVADO] Configuração do AudioListener3D sob a câmera do jogador.")

func test_world_environment_configuration() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	assert(hub_scene != null, "A cena station_hub.tscn deve existir.")
	
	var hub_inst: Node = hub_scene.instantiate()
	var world_env: WorldEnvironment = hub_inst.get_node_or_null("WorldEnvironment") as WorldEnvironment
	assert(world_env != null, "WorldEnvironment deve existir no StationHub.")
	assert(world_env.environment != null, "Recurso Environment deve estar configurado.")
	
	var env: Environment = world_env.environment
	assert(env.tonemap_mode == Environment.TONE_MAPPER_ACES, "Tonemap deve utilizar a curva cinematográfica ACES (modo 3).")
	assert(env.glow_enabled == true, "Glow deve estar habilitado.")
	assert(env.glow_hdr_threshold >= 1.0, "Glow HDR threshold deve ser >= 1.0 para prevenir queima leitosa de superfícies.")
	assert(env.fog_enabled == true, "Névoa atmosférica de profundidade deve estar ativada.")
	assert(env.fog_density > 0.0, "Densidade da névoa deve ser estritamente positiva.")
	
	hub_inst.free()
	passed_assertions += 1
	print("[TESTE 2/8 APROVADO] Calibração de WorldEnvironment (Tonemap ACES, Glow HDR e Névoa).")

func test_lighting_and_shadow_hierarchy() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub_inst: Node = hub_scene.instantiate()
	var dir_light: DirectionalLight3D = hub_inst.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	assert(dir_light != null, "DirectionalLight3D deve existir.")
	assert(dir_light.shadow_enabled == true, "Luz direcional externa deve projetar sombras.")
	hub_inst.free()
	
	var room_scene: PackedScene = load("res://src/world/modular_room.tscn")
	var room_inst: Node = room_scene.instantiate()
	var spot_light: SpotLight3D = room_inst.get_node_or_null("CenterSpotLight") as SpotLight3D
	var omni_light: OmniLight3D = room_inst.get_node_or_null("RoomLight") as OmniLight3D
	
	assert(spot_light != null, "CenterSpotLight deve existir na sala modular.")
	assert(spot_light.shadow_enabled == true, "Luz-chave de holofote (SpotLight3D) deve projetar sombras dramáticas.")
	assert(omni_light != null, "RoomLight deve existir na sala modular.")
	assert(omni_light.shadow_enabled == false, "Luz de preenchimento (OmniLight3D) deve ter sombras desligadas para economia de GPU.")
	
	room_inst.free()
	passed_assertions += 1
	print("[TESTE 3/8 APROVADO] Hierarquia de luzes e sombras (Key Spot com sombra, Fill Omni sem sombra).")

func test_standard_materials_pbr() -> void:
	var corridor_scene: PackedScene = load("res://src/world/modular_corridor.tscn")
	var corridor_inst: Node = corridor_scene.instantiate()
	
	var floor_box: CSGBox3D = corridor_inst.get_node_or_null("Floor") as CSGBox3D
	assert(floor_box != null and floor_box.material != null, "Piso do corredor deve conter material PBR.")
	var floor_mat: StandardMaterial3D = floor_box.material as StandardMaterial3D
	assert(floor_mat != null, "Material do piso deve ser StandardMaterial3D.")
	assert(floor_mat.metallic > 0.0 and floor_mat.roughness < 1.0, "Piso deve ter resposta metálica PBR.")
	
	var strip_mesh: MeshInstance3D = corridor_inst.get_node_or_null("LightStripLeft") as MeshInstance3D
	assert(strip_mesh != null and strip_mesh.mesh != null, "Faixa luminosa deve possuir malha configurada.")
	var strip_mat: StandardMaterial3D = strip_mesh.mesh.material as StandardMaterial3D
	assert(strip_mat != null, "Material da faixa deve ser StandardMaterial3D.")
	assert(strip_mat.emission_enabled == true, "Material da faixa deve ter emissão ativada.")
	assert(strip_mat.emission_energy_multiplier >= 1.0, "Multiplicador de emissão deve ser >= 1.0.")
	
	corridor_inst.free()
	passed_assertions += 1
	print("[TESTE 4/8 APROVADO] Configuração física de materiais PBR (Albedo, Metallic, Roughness, Emission).")

func test_procedural_audio_synth() -> void:
	var reactor: AudioStreamWAV = AudioSynth3D.create_reactor_hum(0.2)
	assert(reactor != null, "Stream do reator deve ser gerado.")
	assert(reactor.data.size() > 0, "Buffer PCM do reator deve conter dados.")
	assert(reactor.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Reator deve estar em modo de loop contínuo.")
	
	var terminal: AudioStreamWAV = AudioSynth3D.create_terminal_beep(0.1)
	assert(terminal != null and terminal.data.size() > 0, "Buffer do terminal deve conter dados.")
	assert(terminal.loop_mode == AudioStreamWAV.LOOP_DISABLED, "Bipe do terminal não deve estar em loop.")
	
	var core_sfx: AudioStreamWAV = AudioSynth3D.create_core_pickup(0.1)
	assert(core_sfx != null and core_sfx.data.size() > 0, "Buffer de coleta deve conter dados.")
	
	var drone_sfx: AudioStreamWAV = AudioSynth3D.create_drone_engine(0.2)
	assert(drone_sfx != null and drone_sfx.data.size() > 0, "Buffer do motor do drone deve conter dados.")
	assert(drone_sfx.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Motor do drone deve estar em loop contínuo.")
	
	passed_assertions += 1
	print("[TESTE 5/8 APROVADO] Síntese procedural de áudios espaciais em memória RAM (AudioSynth3D).")

func test_spatial_audio_manager_attachment() -> void:
	var dummy_parent := Node3D.new()
	add_child(dummy_parent)
	
	var test_stream := AudioStreamWAV.new()
	var player3d := StationAudioManager.attach_spatial_emitter(dummy_parent, test_stream, 6.0, 30.0, -3.0, false)
	assert(player3d != null, "Emissor tridimensional deve ser criado.")
	assert(player3d.unit_size == 6.0, "Unit size de atenuação deve corresponder ao configurado.")
	assert(player3d.max_distance == 30.0, "Max distance de corte sonoro deve corresponder ao configurado.")
	assert(player3d.volume_db == -3.0, "Volume de ganho em decibéis deve corresponder ao configurado.")
	assert(player3d.attenuation_model == AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE, "Modelo de atenuação padrão deve ser INVERSE_DISTANCE.")
	
	dummy_parent.free()
	passed_assertions += 1
	print("[TESTE 6/8 APROVADO] Anexação e calibração espacial via StationAudioManager.")

func test_station_audio_integration() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub_inst: Node = hub_scene.instantiate()
	add_child(hub_inst)
	
	var reactor_audio: AudioStreamPlayer3D = hub_inst.get_node_or_null("NavigationRegion3D/Environment/EngineRoom/ReactorHumAudio") as AudioStreamPlayer3D
	assert(reactor_audio != null, "Emissor ReactorHumAudio deve existir na sala de máquinas.")
	assert(reactor_audio.unit_size == 5.0, "Unit size do reator deve ser 5.0m.")
	assert(reactor_audio.max_distance == 30.0, "Max distance do reator deve ser 30.0m.")
	
	hub_inst.free()
	passed_assertions += 1
	print("[TESTE 7/8 APROVADO] Integração de áudio 3D ambiental na arquitetura da estação.")

func test_interactive_audio_events() -> void:
	var core_scene: PackedScene = load("res://src/props/power_core.tscn")
	var core_inst: PowerCore = core_scene.instantiate() as PowerCore
	add_child(core_inst)
	
	# Simula interação sem disparar exceções
	core_inst._on_interacted(null)
	
	var console_scene: PackedScene = load("res://src/props/terminal_console.tscn")
	var console_inst: TerminalConsole = console_scene.instantiate() as TerminalConsole
	add_child(console_inst)
	
	console_inst._on_interacted(null)
	console_inst.free()
	
	passed_assertions += 1
	print("[TESTE 8/8 APROVADO] Disparo desacoplado de eventos sonoros espaciais em props interativos.")
