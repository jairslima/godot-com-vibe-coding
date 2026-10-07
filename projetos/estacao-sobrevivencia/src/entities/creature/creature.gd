class_name Creature
extends CharacterBody3D

## Criatura hostil perseguidora da Estação Sobrevivência.
## Refatorada para delegar a localização espacial ao componente TargetDetector3D.

signal jogador_capturado

const TargetDetectorScript = preload("res://src/components/target_detector_3d.gd")

@export var velocidade: float = 3.2
@export var distancia_ataque: float = 1.2
@export var gravidade: float = 9.8

@onready var detector: TargetDetector3D = _obter_ou_criar_detector()

var atacou: bool = false

## Propriedade para compatibilidade estrita com contratos e suítes anteriores.
var alvo: Node3D:
	get:
		if detector != null:
			return detector.obter_alvo()
		return null
	set(valor):
		if detector == null:
			detector = _obter_ou_criar_detector()
		detector.definir_alvo(valor)

func _ready() -> void:
	add_to_group("creatures")
	if detector == null:
		detector = _obter_ou_criar_detector()
	if not detector.tem_alvo():
		detector.procurar_alvo()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta
	
	if atacou:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	
	if detector == null or not detector.tem_alvo():
		procurar_alvo()
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	
	var distancia: float = detector.obter_distancia_para_alvo(global_position)
	if distancia <= distancia_ataque:
		atacar_jogador()
		return
	
	if distancia > 0.1:
		var direcao: Vector3 = detector.obter_direcao_normalizada(global_position)
		velocity.x = direcao.x * velocidade
		velocity.z = direcao.z * velocidade
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()

func definir_alvo(novo_alvo: Node3D) -> void:
	if detector == null:
		detector = _obter_ou_criar_detector()
	detector.definir_alvo(novo_alvo)

func procurar_alvo() -> void:
	if detector == null:
		detector = _obter_ou_criar_detector()
	detector.procurar_alvo()

func atacar_jogador() -> void:
	if atacou:
		return
	atacou = true
	jogador_capturado.emit()

func _obter_ou_criar_detector() -> TargetDetector3D:
	if has_node("%TargetDetector3D"):
		return get_node("%TargetDetector3D") as TargetDetector3D
	for child in get_children():
		if child is TargetDetector3D:
			return child as TargetDetector3D
	var novo_detector: TargetDetector3D = TargetDetector3D.new()
	novo_detector.name = "TargetDetector3D"
	add_child(novo_detector)
	return novo_detector
