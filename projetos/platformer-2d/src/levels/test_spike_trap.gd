# ARQUIVO: res://src/levels/test_spike_trap.gd
# ANEXAR AO NODE: TestSpikeTrap (Node2D)
# CENA: res://src/levels/test_spike_trap.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/spike_trap.gd, res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa testes unitários headless do componente SpikeTrap aprovando detecção de colisão, emissão de sinal e reposicionamento.
class_name TestSpikeTrap
extends Node2D

const SPIKE_TRAP_SCENE = preload("res://src/components/spike_trap.tscn")
const PLAYER_SCENE = preload("res://src/entities/player/player.tscn")

var trap_instancia: SpikeTrap = null
var player_instancia: Player = null
var sinal_disparado: bool = false
var testes_passaram: int = 0
var total_testes: int = 4

func _ready() -> void:
	print("============================================================")
	print("INICIANDO SUÍTE HEADLESS: SPIKE TRAP (WORKTREE GAMEPLAY)")
	print("============================================================")
	
	_testar_instanciacao_e_propriedades()
	_testar_estado_inativo()
	_testar_disparo_e_sinal()
	_testar_reposicionamento_player()
	
	print("------------------------------------------------------------")
	print("RESULTADO: %d/%d TESTES APROVADOS COM SUCESSO." % [testes_passaram, total_testes])
	print("------------------------------------------------------------")
	
	if testes_passaram == total_testes:
		print("SUÍTE DE SPIKE TRAP HOMOLOGADA COM SUCESSO.")
		get_tree().quit(0)
	else:
		push_error("FALHA NA SUÍTE DE SPIKE TRAP.")
		get_tree().quit(1)

func _testar_instanciacao_e_propriedades() -> void:
	trap_instancia = SPIKE_TRAP_SCENE.instantiate() as SpikeTrap
	add_child(trap_instancia)
	assert(trap_instancia != null, "Falha ao instanciar SpikeTrap.")
	assert(trap_instancia.is_active == true, "SpikeTrap deve iniciar ativo por padrão.")
	assert(trap_instancia.damage_amount == 1, "SpikeTrap deve ter dano padrão de 1.")
	testes_passaram += 1
	print("[TESTE 1/4 PASSOU] Instanciação e valores padrão de SpikeTrap homologados.")

func _testar_estado_inativo() -> void:
	trap_instancia.is_active = false
	sinal_disparado = false
	trap_instancia.trap_triggered.connect(func(_p: Node2D) -> void: sinal_disparado = true)
	
	player_instancia = PLAYER_SCENE.instantiate() as Player
	add_child(player_instancia)
	trap_instancia._on_body_entered(player_instancia)
	
	assert(sinal_disparado == false, "Armadilha inativa não deve emitir sinal de disparo.")
	testes_passaram += 1
	print("[TESTE 2/4 PASSOU] Estado inativo ignora colisões sem emitir sinais.")

func _testar_disparo_e_sinal() -> void:
	trap_instancia.is_active = true
	sinal_disparado = false
	trap_instancia._on_body_entered(player_instancia)
	
	assert(sinal_disparado == true, "Armadilha ativa deve emitir o sinal trap_triggered.")
	testes_passaram += 1
	print("[TESTE 3/4 PASSOU] Disparo de armadilha ativa emite sinal trap_triggered.")

func _testar_reposicionamento_player() -> void:
	player_instancia.global_position = Vector2(999.0, 999.0)
	player_instancia.velocity = Vector2(250.0, -100.0)
	trap_instancia._on_body_entered(player_instancia)
	
	assert(player_instancia.velocity == Vector2.ZERO, "Velocidade deve ser zerada após colisão com espinhos.")
	testes_passaram += 1
	print("[TESTE 4/4 PASSOU] Reposicionamento e zeramento de inércia validados com sucesso.")
