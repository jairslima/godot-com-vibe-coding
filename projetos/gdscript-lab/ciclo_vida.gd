# ARQUIVO:
# res://ciclo_vida.gd
#
# ANEXAR AO NODE:
# CicloVidaDemo (Node)
#
# CENA:
# res://main.tscn (adicionado como nó filho)
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# Nenhuma
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Demonstra os métodos fundamentais do ciclo de vida e a independência de taxa de quadros via delta.

class_name CicloVidaDemo
extends Node

var tempo_acumulado_process: float = 0.0
var passos_fisica: int = 0
var quadros_render: int = 0

func _ready() -> void:
	print("--- TESTE 4: Ciclo de Vida do Nó ---")
	print("[_ready] Nó inicializado com sucesso na Scene Tree.")

func _process(delta: float) -> void:
	quadros_render += 1
	tempo_acumulado_process += delta
	# Demonstração contida para não poluir a saída em modo headless
	if quadros_render == 1:
		print("[_process] Primeiro quadro de renderização. Delta: ", delta)

func _physics_process(delta: float) -> void:
	passos_fisica += 1
	if passos_fisica == 1:
		print("[_physics_process] Primeiro passo da simulação de física. Delta fixo: ", delta)
