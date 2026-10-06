# ARQUIVO: res://src/components/jump_pad.gd
# ANEXAR AO NODE: JumpPad (Area2D)
# CENA: res://src/components/jump_pad.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma (opera via detecção de CharacterBody2D e sinais desacoplados)
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta entidades do tipo CharacterBody2D na camada física correspondente, aplica impulso vertical para cima, altera a escala visual momentaneamente e emite o sinal launched.
class_name JumpPad
extends Area2D

signal launched(body: Node2D, force: float)

@export var launch_force: float = 650.0
@export var cooldown_time: float = 0.25

@onready var visual_indicator: ColorRect = get_node_or_null("%VisualIndicator")

var _tempo_ultimo_disparo: float = -1.0

func _ready() -> void:
	add_to_group("jump_pads")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	trigger_launch(body)

func trigger_launch(body: Node2D) -> bool:
	if body == null:
		return false
	
	# Verifica se é um corpo com física que responde a velocidade vertical
	if not (body is CharacterBody2D):
		return false
	
	# Previne acionamentos múltiplos no mesmo instante ou durante cooldown
	var tempo_atual := Time.get_ticks_msec() / 1000.0
	if _tempo_ultimo_disparo >= 0.0 and (tempo_atual - _tempo_ultimo_disparo) < cooldown_time:
		return false
	
	_tempo_ultimo_disparo = tempo_atual
	
	# Aplica o impulso vertical diretamente à velocidade do corpo
	var character := body as CharacterBody2D
	character.velocity.y = -launch_force
	
	# Feedback visual de compressão/distorção
	_animar_impacto()
	
	launched.emit(character, launch_force)
	return true

func _animar_impacto() -> void:
	if visual_indicator == null:
		return
	
	var tween := create_tween()
	if tween:
		tween.tween_property(visual_indicator, "scale", Vector2(1.3, 0.6), 0.06)
		tween.tween_property(visual_indicator, "scale", Vector2(1.0, 1.0), 0.12)
