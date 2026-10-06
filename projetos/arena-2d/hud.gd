extends CanvasLayer

@onready var rotulo_vida: Label = %RotuloVida
@onready var rotulo_stamina: Label = %RotuloStamina
@onready var rotulo_pontos: Label = %RotuloPontos
@onready var mensagem_game_over: Label = %MensagemGameOver

func _ready() -> void:
	mensagem_game_over.text = ""
	rotulo_pontos.text = "Pontos: 0"
	rotulo_stamina.text = "Stamina: 100 / 100"
	print("HUD inicializado com sucesso!")

## Atualiza a interface com a vida informada pelo sinal.
func atualizar_vida(atual: int, maxima: int) -> void:
	rotulo_vida.text = "Vida: %d / %d" % [atual, maxima]

## Atualiza a interface com a stamina informada pelo sinal.
func atualizar_stamina(atual: float, maxima: float) -> void:
	rotulo_stamina.text = "Stamina: %d / %d" % [roundi(atual), roundi(maxima)]

## Atualiza a exibicao da pontuacao atual.
func atualizar_pontuacao(pontos: int) -> void:
	rotulo_pontos.text = "Pontos: %d" % pontos

## Exibe alerta visual de fim de jogo e instrucao de reinicio.
func exibir_game_over() -> void:
	mensagem_game_over.text = "FIM DE JOGO!\nPressione R para reiniciar"
	print("HUD exibindo alerta visual de derrota com instrucao de restart.")
