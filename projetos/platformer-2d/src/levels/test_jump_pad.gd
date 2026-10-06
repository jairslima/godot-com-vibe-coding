# ARQUIVO: res://src/levels/test_jump_pad.gd
# ANEXAR AO NODE: TestJumpPad (Node2D)
# CENA: res://src/levels/test_jump_pad.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/jump_pad.gd, res://src/components/jump_pad.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa suíte automatizada headless com 5 asserções aprovadas cobrindo: propriedades/máscaras, aplicação de impulso vertical, emissão de sinal, bloqueio por cooldown e descarte de entidades incompatíveis.
class_name TestJumpPad
extends Node2D

const JUMP_PAD_SCENE = preload("res://src/components/jump_pad.tscn")

var testes_passaram: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("============================================================")
	print("INICIANDO SUÍTE HEADLESS: COMPONENTE JUMP PAD (BENCHMARK)")
	print("============================================================")
	
	_testar_propriedades_e_mascaras()
	_testar_aplicacao_impulso()
	_testar_emissao_sinal()
	_testar_cooldown_disparo_rapido()
	_testar_rejeicao_entidade_incompativel()
	_concluir_testes()

func _testar_propriedades_e_mascaras() -> void:
	var pad: JumpPad = JUMP_PAD_SCENE.instantiate() as JumpPad
	add_child(pad)
	
	assert(pad.is_in_group("jump_pads"), "JumpPad deve pertencer ao grupo 'jump_pads'.")
	assert(pad.launch_force == 650.0, "Força padrão de impulso deve ser 650.0.")
	assert(pad.collision_layer == 0, "JumpPad não deve ter camada de colisão ativa (área passiva).")
	assert(pad.collision_mask == 2, "JumpPad deve monitorar camada 2 (Player).")
	
	pad.queue_free()
	testes_passaram += 1
	print("[TESTE 1/5 PASSOU] Propriedades, máscaras e grupo validados.")

func _testar_aplicacao_impulso() -> void:
	var pad: JumpPad = JUMP_PAD_SCENE.instantiate() as JumpPad
	add_child(pad)
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.velocity = Vector2(100.0, 50.0)
	add_child(dummy_player)
	
	var disparou: bool = pad.trigger_launch(dummy_player)
	
	assert(disparou, "trigger_launch deve retornar true para CharacterBody2D válido.")
	assert(dummy_player.velocity.y == -650.0, "Velocidade vertical deve ser exatamente -launch_force (-650.0).")
	assert(dummy_player.velocity.x == 100.0, "Velocidade horizontal deve ser preservada inalterada.")
	
	dummy_player.queue_free()
	pad.queue_free()
	testes_passaram += 1
	print("[TESTE 2/5 PASSOU] Aplicação de velocidade vetorial vertical homologada.")

func _testar_emissao_sinal() -> void:
	var pad: JumpPad = JUMP_PAD_SCENE.instantiate() as JumpPad
	add_child(pad)
	
	var dummy_player := CharacterBody2D.new()
	add_child(dummy_player)
	
	var dados_sinal := {"disparou": false, "alvo": null, "forca": 0.0}
	pad.launched.connect(func(alvo: Node2D, forca: float):
		dados_sinal["disparou"] = true
		dados_sinal["alvo"] = alvo
		dados_sinal["forca"] = forca
	)
	
	pad.trigger_launch(dummy_player)
	
	assert(dados_sinal["disparou"], "Sinal 'launched' deve ser emitido.")
	assert(dados_sinal["alvo"] == dummy_player, "O alvo emitido deve ser o CharacterBody2D que entrou.")
	assert(dados_sinal["forca"] == 650.0, "A força emitida deve ser 650.0.")
	
	dummy_player.queue_free()
	pad.queue_free()
	testes_passaram += 1
	print("[TESTE 3/5 PASSOU] Sinal tipado 'launched' emitido com parâmetros corretos.")

func _testar_cooldown_disparo_rapido() -> void:
	var pad: JumpPad = JUMP_PAD_SCENE.instantiate() as JumpPad
	add_child(pad)
	
	var dummy_player := CharacterBody2D.new()
	add_child(dummy_player)
	
	var primeira_tentativa: bool = pad.trigger_launch(dummy_player)
	assert(primeira_tentativa, "Primeiro acionamento deve ter sucesso.")
	
	# Segundo acionamento imediato sem intervalo
	var segunda_tentativa: bool = pad.trigger_launch(dummy_player)
	assert(not segunda_tentativa, "Segundo acionamento imediato deve ser bloqueado pelo cooldown.")
	
	dummy_player.queue_free()
	pad.queue_free()
	testes_passaram += 1
	print("[TESTE 4/5 PASSOU] Proteção de cooldown contra disparo múltiplo no mesmo frame homologada.")

func _testar_rejeicao_entidade_incompativel() -> void:
	var pad: JumpPad = JUMP_PAD_SCENE.instantiate() as JumpPad
	add_child(pad)
	
	var no_estranho := Node2D.new()
	add_child(no_estranho)
	
	var resultado: bool = pad.trigger_launch(no_estranho)
	assert(not resultado, "JumpPad não deve acionar impulso em nós que não sejam CharacterBody2D.")
	
	no_estranho.queue_free()
	pad.queue_free()
	testes_passaram += 1
	print("[TESTE 5/5 PASSOU] Rejeição segura de nós arbitrários confirmada.")

func _concluir_testes() -> void:
	print("============================================================")
	print("SUÍTE JUMP PAD CONCLUÍDA: %d/5 TESTES PASSARAM COM SUCESSO." % testes_passaram)
	print("============================================================")
	get_tree().quit(0)
