class_name StoreManager
extends Node

# Gerenciador de serviços de plataforma e lojas digitais (Steam, itch.io, Google Play, DRM-free)
# Fornece abstração segura com contingência local simulada quando executado fora de um cliente de loja

signal conquista_desbloqueada(id_conquista: String)
signal estatistica_atualizada(id_stat: String, valor: int)
signal sincronizacao_concluida(sucesso: bool)

@export var app_id: int = 480
@export var persistir_dados_locais: bool = true

var _em_modo_simulado: bool = true
var _conquistas_desbloqueadas: Array[String] = []
var _estatisticas: Dictionary = {}
var _caminho_dados_simulados: String = "user://mock_store_data.json"

func _ready() -> void:
	inicializar_plataforma()

func inicializar_plataforma() -> void:
	# Verifica se uma biblioteca ou GDExtension de loja está carregada no ambiente global
	# Por exemplo, a classe "Steam" provida pelo GodotSteam
	if ClassDB.class_exists("Steam"):
		print("[STORE] Extensao nativa de loja detectada no ClassDB.")
		_em_modo_simulado = false
	else:
		print("[STORE] Extensao nativa ausente. Operando em modo simulado (offline / DRM-free).")
		_em_modo_simulado = true
		if persistir_dados_locais:
			_carregar_dados_locais()

func desbloquear_conquista(id_conquista: String) -> bool:
	if id_conquista.strip_edges().is_empty():
		push_error("[STORE] Identificador de conquista invalido ou vazio.")
		return false
		
	if _conquistas_desbloqueadas.has(id_conquista):
		return true # Ja desbloqueada anteriormente
		
	_conquistas_desbloqueadas.append(id_conquista)
	conquista_desbloqueada.emit(id_conquista)
	print("[STORE] Conquista desbloqueada: " + id_conquista)
	
	if _em_modo_simulado and persistir_dados_locais:
		_salvar_dados_locais()
		
	return true

func definir_estatistica(id_stat: String, valor: int) -> bool:
	if id_stat.strip_edges().is_empty():
		push_error("[STORE] Identificador de estatistica invalido.")
		return false
		
	_estatisticas[id_stat] = valor
	estatistica_atualizada.emit(id_stat, valor)
	
	if _em_modo_simulado and persistir_dados_locais:
		_salvar_dados_locais()
		
	return true

func obter_estatistica(id_stat: String) -> int:
	return _estatisticas.get(id_stat, 0)

func sincronizar_nuvem() -> bool:
	print("[STORE] Disparando sincronizacao com a nuvem...")
	if _em_modo_simulado:
		if persistir_dados_locais:
			_salvar_dados_locais()
		sincronizacao_concluida.emit(true)
		return true
	return true

func esta_em_modo_simulado() -> bool:
	return _em_modo_simulado

func obter_conquistas() -> Array[String]:
	return _conquistas_desbloqueadas.duplicate()

func _salvar_dados_locais() -> void:
	var dados: Dictionary = {
		"app_id": app_id,
		"conquistas": _conquistas_desbloqueadas,
		"estatisticas": _estatisticas,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_str: String = JSON.stringify(dados, "\t")
	var caminho_tmp: String = _caminho_dados_simulados + ".tmp"
	var f: FileAccess = FileAccess.open(caminho_tmp, FileAccess.WRITE)
	if f == null:
		push_error("[STORE] Erro ao gravar dados temporarios de loja em user://")
		return
	f.store_string(json_str)
	f.close()
	
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null:
		var nome_final: String = _caminho_dados_simulados.get_file()
		var nome_tmp: String = caminho_tmp.get_file()
		if dir.file_exists(nome_final):
			dir.remove(nome_final)
		dir.rename(nome_tmp, nome_final)

func _carregar_dados_locais() -> void:
	if not FileAccess.file_exists(_caminho_dados_simulados):
		return
		
	var f: FileAccess = FileAccess.open(_caminho_dados_simulados, FileAccess.READ)
	if f == null:
		return
	var conteudo: String = f.get_as_text()
	f.close()
	
	var parse_result = JSON.parse_string(conteudo)
	if parse_result is Dictionary:
		var dados: Dictionary = parse_result
		if dados.has("conquistas") and dados["conquistas"] is Array:
			_conquistas_desbloqueadas.clear()
			for c in dados["conquistas"]:
				_conquistas_desbloqueadas.append(str(c))
		if dados.has("estatisticas") and dados["estatisticas"] is Dictionary:
			_estatisticas = dados["estatisticas"]
