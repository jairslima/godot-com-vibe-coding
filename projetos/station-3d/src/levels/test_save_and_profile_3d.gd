class_name TestSaveAndProfile3D
extends Node3D

## Suíte de testes automatizados headless para homologação dos marcos do Capítulo 36:
## - station3d-09-save (Persistência atômica, sanitização e restauração do estado da estação)
## - station3d-10-profile (Telemetria com Performance singleton, custom monitors e medição antes/depois)

var passed_assertions: int = 0
var total_assertions: int = 7

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: PERSISTÊNCIA E PERFORMANCE 3D")
	print("==================================================")
	
	test_save_game_atomic_write()
	test_load_game_and_restoration()
	test_save_sanitization_and_corrupted_data()
	test_performance_telemetry_snapshot()
	test_custom_monitors_registration()
	test_profile_before_and_after_measurement()
	test_real_scene_profiling()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha na suíte de testes de persistência e performance 3D!")
		get_tree().quit(1)

func test_save_game_atomic_write() -> void:
	var test_path: String = "user://test_station_save.json"
	var save_data: Dictionary = StationSaveManager.create_save_dictionary(
		2,
		false,
		Vector3(12.5, 0.0, -8.0),
		0.785
	)
	
	var success: bool = StationSaveManager.save_game(save_data, test_path)
	assert(success == true, "A gravação do arquivo de save deve retornar true.")
	assert(FileAccess.file_exists(test_path), "O arquivo definitivo de save deve existir fisicamente no disco.")
	assert(not FileAccess.file_exists(test_path + ".tmp"), "O arquivo temporário .tmp não deve persistir após substituição atômica.")
	
	passed_assertions += 1
	print("[TESTE 1/7 APROVADO] Gravação atômica de save em disco concluída sem resíduos temporários.")

func test_load_game_and_restoration() -> void:
	var test_path: String = "user://test_station_save.json"
	var loaded_data: Dictionary = StationSaveManager.load_game(test_path)
	
	assert(not loaded_data.is_empty(), "Os dados carregados não devem estar vazios.")
	assert(loaded_data["collected_cores"] == 2, "Núcleos coletados restaurados devem ser exatamente 2.")
	assert(loaded_data["is_power_active"] == false, "Estado de energia restaurado deve ser false.")
	assert(loaded_data["player_position"].is_equal_approx(Vector3(12.5, 0.0, -8.0)), "Posição tridimensional restaurada deve corresponder à gravada.")
	assert(is_equal_approx(loaded_data["player_rotation_y"], 0.785), "Rotação angular restaurada deve ser compatível.")
	
	passed_assertions += 1
	print("[TESTE 2/7 APROVADO] Leitura e restauração dos estados espaciais da estação validados.")

func test_save_sanitization_and_corrupted_data() -> void:
	var corrupt_path: String = "user://test_corrupt_save.json"
	var file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	file.store_string("{ 'json_invalido': true, sem_fechamento")
	file.close()
	
	var result_corrupt: Dictionary = StationSaveManager.load_game(corrupt_path)
	assert(result_corrupt.is_empty(), "Save com JSON malformado deve ser rejeitado defensivamente retornando dicionário vazio.")
	
	# Teste de valores estourados e fora de limites espaciais
	var raw_out_of_bounds := {
		"version": 1,
		"collected_cores": 9999,
		"is_power_active": true,
		"player_position": { "x": 5000.0, "y": -999.0, "z": 8000.0 },
		"player_rotation_y": 0.0
	}
	var sanitized: Dictionary = StationSaveManager.sanitize_save_data(raw_out_of_bounds)
	assert(sanitized["collected_cores"] == 10, "Núcleos coletados anômalos devem ser limitados a 10.")
	var clamped_pos: Vector3 = sanitized["player_position"]
	assert(clamped_pos.x <= StationSaveManager.BOUNDS_MAX.x and clamped_pos.x >= StationSaveManager.BOUNDS_MIN.x, "Posição X deve ser contida nos limites da estação.")
	assert(clamped_pos.y <= StationSaveManager.BOUNDS_MAX.y and clamped_pos.y >= StationSaveManager.BOUNDS_MIN.y, "Posição Y deve ser contida nos limites da estação.")
	assert(clamped_pos.z <= StationSaveManager.BOUNDS_MAX.z and clamped_pos.z >= StationSaveManager.BOUNDS_MIN.z, "Posição Z deve ser contida nos limites da estação.")
	
	passed_assertions += 1
	print("[TESTE 3/7 APROVADO] Sanitização defensiva contra JSON corrompido e coordenadas espaciais fora de limites.")

func test_performance_telemetry_snapshot() -> void:
	var snapshot: Dictionary = StationProfiler.take_snapshot()
	
	assert(snapshot.has("fps"), "Snapshot deve conter a chave 'fps'.")
	assert(snapshot.has("process_time_ms"), "Snapshot deve conter a chave 'process_time_ms'.")
	assert(snapshot.has("physics_time_ms"), "Snapshot deve conter a chave 'physics_time_ms'.")
	assert(snapshot.has("draw_calls"), "Snapshot deve conter a chave 'draw_calls'.")
	assert(snapshot.has("node_count"), "Snapshot deve conter a chave 'node_count'.")
	assert(snapshot.has("memory_static_mb"), "Snapshot deve conter a chave 'memory_static_mb'.")
	
	assert(snapshot["node_count"] > 0, "A contagem de nós na árvore ativa deve ser maior que zero.")
	assert(snapshot["memory_static_mb"] > 0.0, "Uso de memória estática deve ser estritamente positivo.")
	
	passed_assertions += 1
	print("[TESTE 4/7 APROVADO] Captura de snapshot de telemetria com integração à classe Performance.")

func test_custom_monitors_registration() -> void:
	var dummy_cores := func() -> float: return 3.0
	var dummy_drones := func() -> float: return 1.0
	
	StationProfiler.register_custom_monitors(dummy_cores, dummy_drones)
	assert(Performance.has_custom_monitor(StationProfiler.CUSTOM_MONITOR_CORES), "Monitor customizado de núcleos deve estar registrado no motor.")
	assert(Performance.has_custom_monitor(StationProfiler.CUSTOM_MONITOR_DRONES), "Monitor customizado de drones deve estar registrado no motor.")
	
	StationProfiler.unregister_custom_monitors()
	assert(not Performance.has_custom_monitor(StationProfiler.CUSTOM_MONITOR_CORES), "Monitor customizado deve ser removido após desregistro.")
	
	passed_assertions += 1
	print("[TESTE 5/7 APROVADO] Ciclo de vida e registro de monitores customizados no painel Debugger.")

func test_profile_before_and_after_measurement() -> void:
	var before := {
		"draw_calls": 84,
		"node_count": 120,
		"process_time_ms": 16.6,
		"memory_static_mb": 42.0
	}
	var after := {
		"draw_calls": 38,
		"node_count": 110,
		"process_time_ms": 11.2,
		"memory_static_mb": 41.5
	}
	
	var diff: Dictionary = StationProfiler.compute_diff(before, after)
	assert(diff["draw_calls_delta"] == -46, "Redução de draw calls deve ser exatamente -46.")
	assert(diff["node_count_delta"] == -10, "Redução de nós deve ser exatamente -10.")
	assert(is_equal_approx(diff["process_time_delta_ms"], -5.4), "Variação de tempo de frame deve ser -5.4 ms.")
	
	passed_assertions += 1
	print("[TESTE 6/7 APROVADO] Cálculo de diferença de telemetria antes e depois de intervenção de otimização.")

func test_real_scene_profiling() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	assert(hub_scene != null, "A cena station_hub.tscn deve ser carregada com sucesso.")
	
	var hub_inst: Node = hub_scene.instantiate()
	add_child(hub_inst)
	
	var snapshot_scene: Dictionary = StationProfiler.take_snapshot()
	assert(snapshot_scene["node_count"] > 20, "Cena completa da estação espacial deve instanciar mais de 20 nós na Scene Tree.")
	
	var report: String = StationProfiler.format_report(snapshot_scene, "ESTAÇÃO ESPACIAL AO VIVO")
	assert(report.length() > 50, "O relatório textual de performance deve ser gerado com sucesso.")
	
	hub_inst.free()
	passed_assertions += 1
	print("[TESTE 7/7 APROVADO] Perfilamento de cena real station_hub.tscn com telemetria ativa.")
