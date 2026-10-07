# ARQUIVO: res://casos_corrigidos/solucao_sinal_inventado.gd
# ANEXAR AO NODE: BotaoAcao (Button)
# CENA: res://casos_corrigidos/cena_botao.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: nenhuma
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Conecta ao sinal nativo pressed usando Callables tipados

extends Button

var cliques_registrados: int = 0

func _ready() -> void:
	# O sinal oficial de clique em Button no Godot 4 e 'pressed'
	# Nao existe on_click ou clicked na classe BaseButton
	pressed.connect(_ao_pressionar)

func _ao_pressionar() -> void:
	cliques_registrados += 1
