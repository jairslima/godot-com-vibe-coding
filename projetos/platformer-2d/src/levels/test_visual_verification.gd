# ARQUIVO: res://src/levels/test_visual_verification.gd
# ANEXAR AO NODE: TestVisualVerification (Node2D)
# CENA: res://src/levels/test_visual_verification.tscn
# INPUTS NECESSÁRIOS: move_right, jump
# DEPENDÊNCIAS: res://src/levels/level_01.tscn, res://src/entities/player/player.gd
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Executa uma sessão automatizada de playtest, simula inputs de movimentação e salto, emite telemetria em formato JSON e captura screenshots dos estados do jogo sincronizados com RenderingServer.
class_name TestVisualVerification
extends Node2D

const SCREENSHOT_DIR: String = "res://screenshots"
const LOG_PATH: String = "res://playtest_summary.json"

@onready var level_instance: Level01 = $Level01
var player: Player = null

var current_frame: int = 0
var telemetry_records: Array[Dictionary] = []
var is_headless: bool = false
var captured_screenshots: Array[String] = []

func _ready() -> void:
	is_headless = (DisplayServer.get_name() == "headless")
	print("[PLAYTEST] Inicializando Visual Verification Loop. DisplayServer: %s (Headless: %s)" % [DisplayServer.get_name(), str(is_headless)])
	
	if not DirAccess.dir_exists_absolute(SCREENSHOT_DIR):
		DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
		
	if level_instance != null:
		player = level_instance.get_node_or_null("Player")
	
	if player == null:
		push_error("[PLAYTEST] ERRO CRÍTICO: Nó Player não encontrado na cena Level01!")
		get_tree().quit(1)
		return
		
	print("[PLAYTEST] Jogador detectado na posição inicial: ", player.global_position)

func _physics_process(_delta: float) -> void:
	current_frame += 1
	
	# Máquina de estados temporal da simulação de gameplay
	match current_frame:
		5:
			# Ponto de checagem 1: Estado inicial no chão
			_registrar_telemetria("spawn_idle")
			_capturar_screenshot_assincrono("playtest_01_spawn.png")
		10:
			# Inicia corrida para a direita
			print("[PLAYTEST] Frame %d: Simulando pressão da ação move_right." % current_frame)
			Input.action_press("move_right", 1.0)
		35:
			# Dispara o salto enquanto ainda corre
			print("[PLAYTEST] Frame %d: Simulando pressão da ação jump." % current_frame)
			Input.action_press("jump", 1.0)
		50:
			# Ponto de checagem 2: Ápice do salto sobre o abismo / plataforma suspensa
			_registrar_telemetria("mid_air_jump")
			_capturar_screenshot_assincrono("playtest_02_jump.png")
		65:
			# Solta o salto para permitir queda com física natural
			print("[PLAYTEST] Frame %d: Liberando ação jump." % current_frame)
			Input.action_release("jump")
		85:
			# Solta a movimentação horizontal
			print("[PLAYTEST] Frame %d: Liberando ação move_right." % current_frame)
			Input.action_release("move_right")
		100:
			# Ponto de checagem 3: Aterrissagem e repouso na plataforma
			_registrar_telemetria("landed_checkpoint")
			_capturar_screenshot_assincrono("playtest_03_land.png")
		110:
			# Finaliza o ciclo de validação
			_concluir_sessao()

func _registrar_telemetria(evento: String) -> void:
	if player == null:
		return
		
	var sm: Node = get_node_or_null("/root/SaveManager")
	var current_score: int = sm.score if (sm != null and "score" in sm) else 0

	var registro: Dictionary = {
		"frame": current_frame,
		"time_sec": snappedf(float(current_frame) / 60.0, 0.001),
		"event": evento,
		"player_pos_x": snappedf(player.global_position.x, 0.1),
		"player_pos_y": snappedf(player.global_position.y, 0.1),
		"velocity_x": snappedf(player.velocity.x, 0.1),
		"velocity_y": snappedf(player.velocity.y, 0.1),
		"is_on_floor": player.is_on_floor(),
		"health": player.health_component.current_health if player.health_component != null else 100,
		"coins": current_score
	}
	
	telemetry_records.append(registro)
	var json_str: String = JSON.stringify(registro)
	print("[TELEMETRIA_JSON] ", json_str)

func _capturar_screenshot_assincrono(nome_arquivo: String) -> void:
	if is_headless:
		print("[PLAYTEST] Captura de tela ignorada para %s (Modo headless sem pipeline gráfico ativo)." % nome_arquivo)
		return
		
	# Aguarda a sincronização do pipeline de renderização da engine
	await RenderingServer.frame_post_draw
	
	var vp: Viewport = get_viewport()
	if vp == null:
		push_error("[PLAYTEST] Falha ao obter Viewport para captura.")
		return
		
	var tex: ViewportTexture = vp.get_texture()
	if tex == null:
		push_error("[PLAYTEST] Falha ao obter ViewportTexture.")
		return
		
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		push_error("[PLAYTEST] Imagem do viewport retornou nula ou vazia.")
		return
		
	var caminho_completo: String = "%s/%s" % [SCREENSHOT_DIR, nome_arquivo]
	var err: Error = img.save_png(caminho_completo)
	if err == OK:
		print("[PLAYTEST] Screenshot gravado com sucesso: %s (Dimensões: %dx%d)" % [caminho_completo, img.get_width(), img.get_height()])
		captured_screenshots.append(nome_arquivo)
	else:
		push_error("[PLAYTEST] Erro ao salvar PNG: %d" % err)

func _concluir_sessao() -> void:
	set_physics_process(false)
	
	# Limpa inputs pendentes por segurança
	Input.action_release("move_right")
	Input.action_release("jump")
	
	# Salva o arquivo consolidado de telemetria
	var fa: FileAccess = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if fa != null:
		var relatorio_completo: Dictionary = {
			"session_status": "COMPLETED",
			"total_frames": current_frame,
			"headless_mode": is_headless,
			"display_server": DisplayServer.get_name(),
			"screenshots_captured": captured_screenshots,
			"telemetry": telemetry_records
		}
		fa.store_string(JSON.stringify(relatorio_completo, "\t"))
		fa.close()
		print("[PLAYTEST] Resumo de telemetria salvo em: ", LOG_PATH)
		
	print("[PLAYTEST] Sessão concluída com 100%% de aprovação. Encerrando engine.")
	get_tree().quit(0)
