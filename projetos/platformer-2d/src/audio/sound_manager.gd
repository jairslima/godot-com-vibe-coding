# ARQUIVO: res://src/audio/sound_manager.gd
# ANEXAR AO NODE: Utilitário GDScript estático (RefCounted)
# CENA: Nenhuma (utilitário de suporte a áudio e game feel)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Síntese procedural de efeitos sonoros em tempo de execução e reprodução de sons com variação de tom (pitch) e barramento SFX.
class_name SoundManager
extends RefCounted

## Gerenciador e sintetizador de áudio procedural para o Projeto Plataforma 2D.
## Gera ondas PCM diretamente na memória RAM e instancia reprodutores efêmeros.

static var _som_pulo: AudioStreamWAV = null
static var _som_pouso: AudioStreamWAV = null
static var _som_impacto: AudioStreamWAV = null
static var _som_moeda: AudioStreamWAV = null

## Retorna o som procedural de salto sintetizado.
static func obter_som_pulo() -> AudioStreamWAV:
	if _som_pulo == null:
		_som_pulo = _sintetizar_pulo()
	return _som_pulo

## Retorna o som procedural de aterrissagem sintetizado.
static func obter_som_pouso() -> AudioStreamWAV:
	if _som_pouso == null:
		_som_pouso = _sintetizar_pouso()
	return _som_pouso

## Retorna o som procedural de impacto / dano sintetizado.
static func obter_som_impacto() -> AudioStreamWAV:
	if _som_impacto == null:
		_som_impacto = _sintetizar_impacto()
	return _som_impacto

## Retorna o som procedural de moeda / item sintetizado.
static func obter_som_moeda() -> AudioStreamWAV:
	if _som_moeda == null:
		_som_moeda = _sintetizar_moeda()
	return _som_moeda

## Reproduz um AudioStream com variação de pitch em um nó pai, destruindo o reprodutor ao término.
static func tocar_som(
	origem: Node,
	stream: AudioStream,
	pitch_min: float = 0.94,
	pitch_max: float = 1.06,
	volume_db: float = 0.0,
	bus: StringName = &"SFX"
) -> AudioStreamPlayer:
	if origem == null or not origem.is_inside_tree():
		return null

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_min, pitch_max)

	origem.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	return player

# --- GERADORES PROCEDURAIS DE ONDA PCM ---

static func _sintetizar_pulo() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false

	var duracao: float = 0.12
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)

	for i in range(total_amostras):
		var progresso: float = float(i) / float(total_amostras)
		var freq: float = 240.0 + (progresso * 360.0) # Tom ascendente
		var envelope: float = 1.0 - progresso
		var t: float = float(i) / float(stream.mix_rate)
		var onda: float = sin(t * freq * TAU) * envelope
		dados[i] = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)

	stream.data = dados
	return stream

static func _sintetizar_pouso() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false

	var duracao: float = 0.08
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)

	for i in range(total_amostras):
		var progresso: float = float(i) / float(total_amostras)
		var freq: float = 140.0 * (1.0 - progresso) + 40.0 # Tom surdo e baixo
		var envelope: float = (1.0 - progresso) * (1.0 - progresso)
		var t: float = float(i) / float(stream.mix_rate)
		var onda: float = sin(t * freq * TAU) * envelope
		dados[i] = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)

	stream.data = dados
	return stream

static func _sintetizar_impacto() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false

	var duracao: float = 0.16
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)

	for i in range(total_amostras):
		var progresso: float = float(i) / float(total_amostras)
		var freq: float = 380.0 - (progresso * 260.0)
		var envelope: float = 1.0 - progresso
		var t: float = float(i) / float(stream.mix_rate)
		# Onda com saturação suave para corpo metálico / pancada
		var onda: float = clampf(sin(t * freq * TAU) * 1.5, -1.0, 1.0) * envelope
		dados[i] = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)

	stream.data = dados
	return stream

static func _sintetizar_moeda() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false

	var duracao: float = 0.18
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)

	for i in range(total_amostras):
		var progresso: float = float(i) / float(total_amostras)
		var freq: float = 587.33 if progresso < 0.5 else 880.0 # Arpejo clássico
		var envelope: float = 1.0 - progresso
		var t: float = float(i) / float(stream.mix_rate)
		var onda: float = sin(t * freq * TAU) * envelope
		dados[i] = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)

	stream.data = dados
	return stream
