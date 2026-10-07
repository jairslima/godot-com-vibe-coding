# ARQUIVO:
# res://laboratorio_runner.gd
#
# ANEXAR AO NODE:
# Executado como script principal via SceneTree CLI
#
# CENA:
# Nenhuma (execucao direta em modo headless)
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# res://cenarios_bugs/caso1_null_instance.gd
# res://cenarios_bugs/caso2_no_nao_encontrado.gd
# res://cenarios_bugs/caso3_sinal_desconectado.gd
# res://cenarios_bugs/caso4_erro_tipagem.gd
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Executar as quatro solucoes do laboratorio de debugging, confirmando sucesso via asserts.

extends SceneTree

func _init() -> void:
	print("==================================================")
	print("INICIANDO LABORATORIO DE DEBUGGING - ARENA 2D BUGS")
	print("Engine: Godot 4.7.2 Stable")
	print("==================================================")
	
	# Caso 1: Null Instance
	var c1 = CasoNullInstance.new()
	root.add_child(c1)
	var r1 = c1.executar_solucao()
	assert(r1, "Falha no Caso 1!")
	
	# Caso 2: No Nao Encontrado
	var c2 = CasoNoNaoEncontrado.new()
	root.add_child(c2)
	var r2 = c2.executar_solucao()
	assert(r2, "Falha no Caso 2!")
	
	# Caso 3: Sinal Desconectado
	var c3 = CasoSinalDesconectado.new()
	root.add_child(c3)
	var r3 = c3.executar_solucao()
	assert(r3, "Falha no Caso 3!")
	
	# Caso 4: Erro de Tipagem
	var c4 = CasoErroTipagem.new()
	root.add_child(c4)
	var r4 = c4.executar_solucao()
	assert(r4, "Falha no Caso 4!")
	
	print("==================================================")
	print("TODOS OS 4 CASOS DO LABORATORIO FORAM VALIDADOS!")
	print("==================================================")
	quit(0)
