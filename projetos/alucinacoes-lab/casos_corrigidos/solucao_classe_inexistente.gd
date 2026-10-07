# ARQUIVO: res://casos_corrigidos/solucao_classe_inexistente.gd
# ANEXAR AO NODE: AudioEfeito (AudioStreamPlayer2D)
# CENA: res://casos_corrigidos/cena_audio.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: nenhuma
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Toca audio posicional 2D com a classe nativa correta AudioStreamPlayer2D

extends AudioStreamPlayer2D

func disparar_som() -> void:
	# No Godot 4 a classe oficial de audio posicional 2D e AudioStreamPlayer2D
	# Nao existe SoundPlayer2D ou SoundManager nativo no motor
	if stream != null:
		play()
