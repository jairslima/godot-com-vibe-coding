# ARQUIVO: res://extrair_contexto.gd
# ANEXAR AO NODE: Executado via CLI como SceneTree
# CENA: res://main.tscn (ou qualquer cena informada)
# INPUTS NECESSÁRIOS: Nenhum
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Imprime no terminal as acoes do Input Map e a hierarquia da cena principal.
extends SceneTree

func _init() -> void:
	print("==================================================")
	print("RELATÓRIO DE CONTEXTO DO PROJETO: GODOT 4.7.2")
	print("==================================================")
	
	_imprimir_input_map()
	_imprimir_arvore_cena("res://main.tscn")
	
	quit()

func _imprimir_input_map() -> void:
	print("\n[INPUT MAP: AÇÕES CUSTOMIZADAS]")
	var acoes_encontradas: int = 0
	for acao in InputMap.get_actions():
		if not acao.begins_with("ui_"):
			print("  * Acao: ", acao)
			acoes_encontradas += 1
	if acoes_encontradas == 0:
		print("  (Nenhuma acao customizada encontrada)")

func _imprimir_arvore_cena(caminho_cena: String) -> void:
	print("\n[SCENE TREE: HIERARQUIA DE NÓS: ", caminho_cena, "]")
	if not ResourceLoader.exists(caminho_cena):
		print("  ERRO: Cena nao encontrada no caminho: ", caminho_cena)
		return
	
	var recurso_cena = load(caminho_cena)
	if not (recurso_cena is PackedScene):
		print("  ERRO: O recurso informado nao e uma PackedScene valida.")
		return
	
	var raiz: Node = recurso_cena.instantiate()
	_percorrer_nos(raiz, "")
	raiz.free()

func _percorrer_nos(no: Node, indentacao: String) -> void:
	var prefixo_unico: String = "%" if no.unique_name_in_owner else ""
	var script_info: String = ""
	if no.get_script() != null:
		var caminho_script: String = no.get_script().resource_path
		if caminho_script != "":
			script_info = " -> script: " + caminho_script
	
	print(indentacao + "+-- " + prefixo_unico + no.name + " (" + no.get_class() + ")" + script_info)
	
	for filho in no.get_children():
		_percorrer_nos(filho, indentacao + "    ")
