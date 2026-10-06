extends Node2D

## Gerador continuo de entidades inimigas ao redor do jogador na arena.
@export var inimigo_cena: PackedScene = preload("res://inimigo.tscn")
@export var intervalo_spawn: float = 2.5
@export var max_inimigos: int = 15
@export var distancia_spawn: float = 450.0

@onready var timer: Timer = %Timer

func _ready() -> void:
	timer.wait_time = intervalo_spawn
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

## Interrompe a geracao de novos inimigos na arena.
func parar() -> void:
	timer.stop()
	print("Spawner desativado.")

## Reinicia o ciclo de spawn.
func iniciar() -> void:
	timer.start()
	print("Spawner ativado.")

func _on_timer_timeout() -> void:
	var total_inimigos: int = get_tree().get_nodes_in_group("inimigos").size()
	if total_inimigos >= max_inimigos:
		return
	
	var player := get_tree().get_first_node_in_group("players") as CharacterBody2D
	if not is_instance_valid(player) or not player.get("esta_vivo"):
		parar()
		return
	
	# Calcula posicao circular aleatoria ao redor do jogador
	var angulo_aleatorio: float = randf() * TAU
	var deslocamento: Vector2 = Vector2.RIGHT.rotated(angulo_aleatorio) * distancia_spawn
	var posicao_alvo: Vector2 = player.global_position + deslocamento
	
	var novo_inimigo := inimigo_cena.instantiate() as Area2D
	novo_inimigo.global_position = posicao_alvo
	
	# Adiciona o inimigo a cena raiz para manter coordenadas de mundo
	get_parent().add_child(novo_inimigo)
