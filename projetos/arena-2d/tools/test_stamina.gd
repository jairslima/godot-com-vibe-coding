# ARQUIVO: res://tools/test_stamina.gd
# ANEXAR AO NODE: TestStamina (Node2D)
# CENA: res://tools/test_stamina.tscn
# INPUTS NECESSARIOS: move_left, move_right, move_up, move_down, sprint
# DEPENDENCIAS: res://player.tscn
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Valida matematicamente a mecanica de stamina, consumo, regeneracao e limites sem interface grafica
extends Node2D

func _ready() -> void:
	print("Iniciando bateria de testes automatizados da feature de stamina...")
	
	# Aguarda um quadro para que o ambiente de fisica 2D esteja completamente inicializado
	await get_tree().physics_frame
	
	var player_scene: PackedScene = load("res://player.tscn")
	assert(player_scene != null, "Falha critica: player.tscn nao foi carregado.")
	
	var player: CharacterBody2D = player_scene.instantiate()
	add_child(player)
	
	# Aguarda outro quadro de fisica para sincronizacao do servidor de fisica
	await get_tree().physics_frame
	
	# Teste 1: Estado inicial
	assert(player.stamina_atual == player.stamina_maxima, "Teste 1 falhou: stamina inicial incorreta.")
	assert(player.stamina_atual == 100.0, "Teste 1 falhou: valor base diferente de 100.0.")
	print("  [OK] Teste 1: Stamina inicial configurada em 100.0.")
	
	# Teste 2: Consumo com simulacao de sprint ativo
	Input.action_press("move_right")
	Input.action_press("sprint")
	player._physics_process(1.0)
	
	var stamina_esperada_1: float = 100.0 - player.consumo_stamina
	assert(is_equal_approx(player.stamina_atual, stamina_esperada_1), "Teste 2 falhou: consumo em 1s incorreto.")
	assert(player.esta_correndo == true, "Teste 2 falhou: flag esta_correndo nao ativada.")
	assert(player.velocity.x == player.speed * player.multiplicador_sprint, "Teste 2 falhou: velocidade de sprint incorreta.")
	print("  [OK] Teste 2: Consumo e multiplicador de sprint validados em 1 segundo.")
	
	# Teste 3: Consumo ate o esgotamento (nao pode ser menor que zero)
	player._physics_process(2.0)
	assert(player.stamina_atual == 0.0, "Teste 3 falhou: stamina nao travou em 0.0.")
	print("  [OK] Teste 3: Invariante de limite inferior (stamina >= 0.0) aprovada.")
	
	# Teste 4: Tentativa de correr sem stamina (deve retornar a velocidade normal e nao regenerar)
	player._physics_process(0.5)
	assert(player.velocity.x == player.speed, "Teste 4 falhou: velocidade nao retornou ao normal com stamina zerada.")
	assert(player.esta_correndo == false, "Teste 4 falhou: esta_correndo permaneceu ativo sem stamina.")
	assert(player.stamina_atual == 0.0, "Teste 4 falhou: stamina regenerou enquanto tentava correr.")
	print("  [OK] Teste 4: Bloqueio de corrida com stamina esgotada validado.")
	
	# Teste 5: Regeneracao de stamina em repouso
	Input.action_release("sprint")
	Input.action_release("move_right")
	player._physics_process(1.0)
	assert(is_equal_approx(player.stamina_atual, player.regeneracao_stamina), "Teste 5 falhou: regeneracao em 1s incorreta.")
	print("  [OK] Teste 5: Regeneracao em repouso validada (25.0/s).")
	
	# Teste 6: Invariante de teto maximo (nao ultrapassa stamina_maxima)
	player._physics_process(10.0)
	assert(player.stamina_atual == player.stamina_maxima, "Teste 6 falhou: stamina ultrapassou valor maximo.")
	print("  [OK] Teste 6: Invariante de limite superior (stamina <= stamina_maxima) aprovada.")
	
	player.queue_free()
	print("Todos os 6 testes unitarios da feature de stamina foram aprovados com sucesso!")
	get_tree().quit(0)
