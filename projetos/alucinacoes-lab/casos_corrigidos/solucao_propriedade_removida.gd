# ARQUIVO: res://casos_corrigidos/solucao_propriedade_removida.gd
# ANEXAR AO NODE: BotaoMenu (Button)
# CENA: res://casos_corrigidos/cena_ui.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: nenhuma
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Configura posicao e dimensao de no Control usando position e size

extends Button

func configurar_geometria() -> void:
	# No Godot 4 as propriedades rect_position e rect_size do Godot 3 foram unificadas
	# Utiliza-se position e size em todos os nos derivados de Control
	position = Vector2(100.0, 150.0)
	size = Vector2(200.0, 50.0)
