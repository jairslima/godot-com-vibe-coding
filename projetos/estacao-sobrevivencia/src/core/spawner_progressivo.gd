class_name SpawnerProgressivo
extends Node3D

## Gerador de criaturas com taxa progressiva baseada no tempo decorrido.
## Refatorado para emitir sinais reativos de contagem e instância, eliminando polling.

signal criatura_instanciada(criatura: CharacterBody3D)
signal contagem_criaturas_alterada(total: int)

const CreatureScript = preload("res://src/entities/creature/creature.gd")

@export var cena_criatura: PackedScene
@export var limite_maximo_criaturas: int = 16
@export var duracao_total: float = 300.0
@export var pontos_spawn: Array[Vector3] = []

var tempo_decorrido: float = 0.0
var cronometro_spawn: float = 0.0
var ativo: bool = true
var criaturas_ativas: Array[CharacterBody3D] = []

func _ready() -> void:
	if pontos_spawn.is_empty():
		pontos_spawn = [
			Vector3(-12.0, 0.5, -12.0),
			Vector3(12.0, 0.5, -12.0),
			Vector3(-12.0, 0.5, 12.0),
			Vector3(12.0, 0.5, 12.0),
			Vector3(0.0, 0.5, -14.0),
			Vector3(0.0, 0.5, 14.0)
		]

func _process(delta: float) -> void:
	if not ativo:
		return
	
	tempo_decorrido += delta
	cronometro_spawn += delta
	
	var intervalo_atual: float = calcular_intervalo_spawn(tempo_decorrido)
	if cronometro_spawn >= intervalo_atual:
		cronometro_spawn = 0.0
		tentar_instanciar_criatura()

func calcular_taxa_spawn(tempo_atual: float) -> float:
	var progresso: float = clampf(tempo_atual / duracao_total, 0.0, 1.0)
	var taxa_minima: float = 0.05
	var taxa_maxima: float = 0.40
	return taxa_minima + (taxa_maxima - taxa_minima) * pow(progresso, 2.0)

func calcular_intervalo_spawn(tempo_atual: float) -> float:
	var taxa: float = calcular_taxa_spawn(tempo_atual)
	if taxa <= 0.0:
		return 20.0
	return 1.0 / taxa

func tentar_instanciar_criatura() -> CharacterBody3D:
	_limpar_criaturas_invalidas()
	if criaturas_ativas.size() >= limite_maximo_criaturas:
		return null
	
	if cena_criatura == null:
		return null
	
	var nova_criatura: CharacterBody3D = cena_criatura.instantiate() as CharacterBody3D
	if nova_criatura == null:
		return null
	
	var indice: int = randi() % pontos_spawn.size()
	nova_criatura.position = pontos_spawn[indice]
	add_child(nova_criatura)
	
	_registrar_criatura(nova_criatura)
	return nova_criatura

func _registrar_criatura(criatura: CharacterBody3D) -> void:
	criaturas_ativas.append(criatura)
	criatura.tree_exited.connect(func() -> void:
		_desregistrar_criatura(criatura)
	)
	contagem_criaturas_alterada.emit(criaturas_ativas.size())
	criatura_instanciada.emit(criatura)

func _desregistrar_criatura(criatura: CharacterBody3D) -> void:
	if criatura in criaturas_ativas:
		criaturas_ativas.erase(criatura)
		contagem_criaturas_alterada.emit(criaturas_ativas.size())

func _limpar_criaturas_invalidas() -> void:
	var validas: Array[CharacterBody3D] = []
	for c in criaturas_ativas:
		if is_instance_valid(c):
			validas.append(c)
	if validas.size() != criaturas_ativas.size():
		criaturas_ativas = validas
		contagem_criaturas_alterada.emit(criaturas_ativas.size())

func obter_total_criaturas_ativas() -> int:
	_limpar_criaturas_invalidas()
	return criaturas_ativas.size()

func desativar() -> void:
	ativo = false
