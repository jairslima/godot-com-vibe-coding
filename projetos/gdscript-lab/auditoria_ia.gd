# ARQUIVO:
# res://auditoria_ia.gd
#
# ANEXAR AO NODE:
# Script conceitual e de validação de auditoria
#
# CENA:
# Não aplicável (estudo de caso comparativo)
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
# Demonstra o padrão correto de correção para os 3 erros clássicos gerados por assistentes de IA.

class_name AuditoriaIADemo
extends RefCounted

# ==============================================================================
# CASO CORRIGIDO PARA AUDITORIA (CÓDIGO VÁLIDO NO GODOT 4.7.2)
# ==============================================================================

# Erro 1 corrigido: tipagem estática rigorosa sem misturar tipos incompatíveis
var pontuacao_fase: int = 1500

# Erro 2 corrigido: anotação @onready ou inicialização controlada para evitar acesso a nó nulo
# (Em nós reais derivados de Node, usaria: @onready var rotulo: Label = $HUD/Rotulo)

# Erro 3 corrigido: conexão de sinais com a sintaxe moderna de Callable do Godot 4
# Em vez de connect("sinal", self, "funcao"), usa-se:
# botao.pressed.connect(_on_botao_pressed)

static func somar_pontos(base: int, bonus: int) -> int:
	return base + bonus
