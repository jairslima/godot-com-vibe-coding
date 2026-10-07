extends SceneTree

func _init() -> void:
	var sprite := Sprite2D.new()
	sprite.play("andar")
	quit()
