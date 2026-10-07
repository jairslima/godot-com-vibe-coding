# ARQUIVO:
# res://src/core/license_manager.gd
#
# ANEXAR AO NODE:
# LicenseManager (Node)
#
# CENA:
# res://src/core/license_manager.tscn (ou utilizado como utilitário instanciado)
#
# INPUTS NECESSÁRIOS:
# Nenhum.
#
# DEPENDÊNCIAS:
# Singleton Engine do Godot 4.7.2 e arquivo textual res://assets/LICENSES.md
#
# VERSÃO TESTADA:
# Godot 4.7.2.stable.official.ed1daf0bf no Windows 11
#
# RESULTADO ESPERADO:
# Extrai o texto da licença MIT do Godot Engine, lista dependências de terceiros compiladas,
# carrega e audita sintaticamente o Asset Ledger (LICENSES.md) e gera o texto de créditos consolidado.

class_name LicenseManager
extends Node

## Caminho padrão para o arquivo de registro de procedência de recursos.
const CAMINHO_LEDGER_PADRAO: String = "res://assets/LICENSES.md"

## Retorna o texto completo da licença MIT sob a qual o Godot Engine é distribuído.
func obter_licenca_godot() -> String:
	return Engine.get_license_text()

## Retorna a lista de nomes de todas as licenças de terceiros compiladas no binário do Godot.
func obter_resumo_terceiros() -> Array[String]:
	var info_licencas: Dictionary = Engine.get_license_info()
	var nomes: Array[String] = []
	for chave in info_licencas.keys():
		nomes.append(str(chave))
	nomes.sort()
	return nomes

## Retorna as informações detalhadas de copyright de todos os módulos e bibliotecas da engine.
func obter_detalhes_copyright() -> Array[Dictionary]:
	return Engine.get_copyright_info()

## Carrega o conteúdo bruto do Asset Ledger em formato Markdown a partir do sistema virtual de arquivos.
func carregar_ledger(caminho: String = CAMINHO_LEDGER_PADRAO) -> String:
	if not FileAccess.file_exists(caminho):
		push_warning("LicenseManager: Arquivo de ledger não encontrado em '%s'." % caminho)
		return ""
	
	var arquivo := FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		push_error("LicenseManager: Falha ao abrir o arquivo '%s'. Erro: %d" % [caminho, FileAccess.get_open_error()])
		return ""
	
	var conteudo := arquivo.get_as_text()
	arquivo.close()
	return conteudo

## Audita o Asset Ledger verificando estrutura de colunas, contagem de ativos e pendências de aprovação.
func auditar_ledger(caminho: String = CAMINHO_LEDGER_PADRAO) -> Dictionary:
	var resultado := {
		"valido": false,
		"total_assets": 0,
		"aprovados": 0,
		"pendentes": 0,
		"linhas_auditadas": 0,
		"erros": [] as Array[String],
		"advertencias": [] as Array[String]
	}
	
	var texto := carregar_ledger(caminho)
	if texto.is_empty():
		resultado["erros"].append("Arquivo de ledger ausente ou vazio: %s" % caminho)
		return resultado
	
	var linhas := texto.split("\n")
	var dentro_tabela := false
	var cabecalho_encontrado := false
	
	for linha_bruta in linhas:
		var linha := linha_bruta.strip_edges()
		if linha.begins_with("| Identificador do Arquivo"):
			cabecalho_encontrado = true
			dentro_tabela = true
			continue
		
		if dentro_tabela and linha.begins_with("| :---"):
			continue
		
		if dentro_tabela and linha.begins_with("|") and linha.ends_with("|"):
			resultado["linhas_auditadas"] += 1
			var colunas := linha.split("|")
			# Uma linha formatada com 8 colunas gera 10 elementos com split('|') devido às barras externas
			if colunas.size() < 9:
				resultado["erros"].append("Linha com formato de colunas insuficiente: %s" % linha)
				continue
			
			var id_arquivo := colunas[1].strip_edges()
			var categoria := colunas[2].strip_edges()
			var origem := colunas[3].strip_edges()
			var autor := colunas[4].strip_edges()
			var licenca := colunas[5].strip_edges()
			var status := colunas[8].strip_edges()
			
			resultado["total_assets"] += 1
			
			if status.to_lower() == "aprovado":
				resultado["aprovados"] += 1
			else:
				resultado["pendentes"] += 1
				resultado["advertencias"].append("Ativo com status não aprovado ('%s'): %s" % [status, id_arquivo])
			
			if licenca.is_empty():
				resultado["erros"].append("Ativo sem licença declarada: %s" % id_arquivo)
		elif dentro_tabela and linha.is_empty():
			# Fim do bloco da tabela
			dentro_tabela = false
	
	if not cabecalho_encontrado:
		resultado["erros"].append("Tabela de procedência não localizada com cabeçalho padrão.")
	
	resultado["valido"] = cabecalho_encontrado and (resultado["erros"].size() == 0) and (resultado["total_assets"] > 0)
	return resultado

## Gera um documento de créditos consolidado pronto para exibição no menu do jogo ou exportação textual.
func gerar_texto_creditos() -> String:
	var texto_creditos := "==================================================\n"
	texto_creditos += "ESTAÇÃO SOBREVIVÊNCIA - CRÉDITOS E LICENÇAS\n"
	texto_creditos += "==================================================\n\n"
	texto_creditos += "DESENVOLVIMENTO E DESIGN:\n"
	texto_creditos += "Jair Lima\n\n"
	texto_creditos += "ENGINE E TECNOLOGIA:\n"
	texto_creditos += "Este jogo foi construído utilizando o Godot Engine (https://godotengine.org).\n\n"
	texto_creditos += "--- AVISO DE LICENÇA DO GODOT ENGINE (MIT) ---\n"
	texto_creditos += obter_licenca_godot() + "\n\n"
	texto_creditos += "--- BIBLIOTECAS DE TERCEIROS EMBUTIDAS ---\n"
	var terceiros := obter_resumo_terceiros()
	texto_creditos += "O Godot Engine inclui componentes sob as seguintes licenças:\n"
	for lic in terceiros:
		texto_creditos += "* " + lic + "\n"
	texto_creditos += "\nPara o texto completo das licenças de terceiros, consulte a documentação oficial.\n"
	return texto_creditos
