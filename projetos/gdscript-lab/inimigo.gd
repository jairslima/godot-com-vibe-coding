# ARQUIVO:
# res://inimigo.gd
#
# ANEXAR AO NODE:
# Inimigo (Node2D derivado de Entidade)
#
# CENA:
# res://main.tscn (instanciado como nó filho)
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# res://entidade.gd
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Demonstra herança com extends, sobrescrita de método com super e anotação @onready.

class_name Inimigo
extends Entidade

@export var recompensa_moedas: int = 25

# Anotação @onready: busca a referência ao nó filho logo após a entrada na árvore
@onready var indicador_alerta: Marker2D = get_node_or_null("IndicadorAlerta")

func _ready() -> void:
	# Executa a inicialização da classe base Entidade
	super._ready()
	nome_entidade = "Goblin Lanceiro"
	print("Inimigo instanciado: ", nome_entidade, " com vida ", vida_atual)

# Sobrescrita do método da classe base
func receber_dano(quantidade: int) -> void:
	print("Inimigo ", nome_entidade, " foi atingido por ", quantidade, " de dano.")
	# Chamada ao método original da classe ancestral
	super.receber_dano(quantidade)
	
	if vida_atual > 0:
		definir_estado(Estado.PERSEGUINDO)
		print("Inimigo entrou em modo de perseguição!")
