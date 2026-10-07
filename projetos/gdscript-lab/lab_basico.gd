# ARQUIVO:
# res://lab_basico.gd
#
# ANEXAR AO NODE:
# Script utilitário / biblioteca (herda de RefCounted)
#
# CENA:
# Utilizado por res://main.tscn e res://lab_runner.gd
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
# Executa testes lógicos de sintaxe, tipos, coleções e controle de fluxo, imprimindo dados no terminal.

class_name LabBasico
extends RefCounted

# Constantes tipadas
const DANO_BASE: int = 15
const VERSAO_LAB: String = "1.0.0"

# Demonstração de variáveis e inferência de tipos
static func testar_variaveis() -> void:
	print("--- TESTE 1: Variáveis e Inferência de Tipos ---")
	
	# Tipagem explícita estática
	var vida: int = 100
	var velocidade: float = 250.5
	var nome_jogador: String = "Arqueiro"
	var esta_vivo: bool = true
	var posicao_inicial: Vector2 = Vector2(120.0, 80.0)
	
	# Inferência estática de tipo usando :=
	# O compilador infere que 'escudo' é int e proíbe atribuir outros tipos
	var escudo := 50
	var multiplicador := 1.25
	
	print("Jogador: ", nome_jogador, " | Vida: ", vida, " | Escudo: ", escudo)
	print("Posição: ", posicao_inicial, " | Velocidade: ", velocidade * multiplicador)
	print("Status ativo: ", esta_vivo)

# Demonstração de funções e operadores aritméticos
static func calcular_dano_final(dano_recebido: int, armadura: int) -> int:
	var reducao: int = armadura / 2
	var dano_calculado: int = dano_recebido - reducao
	if dano_calculado < 1:
		return 1
	return dano_calculado

# Demonstração de condicionais e estrutura match
static func testar_condicionais(nivel_alerta: int) -> String:
	# Estrutura match: alternativa moderna e eficiente ao switch/case
	match nivel_alerta:
		0:
			return "Seguro"
		1, 2:
			return "Suspeito"
		3:
			return "Combate Iminente"
		_:
			return "Alerta Máximo"

# Demonstração de coleções: Arrays e Dictionaries tipados
static func testar_colecoes() -> void:
	print("--- TESTE 2: Arrays e Dicionários Tipados ---")
	
	# Array estritamente tipado (apenas números inteiros)
	var pontuacoes: Array[int] = [100, 250, 400]
	pontuacoes.append(550)
	
	print("Pontuações registradas: ", pontuacoes)
	print("Total de registros: ", pontuacoes.size())
	
	# Iteração com for in
	var soma_pontos: int = 0
	for ponto: int in pontuacoes:
		soma_pontos += ponto
	print("Soma das pontuações: ", soma_pontos)
	
	# Dicionário com tipos definidos para chave e valor
	var inventario: Dictionary[String, int] = {
		"pocao_vida": 3,
		"flechas": 24,
		"chaves": 1
	}
	
	inventario["moedas"] = 150
	print("Inventário do jogador: ", inventario)
	print("Quantidade de flechas: ", inventario.get("flechas", 0))

# Demonstração de repetições (loops)
static func testar_loops() -> void:
	print("--- TESTE 3: Loops com for e while ---")
	
	# Loop com range (início, fim exclusivo, passo)
	var contagem_regressiva: Array[int] = []
	for i in range(3, 0, -1):
		contagem_regressiva.append(i)
	print("Contagem regressiva: ", contagem_regressiva)
	
	# Loop while com controle de parada seguro
	var energia: int = 10
	var passos: int = 0
	while energia > 0:
		energia -= 3
		passos += 1
	print("Esgotamento de energia em ", passos, " etapas.")
