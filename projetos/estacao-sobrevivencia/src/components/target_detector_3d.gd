class_name TargetDetector3D
extends Node3D

## Componente modular de detecção e rastreamento de alvos no espaço tridimensional.
## Isola a busca espacial por grupos e o cálculo de vetores direcionais horizontais.

signal alvo_adquirido(alvo: Node3D)
signal alvo_perdido()

@export var grupo_alvo: String = "players"

var _alvo_atual: Node3D = null

func _ready() -> void:
	if _alvo_atual == null:
		procurar_alvo()

func definir_alvo(novo_alvo: Node3D) -> void:
	if _alvo_atual == novo_alvo:
		return
	
	_alvo_atual = novo_alvo
	if _alvo_atual != null:
		alvo_adquirido.emit(_alvo_atual)
	else:
		alvo_perdido.emit()

func obter_alvo() -> Node3D:
	return _alvo_atual

func tem_alvo() -> bool:
	return _alvo_atual != null and is_instance_valid(_alvo_atual)

func procurar_alvo() -> Node3D:
	var candidatos: Array[Node] = get_tree().get_nodes_in_group(grupo_alvo)
	if candidatos.size() > 0:
		var primeiro_candidato: Node3D = candidatos[0] as Node3D
		definir_alvo(primeiro_candidato)
		return primeiro_candidato
	
	definir_alvo(null)
	return null

func obter_vetor_para_alvo(origem: Vector3) -> Vector3:
	if not tem_alvo():
		return Vector3.ZERO
	
	var vetor: Vector3 = _alvo_atual.global_position - origem
	vetor.y = 0.0
	return vetor

func obter_distancia_para_alvo(origem: Vector3) -> float:
	if not tem_alvo():
		return INF
	
	return obter_vetor_para_alvo(origem).length()

func obter_direcao_normalizada(origem: Vector3) -> Vector3:
	var vetor: Vector3 = obter_vetor_para_alvo(origem)
	if vetor.length_squared() > 0.0001:
		return vetor.normalized()
	return Vector3.ZERO
