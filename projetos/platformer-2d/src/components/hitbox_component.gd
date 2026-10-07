# ARQUIVO: res://src/components/hitbox_component.gd
# ANEXAR AO NODE: HitboxComponent (Area2D)
# CENA: Qualquer área que cause dano (espada, projétil, corpo hostil)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Define uma área ofensiva que transporta um valor numérico de dano ao colidir com HurtboxComponents.
class_name HitboxComponent
extends Area2D

@export var damage: int = 1
