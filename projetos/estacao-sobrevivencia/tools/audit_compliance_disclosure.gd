# ARQUIVO:
# res://tools/audit_compliance_disclosure.gd
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
# res://src/core/compliance_manager.gd e res://docs/PROVENANCE.md
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Executa auditoria pré-lançamento de disclosure de IA e licenças no modo headless.
# Retorna código de saída 0 em caso de conformidade total ou 1 em caso de irregularidades.

extends SceneTree

const ComplianceManagerScript = preload("res://src/core/compliance_manager.gd")

func _init() -> void:
	print("============================================================")
	print("AUDITORIA PRÉ-LANÇAMENTO: DISCLOSURE DE IA E LICENÇAS")
	print("Godot Engine 4.7.2 Stable - Estação Sobrevivência by Jair Lima")
	print("============================================================")
	
	var compliance = ComplianceManagerScript.new()
	var relatorio_auditoria: Dictionary = compliance.auditar_provenance("res://docs/PROVENANCE.md")
	
	if not relatorio_auditoria["valido"]:
		printerr("[FALHA CRÍTICA] Registro de procedência inválido ou com erros:")
		for erro in relatorio_auditoria["erros"]:
			printerr("  - %s" % erro)
		compliance.free()
		quit(1)
		return
	
	print("[SUCESSO] Inventário de procedência validado:")
	print("  - Total de ativos auditados: %d" % relatorio_auditoria["total_ativos"])
	print("  - Ativos pré-gerados por IA: %d" % relatorio_auditoria["pre_gerados"])
	print("  - Ativos gerados ao vivo: %d" % relatorio_auditoria["gerados_ao_vivo"])
	print("  - Ativos humanos ou híbridos: %d" % relatorio_auditoria["humanos_ou_hibridos"])
	print("  - Ativos aprovados: %d" % relatorio_auditoria["aprovados"])
	
	if relatorio_auditoria["pendentes"] > 0:
		printerr("[FALHA] Existem %d ativos com status pendente de aprovação!" % relatorio_auditoria["pendentes"])
		compliance.free()
		quit(1)
		return
	
	var steam_data: Dictionary = compliance.gerar_declaracao_steam_survey(relatorio_auditoria)
	print("\n[DECLARAÇÃO STEAMWORKS CONTENT SURVEY GERADA]:")
	print("  - Utiliza conteúdo gerado por IA: %s" % ("SIM" if steam_data["uses_ai_content"] else "NÃO"))
	print("  - Conteúdo pré-gerado: %s" % ("SIM" if steam_data["has_pre_generated_content"] else "NÃO"))
	print("  - Conteúdo gerado ao vivo: %s" % ("SIM" if steam_data["has_live_generated_content"] else "NÃO"))
	print("  - Descrição de Guardrails: %s" % steam_data["guardrails_description"])
	print("  - Texto público para a página da loja:\n    \"%s\"" % steam_data["store_page_disclosure"])
	
	# Verificação da licença do Engine
	var licenca: String = compliance.obter_licenca_engine()
	if licenca.is_empty():
		printerr("[FALHA] Licença do Godot Engine não pôde ser recuperada!")
		compliance.free()
		quit(1)
		return
	print("\n[SUCESSO] Licença MIT do Godot Engine confirmada e pronta para exibição in-game.")
	
	compliance.free()
	print("\n============================================================")
	print("AUDITORIA CONCLUÍDA: PACOTE CONFORME PARA PUBLICAÇÃO")
	print("============================================================")
	quit(0)
