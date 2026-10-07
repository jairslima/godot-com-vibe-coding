# ARQUIVO: res://src/components/coin.gd
# ANEXAR AO NODE: Coin (Area2D)
# CENA: res://src/components/coin.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta colisão com o Player, emite sinal collected, desativa monitoramento para prevenir coletas múltiplas no mesmo quadro físico e é liberado da memória com queue_free.
class_name Coin
extends Area2D

signal collected(value: int)

@export var value: int = 10
@export var coin_color: Color = Color(1.0, 0.85, 0.1, 1.0)

@onready var visual_indicator: ColorRect = get_node_or_null("%VisualIndicator")
@onready var collision_shape: CollisionShape2D = get_node_or_null("%CollisionShape2D")

var is_collected: bool = false

func _ready() -> void:
	add_to_group("coins")
	collision_layer = 0
	collision_mask = 2 # Camada 2: Player
	body_entered.connect(_on_body_entered)
	_configurar_visual()

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is Player:
		coletar()

func coletar() -> void:
	if is_collected:
		return
	is_collected = true
	# Desativa detecção física imediatamente para prevenir disparos múltiplos
	set_deferred("monitoring", false)
	collected.emit(value)
	queue_free()

func _configurar_visual() -> void:
	if visual_indicator != null:
		visual_indicator.color = coin_color
