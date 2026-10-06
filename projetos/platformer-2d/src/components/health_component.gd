# ARQUIVO: res://src/components/health_component.gd
# ANEXAR AO NODE: HealthComponent (Node)
# CENA: Qualquer entidade que possua vida (Player, Inimigo, Barricada)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Gerencia pontos de vida de forma desacoplada, emitindo sinais de dano, cura e morte sem conhecer quem o possui.
class_name HealthComponent
extends Node

signal health_changed(current: int, max_health: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died()

@export var max_health: int = 3:
	set(value):
		max_health = maxi(1, value)
		if current_health > max_health:
			current_health = max_health
			health_changed.emit(current_health, max_health)

@export var current_health: int = 3
@export var invulnerability_duration: float = 0.0

var is_invulnerable: bool = false
var _invulnerability_timer: float = 0.0

func _ready() -> void:
	current_health = clampi(current_health, 0, max_health)

func _process(delta: float) -> void:
	if is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0.0:
			is_invulnerable = false
			_invulnerability_timer = 0.0

func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead() or is_invulnerable:
		return

	current_health = maxi(0, current_health - amount)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

	if invulnerability_duration > 0.0:
		is_invulnerable = true
		_invulnerability_timer = invulnerability_duration

	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0 or is_dead():
		return

	var old_health: int = current_health
	current_health = mini(max_health, current_health + amount)
	var actual_healed: int = current_health - old_health
	if actual_healed > 0:
		healed.emit(actual_healed)
		health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0
