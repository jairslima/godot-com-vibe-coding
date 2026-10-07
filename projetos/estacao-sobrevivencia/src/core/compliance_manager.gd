# ARQUIVO:
# res://src/core/compliance_manager.gd
#
# ANEXAR AO NODE:
# ComplianceManager (Node)
#
# CENA:
# res://src/core/compliance_manager.tscn (ou utilizado como utilitário instanciado)
#
# INPUTS NECESSÁRIOS:
# Nenhum.
#
# DEPENDÊNCIAS:
# Singleton Engine do Godot 4.7.2 e arquivo textual res://docs/PROVENANCE.md
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Audita o registro de procedência (PROVENANCE.md), categoriza ativos pré-gerados e ao vivo,
# gera respostas para o Steamworks Content Survey, valida minimização de dados de privacidade (LGPD/GDPR)
# e extrai o texto de licença MIT do Godot Engine para a tela jurídica in-game.

class_name ComplianceManager
extends Node

## Caminho padrão para o arquivo de registro de procedência e declaração de IA.
const CAMINHO_PROVENANCE_PADRAO: String = "res://docs/PROVENANCE.md"

## Chaves estritamente proibidas em payloads de telemetria por violarem minimização de dados.
const CHAVES_PII_PROIBIDAS: Array[String] = [
	"email",
	"e-mail",
	"cpf",
	"ip",
	"endereco_ip",
	"steam_id",
	"senha",
	"password",
	"nome_real",
	"cartao"
]

## Retorna o texto completo da licença MIT sob a qual o executável do Godot Engine é distribuído.
func obter_licenca_engine() -> String:
	return Engine.get_license_text()

## Carrega o conteúdo textual do arquivo de procedência.
func carregar_provenance(caminho: String = CAMINHO_PROVENANCE_PADRAO) -> String:
	if not FileAccess.file_exists(caminho):
		push_warning("ComplianceManager: Arquivo de procedência não encontrado em '%s'." % caminho)
		return ""
	
	var arquivo := FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		push_error("ComplianceManager: Falha ao abrir o arquivo '%s'. Código: %d" % [caminho, FileAccess.get_open_error()])
		return ""
	
	var conteudo := arquivo.get_as_text()
	arquivo.close()
	return conteudo

## Audita a tabela de ativos do registro de procedência, classificando por categorias de IA.
func auditar_provenance(caminho: String = CAMINHO_PROVENANCE_PADRAO) -> Dictionary:
	var resultado := {
		"valido": false,
		"total_ativos": 0,
		"pre_gerados": 0,
		"gerados_ao_vivo": 0,
		"humanos_ou_hibridos": 0,
		"aprovados": 0,
		"pendentes": 0,
		"erros": [] as Array[String],
		"advertencias": [] as Array[String]
	}
	
	var texto := carregar_provenance(caminho)
	if texto.is_empty():
		resultado["erros"].append("Arquivo de procedência vazio ou inexistente: %s" % caminho)
		return resultado
	
	var linhas := texto.split("\n")
	var dentro_tabela := false
	
	for linha_bruta in linhas:
		var linha := linha_bruta.strip_edges()
		if linha.begins_with("| Identificador do Ativo"):
			dentro_tabela = true
			continue
		
		if dentro_tabela and linha.begins_with("| :---"):
			continue
		
		if dentro_tabela and linha.begins_with("|") and linha.ends_with("|"):
			var colunas := linha.split("|")
			# Uma linha formatada com 8 colunas gera 10 elementos com split('|') devido às barras externas
			if colunas.size() < 9:
				resultado["erros"].append("Linha com colunas insuficientes: %s" % linha)
				continue
			
			resultado["total_ativos"] += 1
			var categoria_ia := colunas[3].strip_edges().to_lower()
			var status := colunas[8].strip_edges().to_upper()
			
			if status == "APROVADO":
				resultado["aprovados"] += 1
			else:
				resultado["pendentes"] += 1
				resultado["advertencias"].append("Ativo com status não aprovado: %s" % colunas[1].strip_edges())
			
			if "pré-gerado" in categoria_ia or "pre-generated" in categoria_ia:
				resultado["pre_gerados"] += 1
			elif "ao vivo" in categoria_ia or "live-generated" in categoria_ia:
				resultado["gerados_ao_vivo"] += 1
			else:
				resultado["humanos_ou_hibridos"] += 1
		elif dentro_tabela and not linha.begins_with("|"):
			# Encerrou o bloco da tabela
			dentro_tabela = false
	
	resultado["valido"] = resultado["erros"].is_empty() and resultado["total_ativos"] > 0
	return resultado

## Gera o dicionário com as respostas estruturadas para o Steamworks Content Survey.
func gerar_declaracao_steam_survey(auditoria: Dictionary) -> Dictionary:
	var usa_ia: bool = (auditoria.get("pre_gerados", 0) > 0) or (auditoria.get("gerados_ao_vivo", 0) > 0)
	var tem_pre: bool = auditoria.get("pre_gerados", 0) > 0
	var tem_live: bool = auditoria.get("gerados_ao_vivo", 0) > 0
	
	var texto_divulgacao := ""
	if usa_ia:
		texto_divulgacao = "Este jogo utilizou ferramentas de inteligência artificial durante seu processo de criação. "
		if tem_pre:
			texto_divulgacao += "Conteúdos visuais de referência e efeitos sonoros foram pré-gerados com assistência de modelos generativos e posteriormente lapidados e integrados por desenvolvedores humanos. "
		if tem_live:
			texto_divulgacao += "O jogo inclui geração dinâmica de conteúdo em tempo de execução com filtros de moderação ativos. "
		else:
			texto_divulgacao += "Nenhum conteúdo é gerado em tempo de execução enquanto o jogo roda; todas as lógicas e mídias são estáticas e determinísticas."
	else:
		texto_divulgacao = "Este jogo não utiliza ativos gerados por ferramentas de inteligência artificial generativa."
	
	var guardrails := ""
	if tem_live:
		guardrails = "Filtro de vocabulário ofensivo, orçamentos de requisição por sessão e fallback determinístico offline."
	else:
		guardrails = "Não aplicável (jogo estático e determinístico sem geração ao vivo)."
	
	return {
		"uses_ai_content": usa_ia,
		"has_pre_generated_content": tem_pre,
		"has_live_generated_content": tem_live,
		"guardrails_description": guardrails,
		"store_page_disclosure": texto_divulgacao,
		"adult_only_live_content": false
	}

## Valida um payload de telemetria assegurando conformidade com minimização de dados e LGPD/GDPR.
func validar_privacidade_telemetria(payload: Dictionary) -> Dictionary:
	var resultado := {
		"conforme": true,
		"violacoes": [] as Array[String],
		"chaves_analisadas": payload.keys()
	}
	
	for chave in payload.keys():
		var chave_str := str(chave).to_lower()
		for proibida in CHAVES_PII_PROIBIDAS:
			if chave_str == proibida or chave_str.begins_with(proibida + "_"):
				resultado["conforme"] = false
				resultado["violacoes"].append("Chave sensível detectada no payload: '%s'" % str(chave))
	
	return resultado
