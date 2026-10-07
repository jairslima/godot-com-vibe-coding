# ARQUIVO: res://src/inventory_item.gd
# ANEXAR AO NODE: Não anexado a nó (Resource / RefCounted com class_name)
# CENA: res://tests/test_git_runner.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable
# RESULTADO ESPERADO: Representa um item coletável com identificador, peso e valor monetário.

class_name InventoryItem
extends RefCounted

var id: String = ""
var nome: String = ""
var peso: float = 0.0
var valor: int = 0

func _init(p_id: String = "", p_nome: String = "", p_peso: float = 0.0, p_valor: int = 0) -> void:
	id = p_id
	nome = p_nome
	peso = p_peso
	valor = p_valor

func validar() -> bool:
	return not id.is_empty() and peso >= 0.0 and valor >= 0

func descrever() -> String:
	return "%s (Peso: %.1fkg, Valor: %d moedas)" % [nome, peso, valor]
