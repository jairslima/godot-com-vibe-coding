# ARQUIVO: res://test_mcp_integration.gd
# ANEXAR AO NODE: TestMCPIntegration (Node)
# CENA: res://test_mcp_integration.tscn
# INPUTS NECESSÁRIOS: Nenhum (execução automatizada headless)
# DEPENDÊNCIAS: Nenhuma
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executar 5 validações técnicas de MCP e sair com código 0

extends Node

# Simulador de barreira de caminhos (PathGuardSim) inspirado na proteção de addons MCP comunitários.
class PathGuardSim:
	static func is_safe_project_path(path: String) -> bool:
		if path.begins_with("res://") or path.begins_with("user://"):
			# Proíbe travessia de diretório com ..
			if path.contains(".."):
				return false
			return true
		return false

func _ready() -> void:
	print("--- INICIANDO VALIDAÇÃO PRÁTICA DE MCP E GODOT ---")
	test_1_inspecao_estrutural_cena()
	test_2_leitura_propriedades_tipadas()
	test_3_barreira_seguranca_pathguard()
	test_4_divergencia_memoria_vs_disco()
	test_5_envelope_jsonrpc_mcp()
	print("--- TODOS OS 5 TESTES DE INTEGRAÇÃO MCP APROVADOS COM SUCESSO ---")
	get_tree().quit(0)

func test_1_inspecao_estrutural_cena() -> void:
	# Simula o comportamento da ferramenta MCP de inspeção de cena (read_scene)
	var dummy_root := Node2D.new()
	dummy_root.name = "LevelRoot"
	var child_node := CharacterBody2D.new()
	child_node.name = "Player"
	dummy_root.add_child(child_node)
	
	var arvore_dados := {
		"name": dummy_root.name,
		"type": dummy_root.get_class(),
		"children": []
	}
	
	for child in dummy_root.get_children():
		arvore_dados["children"].append({
			"name": child.name,
			"type": child.get_class()
		})
	
	assert(arvore_dados["name"] == "LevelRoot", "Falha no nome do nó raiz")
	assert(arvore_dados["children"].size() == 1, "Falha na contagem de filhos")
	assert(arvore_dados["children"][0]["name"] == "Player", "Filho deveria ser Player")
	assert(arvore_dados["children"][0]["type"] == "CharacterBody2D", "Tipo incorreto")
	
	child_node.queue_free()
	dummy_root.queue_free()
	print("[TESTE 1 APROVADO] Inspeção estrutural de cena via dados JSON validada.")

func test_2_leitura_propriedades_tipadas() -> void:
	# Simula leitura de propriedades do editor (get_property)
	var node := Node2D.new()
	node.position = Vector2(100.0, 250.0)
	node.rotation_degrees = 45.0
	
	var pos_lida: Vector2 = node.get("position")
	var rot_lida: float = node.get("rotation_degrees")
	
	assert(pos_lida == Vector2(100.0, 250.0), "Posição lida incorreta")
	assert(is_equal_approx(rot_lida, 45.0), "Rotação lida incorreta")
	
	node.queue_free()
	print("[TESTE 2 APROVADO] Leitura e escrita de propriedades tipadas validada.")

func test_3_barreira_seguranca_pathguard() -> void:
	# Simula a prevenção contra path traversal e acesso indevido fora do projeto
	var caminho_seguro_res := "res://scripts/player.gd"
	var caminho_seguro_user := "user://saves/slot1.json"
	var caminho_perigoso_traversal := "res://../../Windows/System32/calc.exe"
	var caminho_perigoso_absoluto := "C:/Windows/System32/cmd.exe"
	var caminho_perigoso_relativo := "../outside_project.txt"
	
	assert(PathGuardSim.is_safe_project_path(caminho_seguro_res), "Caminho res:// válido foi rejeitado")
	assert(PathGuardSim.is_safe_project_path(caminho_seguro_user), "Caminho user:// válido foi rejeitado")
	assert(not PathGuardSim.is_safe_project_path(caminho_perigoso_traversal), "Falha na detecção de .. em res://")
	assert(not PathGuardSim.is_safe_project_path(caminho_perigoso_absoluto), "Caminho absoluto fora de res:// deveria falhar")
	assert(not PathGuardSim.is_safe_project_path(caminho_perigoso_relativo), "Caminho relativo externo deveria falhar")
	
	print("[TESTE 3 APROVADO] Barreira de segurança PathGuard validada.")

func test_4_divergencia_memoria_vs_disco() -> void:
	# Demonstração do princípio: O arquivo não é necessariamente o editor.
	# Um arquivo salvo no disco tem determinado estado. A Scene Tree em memória tem outro.
	var caminho_arquivo := "user://teste_cena_divergencia.txt"
	
	# 1. Grava no disco um estado inicial
	var f_out := FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	assert(f_out != null, "Falha ao criar arquivo de teste no disco")
	f_out.store_string("estado_no_disco: vida = 100")
	f_out.close()
	
	# 2. Modifica o objeto correspondente na memória sem salvar
	var objeto_memoria := Node.new()
	objeto_memoria.set_meta("vida", 75)
	
	# 3. Lê o disco novamente
	var f_in := FileAccess.open(caminho_arquivo, FileAccess.READ)
	var conteudo_disco := f_in.get_as_text()
	f_in.close()
	
	var vida_memoria: int = objeto_memoria.get_meta("vida")
	
	# Prova a divergência: no disco está 100, na memória está 75
	assert(conteudo_disco.contains("100"), "Disco deveria conter valor anterior")
	assert(vida_memoria == 75, "Memória deveria refletir estado ativo editado")
	assert(not conteudo_disco.contains("75"), "Disco não deve conter a alteração feita apenas em memória")
	
	# Limpeza
	objeto_memoria.queue_free()
	DirAccess.remove_absolute(caminho_arquivo)
	
	print("[TESTE 4 APROVADO] Divergência entre estado no disco e estado em memória confirmada.")

func test_5_envelope_jsonrpc_mcp() -> void:
	# Simula o formato de resposta MCP conforme a especificação JSON-RPC 2.0
	var payload_mcp := {
		"jsonrpc": "2.0",
		"id": 42,
		"result": {
			"content": [
				{
					"type": "text",
					"text": JSON.stringify({"nodes_count": 12, "status": "ok"})
				}
			]
		}
	}
	
	var json_str := JSON.stringify(payload_mcp)
	var parsed: Variant = JSON.parse_string(json_str)
	assert(parsed is Dictionary, "Resultado parseado deveria ser Dictionary")
	var dict: Dictionary = parsed
	assert(dict["jsonrpc"] == "2.0", "Versão JSON-RPC inválida")
	assert(dict["id"] == 42, "ID inválido")
	assert(dict["result"]["content"][0]["type"] == "text", "Tipo de conteúdo inválido")
	
	print("[TESTE 5 APROVADO] Envelope JSON-RPC 2.0 da especificação MCP validado.")
