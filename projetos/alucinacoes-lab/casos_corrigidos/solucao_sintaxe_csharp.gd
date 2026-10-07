# ARQUIVO: res://casos_corrigidos/solucao_sintaxe_csharp.gd
# ANEXAR AO NODE: EntidadeVida (Node2D)
# CENA: res://casos_corrigidos/cena_entidade.tscn
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: nenhuma
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Declaracao correta em GDScript tipado com @export, Vector2 e print()

extends Node2D

# No GDScript nao existem modificadores 'public', 'private', nem 'new' para tipos nativos
@export var vida: int = 100
@export var velocidade: float = 250.0

func _ready() -> void:
	# Instanciacao nativa sem a palavra reservada 'new'
	position = Vector2(50.0, 50.0)
	# Saida de log padrao com print() ou print_rich(), nao Console.WriteLine ou Debug.Log
	print("Entidade inicializada na posicao: ", position)
