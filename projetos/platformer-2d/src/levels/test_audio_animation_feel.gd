# ARQUIVO: res://src/levels/test_audio_animation_feel.gd
# ANEXAR AO NODE: TestAudioAnimationFeel (Node2D)
# CENA: res://src/levels/test_audio_animation_feel.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/audio/sound_manager.gd, res://src/entities/player/player.tscn, res://src/components/dust_particles.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Validação automatizada headless de barramentos de áudio, geração procedural de som, AnimationPlayer, Tween de squash & stretch, screen shake e partículas efêmeras.
class_name TestAudioAnimationFeel
extends Node2D

var frame_count: int = 0
var testes_passaram: int = 0
var player_instancia: Player = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	frame_count += 1

	match frame_count:
		2:
			_testar_buses_de_audio()
		4:
			_testar_sintese_e_reproducao_sonora()
		6:
			_testar_animacao_e_player()
		8:
			_testar_squash_stretch_e_particulas()
		10:
			_testar_screen_shake_e_trauma()
		12:
			_concluir_testes()

func _testar_buses_de_audio() -> void:
	var idx_master: int = AudioServer.get_bus_index("Master")
	var idx_music: int = AudioServer.get_bus_index("Music")
	var idx_sfx: int = AudioServer.get_bus_index("SFX")

	assert(idx_master >= 0, "Barramento 'Master' deve existir.")
	assert(idx_music >= 0, "Barramento 'Music' deve existir no layout default_bus_layout.tres.")
	assert(idx_sfx >= 0, "Barramento 'SFX' deve existir no layout default_bus_layout.tres.")

	# Testa ajuste de volume via linear_to_db
	var volume_linear: float = 0.8
	var volume_db: float = linear_to_db(volume_linear)
	AudioServer.set_bus_volume_db(idx_sfx, volume_db)
	assert(is_equal_approx(AudioServer.get_bus_volume_db(idx_sfx), volume_db), "Volume em decibéis deve ser aplicado corretamente.")

	testes_passaram += 1
	print("[TESTE 1/5 PASSOU] Barramentos de áudio Master, Music e SFX homologados com ajuste de decibéis.")

func _testar_sintese_e_reproducao_sonora() -> void:
	var som_pulo: AudioStreamWAV = SoundManager.obter_som_pulo()
	var som_pouso: AudioStreamWAV = SoundManager.obter_som_pouso()
	var som_impacto: AudioStreamWAV = SoundManager.obter_som_impacto()

	assert(som_pulo != null and som_pulo.data.size() > 0, "Som de pulo sintetizado deve conter dados PCM.")
	assert(som_pouso != null and som_pouso.data.size() > 0, "Som de aterrissagem sintetizado deve conter dados PCM.")
	assert(som_impacto != null and som_impacto.data.size() > 0, "Som de impacto sintetizado deve conter dados PCM.")

	# Testa criação de player efêmero
	var audio_player: AudioStreamPlayer = SoundManager.tocar_som(self, som_pulo, 1.0, 1.0, 0.0, &"SFX")
	assert(audio_player != null, "AudioStreamPlayer efêmero deve ser instanciado como filho.")
	assert(audio_player.bus == &"SFX", "AudioStreamPlayer deve estar roteado para o barramento SFX.")
	assert(audio_player.stream == som_pulo, "AudioStreamPlayer deve carregar o stream fornecido.")

	testes_passaram += 1
	print("[TESTE 2/5 PASSOU] Síntese procedural PCM em memória e reprodutor efêmero no bus SFX aprovados.")

func _testar_animacao_e_player() -> void:
	var player_scene: PackedScene = load("res://src/entities/player/player.tscn")
	assert(player_scene != null, "Cena player.tscn deve ser carregada com sucesso.")

	player_instancia = player_scene.instantiate()
	add_child(player_instancia)

	assert(player_instancia.anim_player != null, "Player deve possuir nó AnimationPlayer com unique name.")
	assert(player_instancia.anim_player.has_animation("idle"), "Animação 'idle' deve existir no AnimationPlayer.")
	assert(player_instancia.anim_player.has_animation("run"), "Animação 'run' deve existir no AnimationPlayer.")
	assert(player_instancia.anim_player.has_animation("jump"), "Animação 'jump' deve existir no AnimationPlayer.")

	player_instancia.anim_player.play("run")
	assert(player_instancia.anim_player.current_animation == "run", "AnimationPlayer deve reproduzir animação solicitada.")

	testes_passaram += 1
	print("[TESTE 3/5 PASSOU] AnimationPlayer instanciado e animações idle, run e jump validadas.")

func _testar_squash_stretch_e_particulas() -> void:
	assert(player_instancia != null, "Instância do jogador deve existir para teste de squash & stretch.")

	var escala_original: Vector2 = player_instancia.base_sprite_scale
	player_instancia._aplicar_squash_stretch(Vector2(0.8, 1.3), 0.1)

	# A escala imediata deve refletir a deformação do squash & stretch
	assert(not player_instancia.sprite.scale.is_equal_approx(escala_original), "Escala do Sprite2D deve ser deformada no impacto.")
	assert(player_instancia.current_tween != null and player_instancia.current_tween.is_valid(), "Tween de retorno deve ser ativo e válido.")

	# Testa partícula de poeira
	var dust_scene: PackedScene = load("res://src/components/dust_particles.tscn")
	assert(dust_scene != null, "Cena dust_particles.tscn deve existir.")
	var dust: CPUParticles2D = dust_scene.instantiate()
	assert(dust.one_shot, "Partícula de poeira deve estar configurada como one_shot.")
	assert(dust.explosiveness >= 0.8, "Partícula de poeira deve ter alta explosividade.")
	dust.queue_free()

	testes_passaram += 1
	print("[TESTE 4/5 PASSOU] Squash & stretch dinâmico via Tween e partículas de poeira efêmeras validados.")

func _testar_screen_shake_e_trauma() -> void:
	assert(player_instancia != null, "Instância do jogador deve existir para teste de screen shake.")
	assert(player_instancia.camera != null, "Camera2D deve estar presente no jogador.")

	player_instancia.aplicar_shake(0.8)
	assert(player_instancia.trauma >= 0.8, "Trauma de screen shake deve ser registrado.")

	# Simula processamento de quadro de tela
	player_instancia._processar_screen_shake(0.016)
	assert(player_instancia.camera.offset != Vector2.ZERO, "Offset da câmera deve ser deslocado pelo tremor.")

	testes_passaram += 1
	print("[TESTE 5/5 PASSOU] Screen shake não linear com decaimento de trauma e offset de câmera homologado.")

func _concluir_testes() -> void:
	assert(testes_passaram == 5, "Todos os 5 testes de áudio, animação e game feel devem passar.")
	print("------------------------------------------------------------")
	print("TODOS OS %d TESTES DE ÁUDIO, ANIMAÇÃO E GAME FEEL APROVADOS." % testes_passaram)
	print("------------------------------------------------------------")
	get_tree().quit(0)
