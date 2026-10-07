class_name ObjectiveManager
extends Node

## Gerenciador de objetivos da estação espacial (checkpoint station3d-04-objectives).
## Rastreia núcleos de energia coletados e ativação do terminal principal via sinais desacoplados.

signal core_count_updated(current: int, total: int)
signal power_restored()
signal status_message_updated(message: String)

@export var required_cores: int = 3

var collected_cores: int = 0
var is_power_active: bool = false

func _ready() -> void:
	emit_current_status()

func register_core_collected() -> void:
	collected_cores += 1
	core_count_updated.emit(collected_cores, required_cores)
	
	if collected_cores < required_cores:
		var remaining: int = required_cores - collected_cores
		status_message_updated.emit("Núcleo coletado! Faltam %d para reativar o terminal." % remaining)
	else:
		status_message_updated.emit("Todos os núcleos recuperados! Dirija-se ao Terminal Principal.")

func can_restore_power() -> bool:
	return collected_cores >= required_cores

func restore_power() -> bool:
	if not can_restore_power():
		status_message_updated.emit("Energia insuficiente. Requer %d núcleos de energia." % required_cores)
		return false
	
	if is_power_active:
		return true
	
	is_power_active = true
	power_restored.emit()
	status_message_updated.emit("Energia auxiliar da estação restaurada com sucesso!")
	return true

func emit_current_status() -> void:
	core_count_updated.emit(collected_cores, required_cores)
