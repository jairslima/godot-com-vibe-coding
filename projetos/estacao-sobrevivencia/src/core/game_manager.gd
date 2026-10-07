class_name GameManager
extends Node

## Gerenciador central de partida da Estação Sobrevivência.
## Controla o cronômetro de 300 segundos (cinco minutos) e as regras de vitória e derrota.

enum EstadoJogo {
	EM_ANDAMENTO,
	VITORIA,
	DERROTA
}

signal tempo_atualizado(tempo_restante: float)
signal partida_finalizada(vitoria: bool, motivo: String)

@export var duracao_partida: float = 300.0

var tempo_restante: float = 300.0
var estado: EstadoJogo = EstadoJogo.EM_ANDAMENTO

func _ready() -> void:
	tempo_restante = duracao_partida
	tempo_atualizado.emit(tempo_restante)

func _process(delta: float) -> void:
	if estado != EstadoJogo.EM_ANDAMENTO:
		return
	
	tempo_restante -= delta
	tempo_atualizado.emit(maxf(tempo_restante, 0.0))
	
	if tempo_restante <= 0.0:
		concluir_vitoria()

func concluir_vitoria() -> void:
	if estado != EstadoJogo.EM_ANDAMENTO:
		return
	estado = EstadoJogo.VITORIA
	tempo_restante = 0.0
	partida_finalizada.emit(true, "Sobrevivência confirmada! O módulo de fuga acoplou com sucesso.")

func registrar_derrota(motivo: String = "Capturado por uma criatura hostil!") -> void:
	if estado != EstadoJogo.EM_ANDAMENTO:
		return
	estado = EstadoJogo.DERROTA
	partida_finalizada.emit(false, motivo)

func esta_em_andamento() -> bool:
	return estado == EstadoJogo.EM_ANDAMENTO
