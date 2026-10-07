extends SceneTree

func _init() -> void:
	var btn := Button.new()
	btn.on_click.connect(_ao_clicar)
	quit()

func _ao_clicar() -> void:
	pass
