# ARQUIVO:
# res://main.gd
#
# ANEXAR AO NODE:
# Main (Node2D)
#
# CENA:
# res://main.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# res://lab_basico.gd, res://entidade.gd, res://inimigo.gd, res://ciclo_vida.gd
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Orquestra os testes laboratoriais de GDScript na Scene Tree e exibe os resultados formatados no console.

extends Node2D

# Acesso a nós filhos via anotação @onready e atalhos $ e %
@onready var inimigo: Inimigo = $Inimigo
@onready var status_rotulo: Label = %StatusRotulo

func _ready() -> void:
	print("==================================================")
	print("      GDSCRIPT LAB BY JAIR LIMA - TESTES REAIS    ")
	print("==================================================")
	
	# 1. Testes de tipos, variáveis e coleções
	LabBasico.testar_variaveis()
	LabBasico.testar_colecoes()
	LabBasico.testar_loops()
	
	var dano_calculado: int = LabBasico.calcular_dano_final(LabBasico.DANO_BASE, 8)
	print("Cálculo aritmético de dano com armadura: ", dano_calculado)
	
	var estado_texto: String = LabBasico.testar_condicionais(1)
	print("Avaliação de alerta via match: ", estado_texto)
	
	# 2. Testes de nós, sinais e acesso com % e $
	print("\n--- TESTE 5: Acesso a Nós e Conexão de Sinais ---")
	print("Nó acessado via $: ", inimigo.name, " (Tipo: ", inimigo.get_class(), ")")
	print("Nó acessado via %: ", status_rotulo.name, " (Texto inicial: '", status_rotulo.text, "')")
	
	# Conexão de sinais tipados com métodos Callable
	inimigo.vida_alterada.connect(_on_inimigo_vida_alterada)
	inimigo.entidade_derrotada.connect(_on_inimigo_derrotado)
	
	# Aplicação de dano para disparar sinais
	inimigo.receber_dano(35)
	inimigo.receber_dano(75)
	
	# Demonstração de função anônima passada como Callable
	var cura_dobrada := func(vida: int) -> int:
		return vida + 50
	inimigo.executar_com_modificador(cura_dobrada)
	
	print("\n==================================================")
	print("      FIM DA BATERIA DE TESTES DO GDSCRIPT        ")
	print("==================================================")

func _on_inimigo_vida_alterada(nova_vida: int, vida_max: int) -> void:
	status_rotulo.text = "HP: %d/%d" % [nova_vida, vida_max]
	print("[SINAL vida_alterada] ", inimigo.nome_entidade, " agora possui ", status_rotulo.text)

func _on_inimigo_derrotado(nome: String) -> void:
	print("[SINAL entidade_derrotada] Alerta: ", nome, " foi abatido em combate!")
