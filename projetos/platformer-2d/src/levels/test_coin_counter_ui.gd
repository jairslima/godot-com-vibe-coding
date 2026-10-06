# ARQUIVO: res://src/levels/test_coin_counter_ui.gd
# ANEXAR AO NODE: TestCoinCounterUI (Node2D)
# CENA: res://src/levels/test_coin_counter_ui.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/ui/hud.gd, res://src/ui/hud.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa testes headless do contador de moedas do HUD aprovando ícone, formatação com três dígitos e proteção contra valores negativos.
class_name TestCoinCounterUI
extends Node2D

const HUD_SCENE = preload("res://src/ui/hud.tscn")

var hud_instancia: HUD = null
var testes_passaram: int = 0
var total_testes: int = 4

func _ready() -> void:
	print("============================================================")
	print("INICIANDO SUÍTE HEADLESS: CONTADOR DE MOEDAS (WORKTREE UI)")
	print("============================================================")

	_testar_instanciacao_e_icone()
	_testar_formato_inicial()
	_testar_atualizacao_de_pontos()
	_testar_valor_negativo()

	print("------------------------------------------------------------")
	print("RESULTADO: %d/%d TESTES APROVADOS COM SUCESSO." % [testes_passaram, total_testes])
	print("------------------------------------------------------------")

	if testes_passaram == total_testes:
		print("SUÍTE DE CONTADOR DE MOEDAS HOMOLOGADA COM SUCESSO.")
		get_tree().quit(0)
	else:
		push_error("FALHA NA SUÍTE DE CONTADOR DE MOEDAS.")
		get_tree().quit(1)

func _testar_instanciacao_e_icone() -> void:
	hud_instancia = HUD_SCENE.instantiate() as HUD
	add_child(hud_instancia)
	assert(hud_instancia != null, "Falha ao instanciar o HUD.")
	assert(hud_instancia.coin_icon != null, "CoinIcon deve existir na cena do HUD.")
	assert(hud_instancia.coin_icon.text == "●", "CoinIcon deve exibir o símbolo de moeda.")
	testes_passaram += 1
	print("[TESTE 1/4 PASSOU] Instanciação do HUD e ícone de moeda homologados.")

func _testar_formato_inicial() -> void:
	assert(hud_instancia.score_label != null, "ScoreLabel deve existir na cena do HUD.")
	assert(hud_instancia.score_label.text == "000", "Contador deve iniciar com três dígitos zerados.")
	testes_passaram += 1
	print("[TESTE 2/4 PASSOU] Formato inicial de três dígitos validado.")

func _testar_atualizacao_de_pontos() -> void:
	hud_instancia.atualizar_pontos(35)
	assert(hud_instancia.score_label.text == "035", "Contador deve exibir 035 após 35 moedas.")
	assert(hud_instancia.total_moedas == 35, "Variável total_moedas deve refletir 35.")
	testes_passaram += 1
	print("[TESTE 3/4 PASSOU] Atualização de pontos e preenchimento com zero à esquerda validados.")

func _testar_valor_negativo() -> void:
	hud_instancia.atualizar_pontos(-5)
	assert(hud_instancia.score_label.text == "000", "Contador deve proteger contra valores negativos.")
	assert(hud_instancia.total_moedas == 0, "Variável total_moedas deve ser zerada com valor negativo.")
	testes_passaram += 1
	print("[TESTE 4/4 PASSOU] Proteção contra valores negativos validada com sucesso.")
