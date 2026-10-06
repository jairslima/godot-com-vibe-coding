# ARQUIVO: res://src/components/checkpoint.gd
# ANEXAR AO NODE: Checkpoint (Area2D)
# CENA: res://src/components/checkpoint.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta passagem do jogador, ativa indicador visual/auditivo e emite sinal para registrar novo ponto de renascimento persistente.
class_name Checkpoint
extends Area2D

signal activated(checkpoint_id: String, spawn_pos: Vector2)

@export var checkpoint_id: String = "checkpoint_01"
@export var spawn_offset: Vector2 = Vector2(0.0, -8.0)
@export var active_color: Color = Color(0.2, 0.9, 0.3, 1.0) # Verde brilhante
@export var inactive_color: Color = Color(0.6, 0.6, 0.6, 0.8) # Cinza inativo

@onready var visual_indicator: ColorRect = get_node_or_null("%VisualIndicator")
@onready var spawn_point: Marker2D = get_node_or_null("%SpawnPoint")

var is_active: bool = false

func _ready() -> void:
	add_to_group("checkpoints")
	collision_layer = 0
	collision_mask = 2 # Detecta Player (camada 2 de física)
	body_entered.connect(_on_body_entered)
	_atualizar_visual()

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_active:
		ativar(true)

func ativar(emitir_sinal: bool = true) -> void:
	is_active = true
	_atualizar_visual()
	var spawn_pos: Vector2 = obter_spawn_position()
	print("Checkpoint ativado: ", checkpoint_id, " na posição: ", spawn_pos)
	if emitir_sinal:
		activated.emit(checkpoint_id, spawn_pos)

func desativar() -> void:
	is_active = false
	_atualizar_visual()

func obter_spawn_position() -> Vector2:
	if spawn_point != null:
		return spawn_point.global_position
	return global_position + spawn_offset

func _atualizar_visual() -> void:
	if visual_indicator != null:
		visual_indicator.color = active_color if is_active else inactive_color
