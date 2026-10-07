# ARQUIVO: res://src/score_service.gd
# ANEXAR AO NODE: ScoreService (Node ou RefCounted)
# CENA: N/A (servico logico instanciado por script ou Autoload)
# INPUTS NECESSARIOS: Nenhum
# DEPENDENCIAS: Nenhuma (utiliza APIs nativas FileAccess e JSON do Godot 4.7.2)
# VERSAO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Persistencia segura e sanitizada de recordes locais em user://
class_name ScoreService
extends RefCounted

const SAVE_PATH: String = "user://leaderboard_local.json"
const MAX_ENTRIES: int = 10
const MAX_NAME_LENGTH: int = 16

## Salva um novo recorde de pontuacao de forma sanitizada e defensiva.
static func registrar_pontuacao(nome: String, pontos: int) -> bool:
	if pontos < 0:
		push_warning("Tentativa de salvar pontuacao negativa rejeitada.")
		return false
	
	var nome_sanitizado: String = nome.strip_edges()
	if nome_sanitizado.is_empty():
		nome_sanitizado = "Jogador"
	if nome_sanitizado.length() > MAX_NAME_LENGTH:
		nome_sanitizado = nome_sanitizado.substr(0, MAX_NAME_LENGTH)
	
	var entradas: Array = carregar_pontuacoes()
	var nova_entrada: Dictionary = {
		"nome": nome_sanitizado,
		"pontos": pontos,
		"timestamp": Time.get_unix_time_from_system()
	}
	entradas.append(nova_entrada)
	
	# Ordena decrescente por pontuacao
	entradas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("pontos", 0)) > int(b.get("pontos", 0))
	)
	
	# Mantem apenas o topo da lista
	if entradas.size() > MAX_ENTRIES:
		entradas.resize(MAX_ENTRIES)
	
	var json_texto: String = JSON.stringify(entradas, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Falha ao abrir arquivo para gravacao: " + str(FileAccess.get_open_error()))
		return false
	
	file.store_string(json_texto)
	file.close()
	return true

## Carrega a lista de pontuacoes salvas com validacao defensiva contra dados corrompidos.
static func carregar_pontuacoes() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return []
	
	var conteudo: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var erro: Error = json.parse(conteudo)
	if erro != OK:
		push_warning("Arquivo de pontuacoes corrompido ou invalido. Retornando lista vazia.")
		return []
	
	var dados = json.data
	if not (dados is Array):
		push_warning("Formato inesperado de dados no arquivo de pontuacoes.")
		return []
	
	var lista_validada: Array = []
	for item in dados:
		if item is Dictionary and item.has("nome") and item.has("pontos"):
			lista_validada.append({
				"nome": str(item.get("nome", "Anonimo")),
				"pontos": int(item.get("pontos", 0)),
				"timestamp": int(item.get("timestamp", 0))
			})
	
	return lista_validada

## Limpa os registros locais de teste
static func limpar_registros() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
