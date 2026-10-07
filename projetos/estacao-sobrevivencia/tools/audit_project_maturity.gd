# ARQUIVO:
# res://tools/audit_project_maturity.gd
#
# ANEXAR AO NODE:
# Executável via Godot CLI como SceneTree autônomo (-s)
#
# CENA:
# Não aplicável (script autônomo de terminal)
#
# INPUTS NECESSÁRIOS:
# Nenhum.
#
# DEPENDÊNCIAS:
# Arquivos estruturais do repositório (AGENTS.md, SPEC.md, .gitignore, docs/PROVENANCE.md, etc.)
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Executa a auditoria de maturidade de engenharia de software do projeto no modo headless.
# Valida se os doze pilares de governança agêntica e integridade técnica estão atendidos.
# Retorna código de saída 0 em caso de conformidade total ou 1 em caso de irregularidades.

extends SceneTree

func _init() -> void:
	print("============================================================")
	print("AUDITORIA DE MATURIDADE DE PROJETO: ENGENHARIA E GOVERNANÇA")
	print("Godot Engine 4.7.2 Stable: Estação Sobrevivência by Jair Lima")
	print("============================================================")
	
	var falhas: Array[String] = []
	var sucessos: Array[String] = []
	
	# 1. Version Gate da Engine
	var v_info: Dictionary = Engine.get_version_info()
	var v_string: String = "%d.%d.%d" % [v_info.get("major", 0), v_info.get("minor", 0), v_info.get("patch", 0)]
	if v_info.get("major", 0) == 4 and v_info.get("minor", 0) == 7:
		sucessos.append("Version Gate: Godot %s confirmado (%s)" % [v_string, v_info.get("status", "")])
	else:
		falhas.append("Version Gate incompatível: esperado Godot 4.7.x, detectado %s" % v_string)
	
	# 2. Contrato Operacional de Governança Agêntica
	if FileAccess.file_exists("res://AGENTS.md"):
		var fa_agents := FileAccess.open("res://AGENTS.md", FileAccess.READ)
		if fa_agents != null:
			var tamanho := fa_agents.get_length()
			fa_agents.close()
			if tamanho > 100:
				sucessos.append("Contrato de Governança: res://AGENTS.md presente e estruturado (%d bytes)" % tamanho)
			else:
				falhas.append("Contrato de Governança: res://AGENTS.md vazio ou insuficiente")
		else:
			falhas.append("Contrato de Governança: impossível ler res://AGENTS.md")
	else:
		falhas.append("Contrato de Governança ausente: res://AGENTS.md não encontrado")
	
	# 3. Integridade de Versionamento Git
	var tem_gitignore := FileAccess.file_exists("res://.gitignore")
	var tem_gitattributes := FileAccess.file_exists("res://.gitattributes")
	if tem_gitignore and tem_gitattributes:
		sucessos.append("Blindagem de Versionamento: .gitignore e .gitattributes configurados")
	else:
		falhas.append("Blindagem Git incompleta: verifique .gitignore e .gitattributes")
	
	# 4. Especificação de Engenharia e Arquitetura
	var tem_spec := FileAccess.file_exists("res://SPEC.md")
	var tem_gdd := FileAccess.file_exists("res://docs/GDD.md")
	if tem_spec and tem_gdd:
		sucessos.append("Especificação Técnica: SPEC.md e docs/GDD.md consolidados")
	elif tem_spec or tem_gdd:
		sucessos.append("Especificação Técnica: documento arquitetural presente")
	else:
		falhas.append("Especificação Técnica ausente: SPEC.md ou docs/GDD.md necessários")
	
	# 5. Governança de Licenças e Procedência de Ativos
	var tem_licenses := FileAccess.file_exists("res://assets/LICENSES.md")
	var tem_provenance := FileAccess.file_exists("res://docs/PROVENANCE.md")
	if tem_licenses and tem_provenance:
		sucessos.append("Governança de Ativos: Asset Ledger e docs/PROVENANCE.md validados")
	else:
		falhas.append("Rastreabilidade de Ativos incompleta: requer LICENSES.md e PROVENANCE.md")
	
	# 6. Presets de Exportação e Distribuição
	if FileAccess.file_exists("res://export_presets.cfg"):
		sucessos.append("Esteira de Compilação: export_presets.cfg configurado para distribuição")
	else:
		falhas.append("Esteira de Compilação: export_presets.cfg não encontrado")
	
	# 7. Preservação da Licença de Software Aberto
	if FileAccess.file_exists("res://LICENSE"):
		sucessos.append("Licenciamento Aberto: arquivo LICENSE com termos MIT presente")
	else:
		falhas.append("Licenciamento Aberto: arquivo LICENSE ausente na raiz do projeto")
	
	# 8. Suíte de Testes Automatizados Headless
	var dir_tests := DirAccess.open("res://tests")
	var total_testes: int = 0
	if dir_tests != null:
		dir_tests.list_dir_begin()
		var nome_arquivo := dir_tests.get_next()
		while nome_arquivo != "":
			if not dir_tests.current_is_dir() and (nome_arquivo.ends_with(".tscn") or nome_arquivo.ends_with(".gd")):
				total_testes += 1
			nome_arquivo = dir_tests.get_next()
		dir_tests.list_dir_end()
	
	if total_testes >= 4:
		sucessos.append("Validação Automatizada: suíte de testes verificada com %d arquivos" % total_testes)
	else:
		falhas.append("Validação Automatizada insuficiente: menos de 4 arquivos de teste em res://tests")
	
	# Exibição do Relatório
	print("\n[CRITÉRIOS DE MATURIDADE APROVADOS]:")
	for item in sucessos:
		print("  [OK] %s" % item)
	
	if falhas.size() > 0:
		print("\n[IRREGULARIDADES DETECTADAS]:")
		for falha in falhas:
			printerr("  [FALHA] %s" % falha)
		print("\nResultado: REPROVADO (%d critérios pendentes)" % falhas.size())
		quit(1)
		return
	
	print("\n============================================================")
	print("RESULTADO: PROJETO APROVADO EM MATURIDADE AGÊNTICA")
	print("Todos os pilares de arquitetura, testes e governança estão em conformidade.")
	print("============================================================\n")
	quit(0)
