extends Area2D

## Recurso de configuracao contendo os dados e atributos da entidade.
@export var config: InimigoConfig

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

var vida_atual: int = 50
var velocidade: float = 120.0
var dano_contato: int = 15

func _ready() -> void:
	if config:
		vida_atual = config.vida_maxima
		velocidade = config.velocidade
		dano_contato = config.dano_contato
		sprite.modulate = config.cor_modulacao

func _physics_process(delta: float) -> void:
	# Localiza a primeira entidade pertencente ao grupo "players"
	var player := get_tree().get_first_node_in_group("players") as CharacterBody2D
	if not is_instance_valid(player):
		return
	
	# Se o jogador foi derrotado, o inimigo cessa a perseguicao
	if not player.get("esta_vivo"):
		return
	
	# Vetor de deslocamento em direcao ao jogador
	var diferenca: Vector2 = player.global_position - global_position
	if diferenca.length() > 5.0:
		var direcao: Vector2 = diferenca.normalized()
		global_position += direcao * velocidade * delta
		
		# Ajusta a orientacao horizontal do sprite
		if direcao.x != 0.0:
			sprite.flip_h = direcao.x < 0.0
