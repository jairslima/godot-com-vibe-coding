# ARQUIVO:
# res://entidade.gd
#
# ANEXAR AO NODE:
# Entidade (Node2D) ou classes derivadas
#
# CENA:
# res://main.tscn (instanciado ou como classe base)
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
# Gerencia estado, emissão de sinais tipados e execução de Callables.

class_name Entidade
extends Node2D

# Enumerações para controle de estados de jogo
enum Estado {
	PARADO,
	PATRULHA,
	ALERTA,
	PERSEGUINDO
}

# Propriedades expostas no painel Inspector via anotação @export
@export var nome_entidade: String = "Entidade Base"
@export var vida_maxima: int = 100

# Variáveis internas com tipagem estática
var vida_atual: int = 100
var estado_atual: Estado = Estado.PARADO

# Sinais declarados com tipos de parâmetros explícitos
signal vida_alterada(nova_vida: int, vida_max: int)
signal entidade_derrotada(nome: String)

func _ready() -> void:
	vida_atual = vida_maxima

# Método de recepção de dano com emissão de sinais
func receber_dano(quantidade: int) -> void:
	if quantidade <= 0:
		return
	
	vida_atual = maxi(0, vida_atual - quantidade)
	vida_alterada.emit(vida_atual, vida_maxima)
	
	if vida_atual == 0:
		entidade_derrotada.emit(nome_entidade)

# Método de restauração de vida
func curar(quantidade: int) -> void:
	if quantidade <= 0:
		return
	vida_atual = mini(vida_maxima, vida_atual + quantidade)
	vida_alterada.emit(vida_atual, vida_maxima)

# Método que recebe uma função como objeto de primeira classe (Callable)
func executar_com_modificador(modificador: Callable) -> void:
	if modificador.is_valid():
		var resultado: Variant = modificador.call(vida_atual)
		print("Callback Callable executado. Novo valor retornado: ", resultado)

# Transição de estado com validação
func definir_estado(novo_estado: Estado) -> void:
	estado_atual = novo_estado
