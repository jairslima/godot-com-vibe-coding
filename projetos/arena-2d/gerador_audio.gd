class_name GeradorAudio
extends RefCounted

## Gerador procedural de efeitos sonoros sinteticos para a Arena 2D.
## Produz ondas de audio nativas em memoria RAM sem dependencia de arquivos externos.

## Cria um efeito sonoro de impacto (hit) curto e sintetizado proceduralmente.
static func criar_som_hit() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	
	var duracao: float = 0.12
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)
	
	for i in range(total_amostras):
		var t: float = float(i) / float(stream.mix_rate)
		var freq: float = 350.0 - (230.0 * (float(i) / float(total_amostras)))
		var envelope: float = 1.0 - (float(i) / float(total_amostras))
		var onda: float = sin(t * freq * TAU) * envelope
		var byte_val: int = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)
		dados[i] = byte_val
	
	stream.data = dados
	return stream

## Cria um efeito sonoro de derrota (game over) com tom descendente.
static func criar_som_game_over() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	
	var duracao: float = 0.4
	var total_amostras: int = int(duracao * stream.mix_rate)
	var dados := PackedByteArray()
	dados.resize(total_amostras)
	
	for i in range(total_amostras):
		var t: float = float(i) / float(stream.mix_rate)
		var freq: float = 280.0 * (1.0 - (float(i) / float(total_amostras))) + 60.0
		var envelope: float = 1.0 - (float(i) / float(total_amostras))
		var onda: float = sin(t * freq * TAU) * envelope
		var byte_val: int = clampi(int((onda * 0.5 + 0.5) * 255.0), 0, 255)
		dados[i] = byte_val
	
	stream.data = dados
	return stream
