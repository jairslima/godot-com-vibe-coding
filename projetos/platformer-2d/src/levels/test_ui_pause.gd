# ARQUIVO: res://src/levels/test_ui_pause.gd
# ANEXAR AO NODE: TestUIPause (Node2D)
# CENA: res://src/levels/test_ui_pause.tscn
# INPUTS NECESSÁRIOS: pause
# DEPENDÊNCIAS: res://src/ui/hud.tscn, res://src/ui/pause_menu.tscn, res://src/ui/game_over_menu.tscn
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: Validação automatizada headless de HUD desacoplado, alternância de pausa via get_tree().paused, process_mode e foco de acessibilidade.
class_name TestUIPause
extends Node2D

@onready var hud: HUD = $HUD
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_menu: GameOverMenu = $GameOverMenu

var frame_count: int = 0
var testes_passaram: int = 0

func _ready() -> void:
	# O nó de teste precisa continuar rodando mesmo quando a SceneTree é pausada
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	frame_count += 1

	match frame_count:
		2:
			_testar_hud_atualizacao()
		4:
			_testar_pause_ativacao()
		6:
			_testar_pause_desativacao()
		8:
			_testar_game_over_modal()
		10:
			_testar_acessibilidade_e_process_mode()
		12:
			_concluir_testes()

func _testar_hud_atualizacao() -> void:
	assert(hud != null, "Nó HUD deve existir na cena de teste.")
	assert(hud.health_bar.value == 3.0, "Valor inicial da barra de vida deve ser 3.0.")

	hud.atualizar_vida(1, 3)
	assert(hud.health_bar.value == 1.0, "Barra de vida deve refletir o valor atualizado de 1.0.")
	assert(hud.health_label.text == "VIDA: 1 / 3", "Rótulo de texto deve exibir formato correto.")

	hud.atualizar_pontos(7)
	assert(hud.score_label.text == "07", "Contador de pontos deve formatar com zeros à esquerda.")

	testes_passaram += 1
	print("[TESTE 1/5 PASSOU] HUD desacoplado atualizou ProgressBar e Labels via métodos dedicados.")

func _testar_pause_ativacao() -> void:
	assert(not get_tree().paused, "Árvore de cena deve iniciar sem pausa.")
	assert(not pause_menu.overlay.visible, "Overlay de pausa deve iniciar oculto.")

	pause_menu.pausar()
	assert(get_tree().paused, "Árvore deve reportar estado pausado após chamada a pausar().")
	assert(pause_menu.overlay.visible, "Overlay deve estar visível com o jogo pausado.")
	assert(pause_menu.resume_button.has_focus(), "Botão Continuar deve receber foco para navegação por teclado/gamepad.")

	testes_passaram += 1
	print("[TESTE 2/5 PASSOU] Menu de pausa ativado com congelamento da SceneTree e foco de acessibilidade.")

func _testar_pause_desativacao() -> void:
	pause_menu.despausar()
	assert(not get_tree().paused, "Árvore deve retomar a execução após despausar().")
	assert(not pause_menu.overlay.visible, "Overlay deve voltar a ficar oculto.")

	testes_passaram += 1
	print("[TESTE 3/5 PASSOU] Despausa restaurou a SceneTree para execução normal e ocultou a interface.")

func _testar_game_over_modal() -> void:
	assert(not game_over_menu.overlay.visible, "Menu de Game Over deve iniciar oculto.")

	game_over_menu.exibir()
	assert(get_tree().paused, "Game Over deve congelar a cena.")
	assert(game_over_menu.overlay.visible, "Overlay de Game Over deve estar visível.")
	assert(game_over_menu.retry_button.has_focus(), "Botão de tentar novamente deve receber foco automático.")

	# Restaura a árvore para não afetar testes seguintes
	get_tree().paused = false
	game_over_menu.ocultar()

	testes_passaram += 1
	print("[TESTE 4/5 PASSOU] Menu modal de Game Over testado com pausa forçada e foco no botão de reinício.")

func _testar_acessibilidade_e_process_mode() -> void:
	assert(pause_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu deve ter process_mode = PROCESS_MODE_ALWAYS.")
	assert(game_over_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "GameOverMenu deve ter process_mode = PROCESS_MODE_ALWAYS.")
	assert(pause_menu.resume_button.focus_mode != Control.FOCUS_NONE, "Botões de menu devem permitir foco.")
	assert(game_over_menu.retry_button.focus_mode != Control.FOCUS_NONE, "Botões de Game Over devem permitir foco.")

	testes_passaram += 1
	print("[TESTE 5/5 PASSOU] Configurações de process_mode e modos de foco de acessibilidade homologados.")

func _concluir_testes() -> void:
	assert(testes_passaram == 5, "Todos os 5 testes de UI e pausa devem passar.")
	print("------------------------------------------------------------")
	print("TODOS OS %d TESTES DE INTERFACE, HUD E PAUSA APROVADOS COM SUCESSO." % testes_passaram)
	print("------------------------------------------------------------")
	get_tree().quit(0)
