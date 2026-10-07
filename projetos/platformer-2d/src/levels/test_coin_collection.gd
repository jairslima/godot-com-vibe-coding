# ARQUIVO: res://src/levels/test_coin_collection.gd
# ANEXAR AO NODE: TestCoinCollection (Node2D)
# CENA: res://src/levels/test_coin_collection.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/coin.gd, res://src/entities/player/player.gd, res://src/core/save_manager.gd, res://src/ui/hud.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa suíte automatizada headless com 5 testes do sistema de moedas: propriedades/grupos, emissão de sinal, prevenção de coleta dupla, colisão seletiva com Player e integração com SaveManager/HUD.
class_name TestCoinCollection
extends Node2D

const COIN_SCENE = preload("res://src/components/coin.tscn")
const HUD_SCENE = preload("res://src/ui/hud.tscn")
const PLAYER_SCENE = preload("res://src/entities/player/player.tscn")
const SAVE_MANAGER_SCRIPT = preload("res://src/core/save_manager.gd")

var save_manager: Node = null
var testes_passaram: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Obtém ou instancia SaveManager de forma autônoma para os testes
	save_manager = get_node_or_null("/root/SaveManager")
	if save_manager == null:
		save_manager = SAVE_MANAGER_SCRIPT.new()
		add_child(save_manager)

	print("============================================================")
	print("INICIANDO SUÍTE HEADLESS: SISTEMA DE MOEDAS COLECIONÁVEIS")
	print("============================================================")

	_testar_propriedades_e_grupo()
	_testar_coleta_e_sinal()
	_testar_prevencao_coleta_dupla()
	_testar_colisao_seletiva_com_player()
	_testar_integracao_save_manager_e_hud()
	_concluir_testes()

func _testar_propriedades_e_grupo() -> void:
	var coin: Coin = COIN_SCENE.instantiate()
	add_child(coin)

	assert(coin.is_in_group("coins"), "Moeda deve pertencer ao grupo 'coins'.")
	assert(coin.value == 10, "Valor padrão da moeda deve ser 10 pontos.")
	assert(coin.collision_layer == 0, "Moeda não deve ter collision_layer ativa (área passiva).")
	assert(coin.collision_mask == 2, "Moeda deve monitorar a camada 2 (Player).")
	assert(not coin.is_collected, "Moeda deve iniciar no estado não coletado.")

	coin.queue_free()
	testes_passaram += 1
	print("[TESTE 1/5 PASSOU] Propriedades, máscaras de colisão e grupo 'coins' validados.")

func _testar_coleta_e_sinal() -> void:
	var coin: Coin = COIN_SCENE.instantiate()
	add_child(coin)

	var estado := {"sinal_disparado": false, "valor_recebido": 0}

	coin.collected.connect(func(val: int):
		estado["sinal_disparado"] = true
		estado["valor_recebido"] = val
	)

	coin.coletar()

	assert(estado["sinal_disparado"], "O sinal 'collected' deve ser emitido ao invocar coletar().")
	assert(estado["valor_recebido"] == 10, "O valor emitido pelo sinal deve corresponder ao valor da moeda (10).")
	assert(coin.is_collected, "A propriedade is_collected deve ser verdadeira após a coleta.")

	testes_passaram += 1
	print("[TESTE 2/5 PASSOU] Emissão de sinal e marcação de estado da moeda validados.")

func _testar_prevencao_coleta_dupla() -> void:
	var coin: Coin = COIN_SCENE.instantiate()
	add_child(coin)

	var contagem := {"disparos": 0}
	coin.collected.connect(func(_val: int):
		contagem["disparos"] += 1
	)

	# Primeira coleta
	coin.coletar()
	assert(contagem["disparos"] == 1, "Primeira coleta deve disparar o sinal exatamente 1 vez.")

	# Segunda tentativa de coleta imediata (simulando múltiplos disparos de física no mesmo frame)
	coin.coletar()
	assert(contagem["disparos"] == 1, "Segunda tentativa de coleta NÃO deve re-emitir o sinal.")

	testes_passaram += 1
	print("[TESTE 3/5 PASSOU] Prevenção contra disparo duplo/coleta múltipla homologada.")

func _testar_colisao_seletiva_com_player() -> void:
	var coin: Coin = COIN_SCENE.instantiate()
	add_child(coin)

	var estado := {"coletou": false}
	coin.collected.connect(func(_v: int):
		estado["coletou"] = true
	)

	# 1. Simula entrada de corpo que NÃO é Player (ex.: obstáculo StaticBody2D)
	var corpo_estranho: StaticBody2D = StaticBody2D.new()
	add_child(corpo_estranho)
	coin._on_body_entered(corpo_estranho)
	assert(not estado["coletou"], "Corpos que não herdam de Player não devem ativar a moeda.")
	corpo_estranho.queue_free()

	# 2. Simula entrada de corpo que É Player
	var player_inst: Player = PLAYER_SCENE.instantiate()
	add_child(player_inst)
	coin._on_body_entered(player_inst)
	assert(estado["coletou"], "Instância de Player deve acionar a coleta da moeda.")
	player_inst.queue_free()

	testes_passaram += 1
	print("[TESTE 4/5 PASSOU] Colisão seletiva: filtra corpos genéricos e aceita Player.")

func _testar_integracao_save_manager_e_hud() -> void:
	save_manager.reiniciar_sessao()
	assert(save_manager.score == 0, "Pontuação inicial da sessão deve ser 0.")

	var hud_inst: HUD = HUD_SCENE.instantiate()
	add_child(hud_inst)

	var coin: Coin = COIN_SCENE.instantiate()
	coin.value = 25
	add_child(coin)

	# Simula a conexão que o Level01 realiza
	coin.collected.connect(func(val: int):
		save_manager.score += val
		hud_inst.atualizar_pontos(save_manager.score)
	)

	coin.coletar()

	assert(save_manager.score == 25, "Pontuação no SaveManager deve ser atualizada para 25.")
	assert(hud_inst.score_label != null and hud_inst.score_label.text == "25", "HUD deve refletir a pontuação atualizada '25'.")

	hud_inst.queue_free()
	testes_passaram += 1
	print("[TESTE 5/5 PASSOU] Integração desacoplada de pontuação com SaveManager e HUD aprovada.")

func _concluir_testes() -> void:
	assert(testes_passaram == 5, "Todos os 5 testes de moedas coletáveis devem passar.")
	print("------------------------------------------------------------")
	print("TODOS OS %d TESTES DO SISTEMA DE MOEDAS APROVADOS COM SUCESSO." % testes_passaram)
	print("------------------------------------------------------------")
	get_tree().quit(0)
