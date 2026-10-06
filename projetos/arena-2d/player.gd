extends CharacterBody2D

## Sinais de comunicacao desacoplada para notificacao de estado.
signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu()

## Velocidade de deslocamento do jogador em pixels por segundo.
@export var speed: float = 300.0

## Capacidade total de pontos de vida do personagem.
@export var vida_maxima: int = 100

## Pontos de vida atuais do jogador.
var vida_atual: int = 100

## Flag que controla se o personagem ainda esta ativo no loop de jogo.
var esta_vivo: bool = true

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	vida_atual = vida_maxima
	print("Player inicializado na arena. Posicao: ", global_position)

func _physics_process(_delta: float) -> void:
	if not esta_vivo:
		velocity = Vector2.ZERO
		return
	
	# Leitura vetorial das 8 direcoes com normalizacao automatica
	var direcao: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direcao * speed
	move_and_slide()

## Aplica dano ao jogador e emite os sinais correspondentes.
func receber_dano(quantidade: int) -> void:
	if not esta_vivo or vida_atual <= 0:
		return
	
	vida_atual = maxi(0, vida_atual - quantidade)
	vida_alterada.emit(vida_atual, vida_maxima)
	
	if vida_atual == 0:
		esta_vivo = false
		morreu.emit()
