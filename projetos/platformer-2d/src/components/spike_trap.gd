# ARQUIVO: res://src/components/spike_trap.gd
# ANEXAR AO NODE: SpikeTrap (Area2D)
# CENA: res://src/components/spike_trap.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta colisão do Player sobre espinhos, causando respawn imediato e emitindo sinal de armadilha ativada.
class_name SpikeTrap
extends Area2D

signal trap_triggered(body: Node2D)

@export var is_active: bool = true
@export var damage_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body is Player:
		trap_triggered.emit(body)
		var sm: Node = get_node_or_null("/root/SaveManager")
		var spawn_pos: Vector2 = Vector2(100.0, 300.0)
		if sm != null and sm.has_method("obter_ponto_respawn"):
			spawn_pos = sm.obter_ponto_respawn(spawn_pos)
		body.global_position = spawn_pos
		body.velocity = Vector2.ZERO
