# ARQUIVO: res://tools/leitor_argumentos.gd
# ANEXAR AO NODE: Executado de forma autonoma como SceneTree (-s)
# CENA: Nenhuma (script de automacao de terminal)
# INPUTS NECESSARIOS: Nenhum
# DEPENDENCIAS: Nenhuma
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Captura e exibe argumentos passados pelo usuario apos o delimitador --
extends SceneTree

func _init() -> void:
	var argumentos: PackedStringArray = OS.get_cmdline_user_args()
	print("Quantidade de argumentos recebidos: ", argumentos.size())
	for item in argumentos:
		print("  -> Parametro: ", item)
	quit()
