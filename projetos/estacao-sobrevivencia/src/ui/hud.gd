class_name HUD
extends CanvasLayer

## Interface visual do MVP da Estação Sobrevivência.
## Exibe cronômetro regressivo MM:SS, quantidade de ameaças ativas e avisos de status.

@onready var timer_label: Label = %TimerLabel
@onready var status_label: Label = %StatusLabel
@onready var creatures_label: Label = %CreaturesLabel

func _ready() -> void:
	status_label.visible = false

func atualizar_tempo(tempo_restante: float) -> void:
	var total_segundos: int = int(ceil(maxf(tempo_restante, 0.0)))
	var minutos: int = total_segundos / 60
	var segundos: int = total_segundos % 60
	timer_label.text = "%02d:%02d" % [minutos, segundos]

func atualizar_contagem_criaturas(quantidade: int) -> void:
	creatures_label.text = "Ameaças ativas: %d" % quantidade

func exibir_resultado(vitoria: bool, mensagem: String) -> void:
	status_label.visible = true
	if vitoria:
		status_label.text = "VITÓRIA!\n" + mensagem
		status_label.modulate = Color(0.2, 1.0, 0.4)
	else:
		status_label.text = "DERROTA!\n" + mensagem
		status_label.modulate = Color(1.0, 0.3, 0.3)
