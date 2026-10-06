class_name AudioSynth3D
extends RefCounted

## Gerador procedural de ondas sonoras sintéticas tridimensionais em memória RAM.
## Produz fluxos de áudio PCM para ambiência, motores e eventos sem dependências de arquivos externos.

## Gera um zumbido contínuo e grave de reator espacial com suporte a loop sem emendas.
static func create_reactor_hum(duration: float = 1.0, mix_rate: int = 22050) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var total_samples: int = int(duration * float(mix_rate))
	stream.loop_begin = 0
	stream.loop_end = total_samples
	
	var data := PackedByteArray()
	data.resize(total_samples)
	
	for i in range(total_samples):
		var t: float = float(i) / float(mix_rate)
		# Frequência fundamental de 55 Hz (nota Lá grave) com harmônico em 110 Hz
		var fundamental: float = sin(t * 55.0 * TAU) * 0.6
		var harmonic: float = sin(t * 110.0 * TAU) * 0.25
		var sub: float = sin(t * 27.5 * TAU) * 0.15
		var combined: float = fundamental + harmonic + sub
		var byte_val: int = clampi(int((combined * 0.5 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
	
	stream.data = data
	return stream

## Gera um bipe curto de confirmação eletrônica para consoles e terminais.
static func create_terminal_beep(duration: float = 0.15, mix_rate: int = 22050) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var total_samples: int = int(duration * float(mix_rate))
	var data := PackedByteArray()
	data.resize(total_samples)
	
	for i in range(total_samples):
		var progress: float = float(i) / float(total_samples)
		var t: float = float(i) / float(mix_rate)
		# Frequência crescente de 880 Hz para 1760 Hz
		var freq: float = 880.0 + (880.0 * progress)
		var envelope: float = 1.0 - progress
		var wave: float = sin(t * freq * TAU) * envelope
		var byte_val: int = clampi(int((wave * 0.5 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
	
	stream.data = data
	return stream

## Gera um pulso harmônico de ressonância ao coletar um núcleo de energia.
static func create_core_pickup(duration: float = 0.25, mix_rate: int = 22050) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var total_samples: int = int(duration * float(mix_rate))
	var data := PackedByteArray()
	data.resize(total_samples)
	
	for i in range(total_samples):
		var progress: float = float(i) / float(total_samples)
		var t: float = float(i) / float(mix_rate)
		# Três tons harmônicos empilhados com decaimento exponencial
		var freq: float = 440.0 + (440.0 * progress)
		var envelope: float = (1.0 - progress) * (1.0 - progress)
		var wave: float = (sin(t * freq * TAU) * 0.6 + sin(t * freq * 1.5 * TAU) * 0.4) * envelope
		var byte_val: int = clampi(int((wave * 0.5 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
	
	stream.data = data
	return stream

## Gera um zumbido oscilante modulado em frequência para o propulsor do drone sentinela.
static func create_drone_engine(duration: float = 0.8, mix_rate: int = 22050) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var total_samples: int = int(duration * float(mix_rate))
	stream.loop_begin = 0
	stream.loop_end = total_samples
	
	var data := PackedByteArray()
	data.resize(total_samples)
	
	for i in range(total_samples):
		var t: float = float(i) / float(mix_rate)
		# Modulação FM: centro em 130 Hz, oscilando ±20 Hz a uma taxa de 5 Hz
		var mod: float = sin(t * 5.0 * TAU) * 20.0
		var freq: float = 130.0 + mod
		var wave: float = sin(t * freq * TAU) * 0.7
		var byte_val: int = clampi(int((wave * 0.5 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
	
	stream.data = data
	return stream
