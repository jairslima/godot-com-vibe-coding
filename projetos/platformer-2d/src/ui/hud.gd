# ARQUIVO: res://src/ui/hud.gd
# ANEXAR AO NODE: HUD (CanvasLayer)
# CENA: res://src/ui/hud.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Exibe vida do jogador e contador de moedas/pontos no CanvasLayer de forma desacoplada por sinais.
class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var score_label: Label = %ScoreLabel

func _ready() -> void:
	if health_bar != null:
		health_bar.min_value = 0
		health_bar.max_value = 3
		health_bar.value = 3
	if health_label != null:
		health_label.text = "VIDA: 3 / 3"
	if score_label != null:
		score_label.text = "00"

func atualizar_vida(atual: int, maxima: int) -> void:
	if health_bar != null:
		health_bar.max_value = maxi(1, maxima)
		health_bar.value = clampi(atual, 0, maxima)
	if health_label != null:
		health_label.text = "VIDA: %d / %d" % [atual, maxima]

func atualizar_pontos(pontos: int) -> void:
	if score_label != null:
		score_label.text = "%02d" % pontos
