@tool
extends SceneTree

func _init() -> void:
	print("--- MEDIÇÃO DE PERFORMANCE REAL NA ESTAÇÃO 3D (GODOT 4.7.2) ---")
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub: Node3D = hub_scene.instantiate() as Node3D
	root.add_child(hub)
	
	# Simula renderização de alguns quadros
	print("Coletando métricas após inicialização da cena...")
	
	var snap1 := StationProfiler.take_snapshot()
	print("=== BASELINE DA CENA STATION_HUB ===")
	print(StationProfiler.format_report(snap1, "BASELINE"))
	
	# Alteração para simular estresse: adiciona 5 OmniLight3D adicionais com sombras ativadas
	print("\nAplicando estresse: adicionando 5 OmniLight3D com sombras ativadas no setor...")
	var lights: Array[OmniLight3D] = []
	for i in range(5):
		var omni := OmniLight3D.new()
		omni.name = "StressLight_%d" % i
		omni.position = Vector3(float(i * 3 - 6), 3.0, float(i * 2 - 4))
		omni.omni_range = 8.0
		omni.light_energy = 1.5
		omni.shadow_enabled = true
		hub.add_child(omni)
		lights.append(omni)
	
	var snap_stress := StationProfiler.take_snapshot()
	print("=== APÓS ADIÇÃO DE SOMBRAS PESADAS (ESTRESSE) ===")
	print(StationProfiler.format_report(snap_stress, "ESTRESSE"))
	
	# Otimização: remove sombras pontuais das luzes adicionadas e reverte para preenchimento
	print("\nAplicando otimização: desativando sombras nas lâmpadas pontuais de preenchimento...")
	for l in lights:
		l.shadow_enabled = false
	
	var snap_opt := StationProfiler.take_snapshot()
	print("=== APÓS OTIMIZAÇÃO (SOMBRAS DESATIVADAS NAS LUZES DE PREENCHIMENTO) ===")
	print(StationProfiler.format_report(snap_opt, "OTIMIZADO"))
	
	var diff := StationProfiler.compute_diff(snap_stress, snap_opt)
	print("\n=== COMPARATIVO / DIFF DE PERFORMANCE ===")
	print("Variação de Draw Calls: %d" % diff["draw_calls_delta"])
	print("Variação de Nós: %d" % diff["node_count_delta"])
	print("Variação de Memória: %.2f MB" % diff["memory_delta_mb"])
	
	for l in lights:
		l.free()
	hub.free()
	quit(0)
