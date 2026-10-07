extends Node

func _ready() -> void:
	print("Olá, Godot! Projeto inicial configurado com sucesso.")
	var info: Dictionary = Engine.get_version_info()
	print("Versão em execução: %s.%s.%s (%s)" % [info.major, info.minor, info.patch, info.status])
