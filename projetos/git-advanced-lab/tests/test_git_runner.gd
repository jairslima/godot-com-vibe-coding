# ARQUIVO: res://tests/test_git_runner.gd
# ANEXAR AO NODE: TestGitRunner (Node)
# CENA: res://tests/test_git_runner.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/inventory_item.gd, res://src/loot_chest.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable
# RESULTADO ESPERADO: Executa asserções de validação de itens e baús e encerra com código 0.

extends Node

const InventoryItem = preload("res://src/inventory_item.gd")
const LootChest = preload("res://src/loot_chest.gd")

func _ready() -> void:
	print("--- INICIANDO TESTES DO GIT ADVANCED LAB ---")
	
	var item_valido = InventoryItem.new("espada_ferro", "Espada de Ferro", 2.5, 150)
	assert(item_valido.validar(), "Item valido deve passar na validacao.")
	assert(item_valido.id == "espada_ferro", "ID deve corresponder ao configurado.")
	assert(item_valido.peso == 2.5, "Peso deve ser 2.5.")
	assert(item_valido.valor == 150, "Valor deve ser 150.")
	assert(item_valido.descrever().contains("150 moedas"), "Descricao deve conter as moedas.")
	
	var bau = LootChest.new(2)
	assert(bau.adicionar_item(item_valido), "Primeiro item deve entrar no bau.")
	var item_2 = InventoryItem.new("pocao_vida", "Pocao de Vida", 0.5, 25)
	assert(bau.adicionar_item(item_2), "Segundo item deve entrar no bau.")
	var item_extra = InventoryItem.new("escudo", "Escudo", 4.0, 80)
	assert(not bau.adicionar_item(item_extra), "Nao deve aceitar item acima da capacidade.")
	
	var recompensa = bau.abrir()
	assert(recompensa.size() == 2, "Bau deve entregar os 2 itens ao abrir.")
	assert(bau.abrir().is_empty(), "Bau ja aberto deve entregar lista vazia.")
	
	print("[SUCESSO] Todas as 8 assercoes do Git Advanced Lab foram aprovadas!")
	get_tree().quit(0)
