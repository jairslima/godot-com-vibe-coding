# ARQUIVO: res://casos_corrigidos/solucao_godot3_migracao.gd
# ANEXAR AO NODE: Invocador (Node)
# CENA: res://casos_corrigidos/cena_invocador.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: PackedScene valida
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Instancia cena com instantiate() e aguarda com await sem erros

extends Node

func instanciar_entidade(cena: PackedScene) -> Node:
	# No Godot 4 o metodo oficial e instantiate(), substituindo o antigo instance() do Godot 3
	if cena == null:
		return null
	var instancia := cena.instantiate()
	return instancia

func temporizar_evento() -> void:
	# No Godot 4 a espera assincrona utiliza await, substituindo o antigo yield() do Godot 3
	await get_tree().create_timer(0.1).timeout
