class_name StationHub
extends Node3D

## Controlador de inicialização do setor central da estação espacial.
## Responsável pelo registro de prontidão dos sistemas de suporte e iluminação.

@onready var world_env: WorldEnvironment = %WorldEnvironment
@onready var sun_light: DirectionalLight3D = %DirectionalLight3D
@onready var station_camera: Camera3D = %StationCamera
@onready var floor_csg: CSGBox3D = %Floor

func _ready() -> void:
	print("--- ESTAÇÃO ESPACIAL: BOOTSTRAP 3D ---")
	print("Setor central inicializado com sucesso.")
	print("Câmera ativa no ponto: ", station_camera.global_position)
	print("Colisão do solo CSG ativa: ", floor_csg.use_collision)
	
	if world_env and world_env.environment:
		print("Ambiente 3D carregado: ", world_env.environment.resource_name if world_env.environment.resource_name != "" else "Environment padrão")
	if sun_light:
		print("Luz direcional ativa com sombras: ", sun_light.shadow_enabled)
