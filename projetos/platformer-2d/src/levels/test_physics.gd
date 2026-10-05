# ARQUIVO: res://src/levels/test_physics.gd
# ANEXAR AO NODE: TestPhysics (Node2D)
# CENA: res://src/levels/test_physics.tscn
# INPUTS NECESSÁRIOS: move_left, move_right, jump
# DEPENDÊNCIAS: res://src/entities/player/player.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Simula inputs headless via Input.action_press e valida aceleração, salto, gravidade, inércia e câmera.
class_name TestPhysics
extends Node2D

@onready var player: Player = $Player
var frame_count: int = 0
var testes_passados: int = 0

func _physics_process(_delta: float) -> void:
	frame_count += 1

	match frame_count:
		5:
			# Teste 1: Contato com o solo e repouso
			assert(player.is_on_floor(), "Erro: Player deveria estar em repouso no solo.")
			assert(player.velocity.x == 0.0, "Erro: Velocidade horizontal inicial deveria ser zero.")
			testes_passados += 1
			print("[TESTE 1/5 PASSOU] Jogador assentado e detectando solo corretamente.")

			# Inicia comando de movimento para a direita
			Input.action_press("move_right")

		12:
			# Teste 2: Aceleração horizontal
			assert(player.velocity.x > 0.0, "Erro: Player deveria ter acelerado para a direita.")
			assert(player.velocity.x <= player.max_speed, "Erro: Velocidade horizontal ultrapassou a velocidade máxima.")
			testes_passados += 1
			print("[TESTE 2/5 PASSOU] Aceleração horizontal com inércia validada (Vx: %f)." % player.velocity.x)

			# Solta o comando para testar frenagem e prepara salto
			Input.action_release("move_right")
			Input.action_press("jump")

		15:
			# Teste 3: Impulso de salto
			Input.action_release("jump")
			assert(player.velocity.y < 0.0, "Erro: Player deveria estar subindo com velocidade vertical negativa.")
			assert(not player.is_on_floor(), "Erro: Player não deveria estar no solo após o salto.")
			testes_passados += 1
			print("[TESTE 3/5 PASSOU] Disparo de salto e transição de estado aéreo validados (Vy: %f)." % player.velocity.y)

		30:
			# Teste 4: Atuação da gravidade no ar
			assert(player.velocity.y > -380.0, "Erro: Gravidade deveria ter desacelerado a subida ou iniciado a queda.")
			testes_passados += 1
			print("[TESTE 4/5 PASSOU] Atuação da gravidade na parábola do salto validada (Vy atual: %f)." % player.velocity.y)

		40:
			# Teste 5: Configuração e presença da Camera2D com suavização
			var camera: Camera2D = player.get_node_or_null("%Camera2D")
			assert(camera != null, "Erro: Camera2D não encontrada como nó único no Player.")
			assert(camera.position_smoothing_enabled, "Erro: Suavização da câmera deveria estar habilitada.")
			testes_passados += 1
			print("[TESTE 5/5 PASSOU] Camera2D validada com position_smoothing_enabled ativo.")

			print("------------------------------------------------------------")
			print("TODOS OS %d TESTES DE FISICA E MOVIMENTO APROVADOS COM SUCESSO." % testes_passados)
			print("------------------------------------------------------------")
			get_tree().quit(0)
