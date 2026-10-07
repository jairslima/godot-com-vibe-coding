# ARQUIVO: res://src/loot_chest.gd
# ANEXAR AO NODE: Não anexado a nó (Resource / RefCounted com class_name)
# CENA: res://tests/test_git_runner.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/inventory_item.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable
# RESULTADO ESPERADO: Gerencia um baú de tesouro com capacidade máxima e lista de itens tipados.

class_name LootChest
extends RefCounted

const InventoryItem = preload("res://src/inventory_item.gd")

var aberto: bool = false
var itens: Array = []
var capacidade_maxima: int = 5

func _init(p_capacidade: int = 5) -> void:
	capacidade_maxima = p_capacidade
	itens = []

func adicionar_item(item: RefCounted) -> bool:
	if itens.size() >= capacidade_maxima:
		return false
	itens.append(item)
	return true

func abrir() -> Array:
	if aberto:
		return []
	aberto = true
	var recompensa = itens.duplicate()
	itens.clear()
	return recompensa
