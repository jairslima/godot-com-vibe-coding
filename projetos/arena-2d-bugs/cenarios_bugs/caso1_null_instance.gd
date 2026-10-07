# ARQUIVO:
# res://cenarios_bugs/caso1_null_instance.gd
#
# ANEXAR AO NODE:
# CasoNullInstance (Node)
#
# CENA:
# res://cenarios_bugs/cenario_bugs.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# res://hud.tscn
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Demonstrar a diferenca entre acesso nulo e inicializacao defensiva garantida.

extends Node
class_name CasoNullInstance

## Referencia tipada para demonstracao do caso corrigido
var hud_valido: CanvasLayer = null

## Funcao que reproduz o erro de ponteiro nulo (Nil) em tempo de execucao.
func reproduzir_bug() -> void:
	var hud_nulo: CanvasLayer = null
	# Chamada que resulta em: SCRIPT ERROR: Cannot call method 'atualizar_vida' on a null value.
	hud_nulo.atualizar_vida(80, 100)

## Funcao com a solucao defensiva e verificacao de instancia valida.
func executar_solucao() -> bool:
	if hud_valido == null or not is_instance_valid(hud_valido):
		# Cria uma instancia sob demanda ou busca na arvore com seguranca
		hud_valido = CanvasLayer.new()
		add_child(hud_valido)
	
	if is_instance_valid(hud_valido):
		print("[Caso 1 - Null Instance] Instancia valida confirmada. Execucao segura concluida.")
		return true
	return false
