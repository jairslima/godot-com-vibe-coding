class_name StationSaveManager
extends Node

## Gerenciador de persistência de estado para a Estação 3D (checkpoint station3d-09-save).
## Implementa gravação atômica, sanitização defensiva de coordenadas espaciais e versionamento.

const SAVE_PATH: String = "user://station_save.json"
const SAVE_TEMP_PATH: String = "user://station_save.json.tmp"
const CURRENT_VERSION: int = 1

# Limites espaciais métricos para sanitização da Estação Espacial
const BOUNDS_MIN: Vector3 = Vector3(-60.0, -10.0, -60.0)
const BOUNDS_MAX: Vector3 = Vector3(60.0, 30.0, 60.0)

static func create_save_dictionary(collected_cores: int, is_power_active: bool, player_pos: Vector3, player_rot_y: float) -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"collected_cores": clampi(collected_cores, 0, 10),
		"is_power_active": is_power_active,
		"player_position": {
			"x": clampf(player_pos.x, BOUNDS_MIN.x, BOUNDS_MAX.x),
			"y": clampf(player_pos.y, BOUNDS_MIN.y, BOUNDS_MAX.y),
			"z": clampf(player_pos.z, BOUNDS_MIN.z, BOUNDS_MAX.z)
		},
		"player_rotation_y": player_rot_y
	}

static func save_game(data: Dictionary, path: String = SAVE_PATH) -> bool:
	var temp_path: String = path + ".tmp"
	var json_string: String = JSON.stringify(data, "\t")
	
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if not file:
		push_error("Falha ao abrir arquivo temporário para escrita: %s (Erro: %d)" % [temp_path, FileAccess.get_open_error()])
		return false
	
	file.store_string(json_string)
	file.close()
	
	# Gravação atômica: substitui o arquivo original pelo arquivo temporário
	var dir := DirAccess.open("user://")
	if not dir:
		push_error("Falha ao acessar diretório user:// para substituição atômica.")
		return false
	
	var clean_temp: String = temp_path.replace("user://", "")
	var clean_target: String = path.replace("user://", "")
	
	if dir.file_exists(clean_target):
		var remove_err := dir.remove(clean_target)
		if remove_err != OK:
			push_error("Falha ao remover arquivo de save anterior: %d" % remove_err)
			return false
	
	var rename_err := dir.rename(clean_temp, clean_target)
	if rename_err != OK:
		push_error("Falha ao renomear arquivo temporário para save definitivo: %d" % rename_err)
		return false
	
	return true

static func load_game(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Falha ao abrir arquivo de save para leitura: %s" % path)
		return {}
	
	var content: String = file.get_as_text()
	file.close()
	
	var test_json_conv := JSON.new()
	var parse_err := test_json_conv.parse(content)
	if parse_err != OK:
		push_error("Arquivo de save corrompido ou JSON inválido: linha %d, erro: %s" % [test_json_conv.get_error_line(), test_json_conv.get_error_message()])
		return {}
	
	var raw_data: Variant = test_json_conv.data
	if typeof(raw_data) != TYPE_DICTIONARY:
		push_error("Conteúdo de save não representa um dicionário válido.")
		return {}
	
	return sanitize_save_data(raw_data as Dictionary)

static func sanitize_save_data(data: Dictionary) -> Dictionary:
	var clean := Dictionary()
	
	clean["version"] = int(data.get("version", CURRENT_VERSION))
	clean["collected_cores"] = clampi(int(data.get("collected_cores", 0)), 0, 10)
	clean["is_power_active"] = bool(data.get("is_power_active", false))
	
	var pos_dict: Variant = data.get("player_position", null)
	if typeof(pos_dict) == TYPE_DICTIONARY:
		var p_dict: Dictionary = pos_dict as Dictionary
		var px: float = clampf(float(p_dict.get("x", 0.0)), BOUNDS_MIN.x, BOUNDS_MAX.x)
		var py: float = clampf(float(p_dict.get("y", 0.0)), BOUNDS_MIN.y, BOUNDS_MAX.y)
		var pz: float = clampf(float(p_dict.get("z", 0.0)), BOUNDS_MIN.z, BOUNDS_MAX.z)
		clean["player_position"] = Vector3(px, py, pz)
	else:
		clean["player_position"] = Vector3.ZERO
	
	clean["player_rotation_y"] = float(data.get("player_rotation_y", 0.0))
	return clean
