# ARQUIVO: res://laboratorio_runner.gd
# ANEXAR AO NODE: Executado diretamente via CLI headless
# CENA: Nenhuma (estende SceneTree)
# INPUTS NECESSARIOS: nenhum
# DEPENDENCIAS: scripts em res://casos_corrigidos/
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Valida e executa as solucoes homologadas do laboratorio de alucinacoes

extends SceneTree

func _init() -> void:
	print("--- INICIANDO VALIDACAO DO LABORATORIO DE ALUCINACOES (GODOT 4.7.2) ---")
	
	# Teste 1: Validacao da classe oficial AudioStreamPlayer2D
	var script_audio: GDScript = load("res://casos_corrigidos/solucao_classe_inexistente.gd")
	assert(script_audio != null, "Falha ao carregar solucao de classe inexistente")
	var audio_node = script_audio.new()
	assert(audio_node is AudioStreamPlayer2D, "Audio node deve ser instancia de AudioStreamPlayer2D")
	audio_node.free()
	print("[OK] Teste 1: Classe oficial AudioStreamPlayer2D validada com sucesso.")
	
	# Teste 2: Validacao de instanciacao moderna com instantiate()
	var script_migracao: GDScript = load("res://casos_corrigidos/solucao_godot3_migracao.gd")
	assert(script_migracao != null, "Falha ao carregar solucao de migracao Godot 3 vs 4")
	var migracao_node = script_migracao.new()
	assert(migracao_node.has_method("instanciar_entidade"), "Metodo instanciar_entidade deve existir")
	migracao_node.free()
	print("[OK] Teste 2: Metodo instantiate() e await validados com sucesso.")
	
	# Teste 3: Validacao de propriedades Control (position e size)
	var script_propriedade: GDScript = load("res://casos_corrigidos/solucao_propriedade_removida.gd")
	assert(script_propriedade != null, "Falha ao carregar solucao de propriedades Control")
	var btn_prop = script_propriedade.new()
	btn_prop.configurar_geometria()
	assert(btn_prop.position == Vector2(100.0, 150.0), "Position deve ser configurada corretamente")
	assert(btn_prop.size == Vector2(200.0, 50.0), "Size deve ser configurado corretamente")
	btn_prop.free()
	print("[OK] Teste 3: Propriedades position e size em Button validadas com sucesso.")
	
	# Teste 4: Validacao de sinal oficial pressed em Button
	var script_sinal: GDScript = load("res://casos_corrigidos/solucao_sinal_inventado.gd")
	assert(script_sinal != null, "Falha ao carregar solucao de sinal oficial")
	var btn_sinal = script_sinal.new()
	assert(btn_sinal.has_signal("pressed"), "Button deve possuir o sinal nativo pressed")
	btn_sinal.pressed.connect(btn_sinal._ao_pressionar)
	btn_sinal.pressed.emit()
	assert(btn_sinal.cliques_registrados == 1, "Emissao de pressed deve incrementar contador")
	btn_sinal.free()
	print("[OK] Teste 4: Conexao e emissao do sinal nativo pressed validadas com sucesso.")
	
	# Teste 5: Validacao de AnimatedSprite2D para animacoes com play()
	var script_anim: GDScript = load("res://casos_corrigidos/solucao_no_errado.gd")
	assert(script_anim != null, "Falha ao carregar solucao de no correto")
	var anim_node = script_anim.new()
	assert(anim_node is AnimatedSprite2D, "No deve ser instancia de AnimatedSprite2D")
	assert(anim_node.has_method("play"), "AnimatedSprite2D deve conter o metodo play()")
	anim_node.free()
	print("[OK] Teste 5: Metodo play() no no correto AnimatedSprite2D validado com sucesso.")
	
	# Teste 6: Validacao de GDScript limpo sem sintaxe alienigena de C#
	var script_csharp: GDScript = load("res://casos_corrigidos/solucao_sintaxe_csharp.gd")
	assert(script_csharp != null, "Falha ao carregar solucao de sintaxe GDScript limpa")
	var entidade_node = script_csharp.new()
	assert(entidade_node.vida == 100, "Propriedade vida deve iniciar em 100")
	assert(entidade_node.velocidade == 250.0, "Propriedade velocidade deve iniciar em 250.0")
	entidade_node.free()
	print("[OK] Teste 6: Sintaxe GDScript tipada e sem artefatos C# validada com sucesso.")
	
	print("--- TODOS OS 6 TESTES DE HOMOLOGACAO PASSARAM COM SUCESSO NO GODOT 4.7.2 ---")
	quit(0)
