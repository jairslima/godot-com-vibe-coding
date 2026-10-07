extends Node3D

## Cena principal do MVP da Estação Sobrevivência.
## Orquestrador desacoplado e reativo, sem polling por frame.

const GameManagerScript = preload("res://src/core/game_manager.gd")
const SpawnerScript = preload("res://src/core/spawner_progressivo.gd")
const HUDScript = preload("res://src/ui/hud.gd")
const PlayerScript = preload("res://src/entities/player/player.gd")
const CreatureScript = preload("res://src/entities/creature/creature.gd")

@onready var game_manager: Node = %GameManager
@onready var spawner: SpawnerProgressivo = %SpawnerProgressivo
@onready var hud: HUD = %HUD
@onready var player: CharacterBody3D = %Player

func _ready() -> void:
	game_manager.tempo_atualizado.connect(hud.atualizar_tempo)
	game_manager.partida_finalizada.connect(_on_partida_finalizada)
	
	spawner.contagem_criaturas_alterada.connect(hud.atualizar_contagem_criaturas)
	spawner.criatura_instanciada.connect(_on_criatura_instanciada)
	
	hud.atualizar_contagem_criaturas(0)

func _on_criatura_instanciada(criatura: CharacterBody3D) -> void:
	if criatura is CreatureScript:
		criatura.jogador_capturado.connect(_on_jogador_capturado)

func _on_jogador_capturado() -> void:
	if game_manager.esta_em_andamento():
		game_manager.registrar_derrota("Uma criatura hostil capturou o jogador!")

func _on_partida_finalizada(vitoria: bool, motivo: String) -> void:
	hud.exibir_resultado(vitoria, motivo)
	spawner.desativar()
