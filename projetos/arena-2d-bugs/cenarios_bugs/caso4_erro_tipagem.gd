# ARQUIVO:
# res://cenarios_bugs/caso4_erro_tipagem.gd
#
# ANEXAR AO NODE:
# CasoErroTipagem (Node)
#
# CENA:
# res://cenarios_bugs/cenario_bugs.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# Nenhum
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Demonstrar erro de tipagem estatica incompativel e resolucao por conversao segura.

extends Node
class_name CasoErroTipagem

## Funcao tipada estritamente com inteiro.
func aplicar_dano(quantidade: int) -> int:
	return maxi(0, 100 - quantidade)

## Funcao que reproduz erro de tipo incompativel em tempo de execucao.
func reproduzir_bug() -> void:
	var valor_incorreto: Variant = "cinquenta"
	# Dispara: SCRIPT ERROR: Invalid type in function 'aplicar_dano'... Cannot convert argument 1 from String to int.
	aplicar_dano(valor_incorreto)

## Funcao com a solucao segura: conversao e validacao de tipo estatico.
func executar_solucao() -> bool:
	var entrada_bruta: Variant = "50"
	var quantidade_segura: int = 0
	
	if entrada_bruta is int:
		quantidade_segura = entrada_bruta
	elif entrada_bruta is String and (entrada_bruta as String).is_valid_int():
		quantidade_segura = (entrada_bruta as String).to_int()
	else:
		push_warning("Entrada de tipo inesperado, utilizando valor padrao zero.")
	
	var vida_restante: int = aplicar_dano(quantidade_segura)
	assert(vida_restante == 50, "A vida restante calculada deveria ser exatamente 50!")
	print("[Caso 4 - Tipagem] Conversao estatica e calculo validados com sucesso. Vida: ", vida_restante)
	return true
