# ARQUIVO: res://casos_corrigidos/solucao_no_errado.gd
# ANEXAR AO NODE: AnimacaoPersonagem (AnimatedSprite2D)
# CENA: res://casos_corrigidos/cena_animacao.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: SpriteFrames configurado
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa animacoes atraves da classe com o metodo play(): AnimatedSprite2D

extends AnimatedSprite2D

func executar_animacao(nome_animacao: StringName) -> void:
	# Sprite2D apenas exibe texturas estaticas e nao possui o metodo play()
	# Para tocar animacoes quadro a quadro utiliza-se AnimatedSprite2D
	# Para animacoes por interpolacao de propriedades utiliza-se AnimationPlayer
	if sprite_frames != null and sprite_frames.has_animation(nome_animacao):
		play(nome_animacao)
