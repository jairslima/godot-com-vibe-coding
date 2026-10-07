# ARQUIVO: res://src/components/dust_particles.gd
# ANEXAR AO NODE: DustParticles (CPUParticles2D)
# CENA: res://src/components/dust_particles.tscn
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Emite uma explosão pontual de partículas de poeira (one-shot) e se destrói automaticamente ao concluir.
class_name DustParticles
extends CPUParticles2D

func _ready() -> void:
	emitting = true
	one_shot = true
	finished.connect(queue_free)
