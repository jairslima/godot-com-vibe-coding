# ARQUIVO:
# res://apendice_b_ref.gd
#
# ANEXAR AO NODE:
# Nenhum (classe de referência, herda de RefCounted)
#
# CENA:
# Nenhuma (validação estática via --check-only)
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
# Passa na validação estática (godot --check-only) sem erros de parse.
# Consolida os trechos de referência do Apêndice B.

class_name ApendiceBRef
extends RefCounted

# --- Tipos primitivos ---
var vida_maxima: int = 100
var taxa_regeneracao: float = 2.5
var nome_personagem: String = "Valente"
var esta_vivo: bool = true
var posicao_inicial: Vector2 = Vector2(120.0, 80.0)
var eixo_frente: Vector3 = Vector3(0, 0, -1)
var cor_alerta: Color = Color(1, 0, 0, 1)

# --- Inferência com := ---
var armadura := 50
var multiplicador_critico := 1.75
var esta_invencivel := false
var vetor_empurrao := Vector2.ZERO

# --- Constantes ---
const GRAVIDADE_PADRAO: float = 980.0
const CAPACIDADE_INVENTARIO: int = 20

# --- Estado usado nos exemplos ---
var vida_atual: int = 100

# --- Funções tipadas ---
func calcular_dano_final(dano_base: int, armadura_alvo: int) -> int:
	var reducao: int = armadura_alvo / 2
	var dano_final: int = dano_base - reducao
	if dano_final < 1:
		return 1
	return dano_final

func aplicar_efeito_cura(quantidade: int) -> void:
	vida_atual = mini(vida_maxima, vida_atual + quantidade)
	print("Vida recuperada: ", quantidade, " | Atual: ", vida_atual)

# --- Condicionais ---
func executar_morte() -> void:
	pass

func ativar_efeito_alerta_visual() -> void:
	pass

func manter_comportamento_padrao() -> void:
	pass

func avaliar_estado() -> void:
	if vida_atual <= 0:
		executar_morte()
	elif vida_atual < 20:
		ativar_efeito_alerta_visual()
	else:
		manter_comportamento_padrao()

# --- match ---
func descrever_estado_alerta(nivel: int) -> String:
	match nivel:
		0:
			return "Área Segura"
		1, 2:
			return "Atividade Suspeita Detectada"
		3:
			return "Inimigo em Combate Ativo"
		_:
			return "Estado Desconhecido ou Emergência Crítica"

# --- Loops ---
func contar_passos() -> void:
	for i in range(5):
		print("Passo da contagem: ", i)
	for contagem in range(10, 0, -2):
		print("Tempo restante: ", contagem)
	var energia_restante: int = 15
	while energia_restante > 0:
		energia_restante -= 4
		print("Consumindo energia... Saldo: ", energia_restante)

# --- Coleções ---
func trabalhar_colecoes() -> void:
	var pontuacoes: Array[int] = [100, 250, 400]
	pontuacoes.append(550)
	print("Total de registros: ", pontuacoes.size())
	if pontuacoes.has(550):
		pontuacoes.erase(550)
	pontuacoes.clear()
	for ponto: int in pontuacoes:
		print("Pontuação: ", ponto)
	var inventario: Dictionary[String, int] = {
		"pocao_cura": 3,
		"flechas": 24,
		"chaves_ouro": 1
	}
	inventario["moedas"] = 150
	var total_bombas: int = inventario.get("bombas", 0)
	print("Total de bombas: ", total_bombas)

# --- Herança com extends e super (classes internas) ---
class InimigoBase:
	extends RefCounted

	func receber_dano(quantidade: int) -> void:
		print("Dano base: ", quantidade)

class InimigoChefe:
	extends InimigoBase

	func receber_dano(quantidade: int) -> void:
		print("Efeito visual de impacto no chefe!")
		super.receber_dano(quantidade)

# --- Enums ---
enum EstadoInimigo {
	PARADO,
	PATRULHA,
	ALERTA,
	PERSEGUINDO
}

var estado_atual: EstadoInimigo = EstadoInimigo.PARADO

func aguardar_jogador() -> void:
	pass

func percorrer_caminho() -> void:
	pass

func correr_atras_do_alvo() -> void:
	pass

func atualizar_comportamento() -> void:
	match estado_atual:
		EstadoInimigo.PARADO:
			aguardar_jogador()
		EstadoInimigo.PATRULHA:
			percorrer_caminho()
		EstadoInimigo.PERSEGUINDO:
			correr_atras_do_alvo()

# --- Sinais e Callables ---
signal vida_alterada(nova_vida: int, vida_max: int)
signal personagem_morreu(nome: String)

func aplicar_dano(dano: int) -> void:
	vida_atual = maxi(0, vida_atual - dano)
	vida_alterada.emit(vida_atual, vida_maxima)
	if vida_atual == 0:
		personagem_morreu.emit(nome_personagem)

func _on_vida_alterada(nova_vida: int, vida_max: int) -> void:
	print("Interface atualizada: ", nova_vida, " de ", vida_max)

func conectar_sinal() -> void:
	vida_alterada.connect(_on_vida_alterada)

func registrar_callback_rapido() -> void:
	var operacao_duplicar := func(valor: int) -> int:
		return valor * 2
	print("Resultado do Callable anônimo: ", operacao_duplicar.call(25))

# --- Utilitários frequentes ---
const ICONE := preload("res://icon.svg")

func carregar_em_execucao() -> void:
	var textura: Texture2D = load("res://icon.svg")
	print("Carregado: ", textura)

func exemplo_assert() -> void:
	assert(vida_maxima > 0, "A vida máxima deve ser positiva")
	assert(is_instance_valid(self), "A instância precisa existir")

func exemplo_limites() -> void:
	var valor_limitado: float = clampf(1.7, 0.0, 1.0)
	var vida_cheia: int = mini(vida_maxima, vida_atual + 10)
	var vida_nao_negativa: int = maxi(0, vida_atual - 5)
	print(valor_limitado, vida_cheia, vida_nao_negativa)
