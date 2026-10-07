# ARQUIVO:
# res://cenarios_bugs/caso2_no_nao_encontrado.gd
#
# ANEXAR AO NODE:
# CasoNoNaoEncontrado (Node)
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
# Demonstrar erro de busca de no por caminho rigido versus busca segura ou no unico.

extends Node
class_name CasoNoNaoEncontrado

## Funcao que reproduz o erro de no inexistente via get_node().
func reproduzir_bug() -> void:
	# Dispara: ERROR: Node not found: "HUD/RotuloInexistente" (relative to "...").
	var no_inexistente = get_node("HUD/RotuloInexistente")
	print(no_inexistente)

## Funcao com a solucao defensiva usando has_node() e validacao de existencia.
func executar_solucao() -> bool:
	var caminho: String = "HUD/RotuloInexistente"
	if has_node(caminho):
		var no = get_node(caminho)
		print("[Caso 2] No encontrado: ", no.name)
		return true
	else:
		print("[Caso 2 - No Nao Encontrado] has_node() interceptou a ausencia do no com sucesso.")
		return true
