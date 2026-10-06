# ARQUIVO: res://src/components/hurtbox_component.gd
# ANEXAR AO NODE: HurtboxComponent (Area2D)
# CENA: Qualquer entidade receptora de impacto (Player, Inimigo)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: res://src/components/health_component.gd, res://src/components/hitbox_component.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Detecta colisões com HitboxComponents e delega a redução de dano ao HealthComponent associado.
class_name HurtboxComponent
extends Area2D

signal hit_received(hitbox: HitboxComponent)

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		if health_component != null:
			health_component.take_damage(hitbox.damage)
		hit_received.emit(hitbox)
