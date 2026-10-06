extends Node2D

## Sinal desacoplado de atualizacao de pontuacao.
signal pontuacao_alterada(pontos: int)

@onready var player: CharacterBody2D = %Player
@onready var hud: CanvasLayer = %HUD
@onready var spawner: Node2D = %Spawner

var pontuacao: int = 0
var em_game_over: bool = false
var tempo_acumulado: float = 0.0

func _ready() -> void:
	print("Arena 2D inicializada!")
	
	# Conexoes arquiteturais desacopladas (Call down, signal up)
	player.vida_alterada.connect(_on_player_vida_alterada)
	player.morreu.connect(_on_player_morreu)
	pontuacao_alterada.connect(hud.atualizar_pontuacao)
	
	# Sincronizacao inicial da interface com o estado do jogo
	hud.atualizar_vida(player.vida_atual, player.vida_maxima)
	hud.atualizar_pontuacao(pontuacao)

func _process(delta: float) -> void:
	if not em_game_over:
		# Acumula tempo de sobrevivencia para gerar pontuacao continua
		tempo_acumulado += delta
		if tempo_acumulado >= 1.0:
			tempo_acumulado -= 1.0
			pontuacao += 10
			pontuacao_alterada.emit(pontuacao)
	else:
		# Escuta a acao mapeada de reinicio apos Game Over
		if Input.is_action_just_pressed("reiniciar"):
			print("Reiniciando arena...")
			get_tree().reload_current_scene()

func _on_player_vida_alterada(atual: int, maxima: int) -> void:
	hud.atualizar_vida(atual, maxima)

func _on_player_morreu() -> void:
	em_game_over = true
	spawner.parar()
	hud.exibir_game_over()
	print("Rodada encerrada. Pontuacao final: ", pontuacao)
