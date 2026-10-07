extends CharacterBody2D

## Sinais de comunicacao desacoplada para notificacao de estado.
signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu()
signal stamina_alterada(stamina_atual: float, stamina_maxima: float)

## Velocidade de deslocamento do jogador em pixels por segundo.
@export var speed: float = 300.0

## Capacidade total de pontos de vida do personagem.
@export var vida_maxima: int = 100

## Duracao da janela de invulnerabilidade apos sofrer dano (em segundos).
@export var tempo_invulnerabilidade: float = 0.8

## Capacidade maxima de stamina para corrida rapida.
@export var stamina_maxima: float = 100.0

## Taxa de consumo de stamina por segundo durante corrida rapida.
@export var consumo_stamina: float = 40.0

## Taxa de regeneracao de stamina por segundo quando em repouso ou velocidade normal.
@export var regeneracao_stamina: float = 25.0

## Multiplicador de velocidade aplicado durante a corrida rapida.
@export var multiplicador_sprint: float = 1.6

## Pontos de vida atuais do jogador.
var vida_atual: int = 100

## Valor atual de stamina do jogador.
var stamina_atual: float = 100.0

## Flag que indica se o jogador esta ativamente correndo com sprint.
var esta_correndo: bool = false

## Flag que indica se o jogador esta temporariamente protegido contra dano.
var esta_invulneravel: bool = false

## Flag que controla se o personagem ainda esta ativo no loop de jogo.
var esta_vivo: bool = true

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	vida_atual = vida_maxima
	stamina_atual = stamina_maxima
	print("Player inicializado na arena. Posicao: ", global_position)

func _physics_process(delta: float) -> void:
	if not esta_vivo:
		velocity = Vector2.ZERO
		return
	
	# Leitura vetorial das 8 direcoes com normalizacao automatica
	var direcao: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Gerenciamento da mecanica de corrida rapida orientada por stamina
	var quer_correr: bool = Input.is_action_pressed("sprint") and direcao != Vector2.ZERO
	if quer_correr:
		if stamina_atual > 0.0:
			esta_correndo = true
			stamina_atual = maxf(0.0, stamina_atual - consumo_stamina * delta)
			velocity = direcao * (speed * multiplicador_sprint)
		else:
			esta_correndo = false
			velocity = direcao * speed
	else:
		esta_correndo = false
		if stamina_atual < stamina_maxima:
			stamina_atual = minf(stamina_maxima, stamina_atual + regeneracao_stamina * delta)
		velocity = direcao * speed
	
	stamina_alterada.emit(stamina_atual, stamina_maxima)
	move_and_slide()

## Aplica dano ao jogador respeitando o periodo de invulnerabilidade.
func receber_dano(quantidade: int) -> void:
	if not esta_vivo or esta_invulneravel:
		return
	
	vida_atual = maxi(0, vida_atual - quantidade)
	print("Player recebeu ", quantidade, " de dano. Vida restante: ", vida_atual, "/", vida_maxima)
	vida_alterada.emit(vida_atual, vida_maxima)
	
	if vida_atual == 0:
		esta_vivo = false
		collision_shape.set_deferred("disabled", true)
		sprite.modulate = Color(0.4, 0.4, 0.4, 0.7)
		print("Player foi derrotado!")
		morreu.emit()
	else:
		_ativar_invulnerabilidade()

## Ativa o temporizador de invulnerabilidade e aplica feedback visual de piscar.
func _ativar_invulnerabilidade() -> void:
	esta_invulneravel = true
	
	# Feedback visual de dano: modula para tom avermelhado e semi-transparente
	sprite.modulate = Color(1.0, 0.3, 0.3, 0.6)
	
	# Aguarda o encerramento da janela de protecao de forma assincrona
	await get_tree().create_timer(tempo_invulnerabilidade).timeout
	
	if is_instance_valid(self) and esta_vivo:
		esta_invulneravel = false
		sprite.modulate = Color.WHITE

## Restaura pontos de vida do jogador sem ultrapassar a capacidade maxima.
func curar(quantidade: int) -> void:
	if not esta_vivo:
		return
	
	vida_atual = mini(vida_maxima, vida_atual + quantidade)
	print("Player curado em ", quantidade, " pontos. Vida atual: ", vida_atual, "/", vida_maxima)
	vida_alterada.emit(vida_atual, vida_maxima)
