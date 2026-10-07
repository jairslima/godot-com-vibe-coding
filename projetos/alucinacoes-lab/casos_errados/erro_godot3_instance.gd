extends SceneTree

func _init() -> void:
	var cena: PackedScene = PackedScene.new()
	var inst = cena.instance()
	quit()
