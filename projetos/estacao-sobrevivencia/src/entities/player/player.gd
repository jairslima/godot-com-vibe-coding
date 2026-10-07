class_name Player
extends CharacterBody3D

## Controlador de movimentação do jogador em primeira pessoa para o MVP da Estação.
## Implementa deslocamento tridimensional com física e câmera integrada.

@export var velocidade: float = 5.0
@export var gravidade: float = 9.8

@onready var camera: Camera3D = %Camera3D

func _ready() -> void:
	add_to_group("players")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direcao: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if direcao != Vector3.ZERO:
		velocity.x = direcao.x * velocidade
		velocity.z = direcao.z * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity.z = move_toward(velocity.z, 0.0, velocidade)
	
	move_and_slide()
