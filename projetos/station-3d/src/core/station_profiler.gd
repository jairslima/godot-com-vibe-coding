class_name StationProfiler
extends Node

## Módulo de diagnóstico, perfilamento e telemetria de desempenho (checkpoint station3d-10-profile).
## Conecta-se ao singleton Performance do Godot 4.7.2 para colher métricas reais de CPU, GPU, nós e draw calls.

const CUSTOM_MONITOR_CORES: StringName = &"Station/ActiveCores"
const CUSTOM_MONITOR_DRONES: StringName = &"Station/ActiveDrones"

static func take_snapshot() -> Dictionary:
	var snapshot := Dictionary()
	
	snapshot["fps"] = Performance.get_monitor(Performance.TIME_FPS)
	snapshot["process_time_ms"] = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	snapshot["physics_time_ms"] = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	snapshot["draw_calls"] = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	snapshot["objects_in_frame"] = int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
	snapshot["primitives_in_frame"] = int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	snapshot["node_count"] = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	snapshot["orphan_node_count"] = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	snapshot["memory_static_mb"] = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	snapshot["video_memory_mb"] = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0)
	snapshot["physics_3d_active"] = int(Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS))
	
	return snapshot

static func format_report(snapshot: Dictionary, label: String = "SNAPSHOT") -> String:
	var lines: Array[String] = []
	lines.append("=== TELEMETRIA DE PERFORMANCE [%s] ===" % label)
	lines.append("FPS: %.1f | Frame Process: %.2f ms | Physics Process: %.2f ms" % [
		snapshot.get("fps", 0.0),
		snapshot.get("process_time_ms", 0.0),
		snapshot.get("physics_time_ms", 0.0)
	])
	lines.append("Draw Calls: %d | Objetos no Quadro: %d | Primitivas: %d" % [
		snapshot.get("draw_calls", 0),
		snapshot.get("objects_in_frame", 0),
		snapshot.get("primitives_in_frame", 0)
	])
	lines.append("Nós Ativos: %d | Órfãos: %d | Física 3D Ativa: %d" % [
		snapshot.get("node_count", 0),
		snapshot.get("orphan_node_count", 0),
		snapshot.get("physics_3d_active", 0)
	])
	lines.append("Memória Estática: %.2f MB | VRAM: %.2f MB" % [
		snapshot.get("memory_static_mb", 0.0),
		snapshot.get("video_memory_mb", 0.0)
	])
	lines.append("==========================================")
	return "\n".join(lines)

static func compute_diff(before: Dictionary, after: Dictionary) -> Dictionary:
	var diff := Dictionary()
	diff["draw_calls_delta"] = int(after.get("draw_calls", 0)) - int(before.get("draw_calls", 0))
	diff["node_count_delta"] = int(after.get("node_count", 0)) - int(before.get("node_count", 0))
	diff["process_time_delta_ms"] = float(after.get("process_time_ms", 0.0)) - float(before.get("process_time_ms", 0.0))
	diff["memory_delta_mb"] = float(after.get("memory_static_mb", 0.0)) - float(before.get("memory_static_mb", 0.0))
	return diff

static func register_custom_monitors(cores_callable: Callable, drones_callable: Callable) -> void:
	if not Performance.has_custom_monitor(CUSTOM_MONITOR_CORES):
		Performance.add_custom_monitor(CUSTOM_MONITOR_CORES, cores_callable)
	if not Performance.has_custom_monitor(CUSTOM_MONITOR_DRONES):
		Performance.add_custom_monitor(CUSTOM_MONITOR_DRONES, drones_callable)

static func unregister_custom_monitors() -> void:
	if Performance.has_custom_monitor(CUSTOM_MONITOR_CORES):
		Performance.remove_custom_monitor(CUSTOM_MONITOR_CORES)
	if Performance.has_custom_monitor(CUSTOM_MONITOR_DRONES):
		Performance.remove_custom_monitor(CUSTOM_MONITOR_DRONES)
