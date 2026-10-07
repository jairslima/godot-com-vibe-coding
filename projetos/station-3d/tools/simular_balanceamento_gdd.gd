# tools/simular_balanceamento_gdd.gd
# Simulador matemático de balanceamento para o Game Design Document da Estação 3D
# Valida curvas de spawn progressivo e consumo de recursos ao longo de 5 minutos (300 segundos).
extends SceneTree

const DURACAO_TOTAL_SEGUNDOS: float = 300.0
const INTERVALO_SIMULACAO_DELTA: float = 1.0
const LIMITE_MAXIMO_CRIATURAS: int = 16
const ENERGIA_INICIAL_ESTACAO: float = 100.0
const CONSUMO_ENERGIA_POR_SEGUNDO: float = 0.5
const ENERGIA_POR_CELULA_COLETADA: float = 35.0

func _init() -> void:
	print("--- INICIANDO SIMULACAO DE BALANCEAMENTO DO GDD (300 SEGUNDOS) ---")
	var sucesso: bool = executar_simulacao()
	if sucesso:
		print("--- SIMULACAO CONCLUIDA COM SUCESSO: REGRAS DO GDD MATEMATICAMENTE VIAVEIS ---")
		quit(0)
	else:
		printerr("--- FALHA NA VALIDACAO DO BALANCEAMENTO DO GDD ---")
		quit(1)

func calcular_taxa_spawn(tempo_atual: float) -> float:
	# Curva de progressao suave exponencial de spawn: de 0.05 spawns/seg (1 a cada 20s) a 0.40 spawns/seg (1 a cada 2.5s)
	var progresso: float = clampf(tempo_atual / DURACAO_TOTAL_SEGUNDOS, 0.0, 1.0)
	var taxa_minima: float = 0.05
	var taxa_maxima: float = 0.40
	return taxa_minima + (taxa_maxima - taxa_minima) * pow(progresso, 2.0)

func executar_simulacao() -> bool:
	var tempo_decorrido: float = 0.0
	var criaturas_ativas: int = 0
	var total_criaturas_geradas: int = 0
	var criaturas_eliminadas_ou_dispersas: int = 0
	var energia_estacao: float = ENERGIA_INICIAL_ESTACAO
	var celulas_energia_inseridas: int = 0
	
	var contagem_por_minuto: Array[Dictionary] = []
	var minuto_atual: int = 1
	var criaturas_no_minuto: int = 0
	var acumulador_spawn: float = 0.0

	while tempo_decorrido < DURACAO_TOTAL_SEGUNDOS:
		tempo_decorrido += INTERVALO_SIMULACAO_DELTA
		
		# 1. Calculo de geracao progressiva de criaturas
		var taxa_spawn: float = calcular_taxa_spawn(tempo_decorrido)
		acumulador_spawn += taxa_spawn * INTERVALO_SIMULACAO_DELTA
		
		while acumulador_spawn >= 1.0:
			acumulador_spawn -= 1.0
			# Regra de design: criacao respeita o teto fisico da estacao
			if criaturas_ativas < LIMITE_MAXIMO_CRIATURAS:
				criaturas_ativas += 1
				total_criaturas_geradas += 1
				criaturas_no_minuto += 1
		
		# 2. Mecanica de neutralizacao, portas de seguranca e dispersao
		# Conforme a densidade aumenta, o jogador fecha comportas ou aciona pulsos defensivos.
		# A frequencia de evasao/neutralizacao sobe quando a populacao esta alta
		var intervalo_neutralizacao: int = 12 if criaturas_ativas > 8 else 18
		if int(tempo_decorrido) % intervalo_neutralizacao == 0 and criaturas_ativas > 0:
			criaturas_ativas -= 1
			criaturas_eliminadas_ou_dispersas += 1
		
		# 3. Consumo de energia da estacao
		energia_estacao -= CONSUMO_ENERGIA_POR_SEGUNDO * INTERVALO_SIMULACAO_DELTA
		
		# Insercao de celulas coletadas pelo jogador
		if energia_estacao <= 30.0:
			energia_estacao = minf(energia_estacao + ENERGIA_POR_CELULA_COLETADA, 100.0)
			celulas_energia_inseridas += 1
		
		# Registro estatistico a cada 60 segundos
		if int(tempo_decorrido) % 60 == 0:
			var resumo_minuto: Dictionary = {
				"minuto": minuto_atual,
				"tempo_s": int(tempo_decorrido),
				"taxa_spawn_final": taxa_spawn,
				"novas_criaturas": criaturas_no_minuto,
				"criaturas_vivas_fim": criaturas_ativas,
				"energia_restante": energia_estacao
			}
			contagem_por_minuto.append(resumo_minuto)
			print("Minuto %d (%ds): Taxa=%.3f/s | Novas=%d | Vivas=%d | Energia=%.1f%%" % [
				minuto_atual,
				int(tempo_decorrido),
				taxa_spawn,
				criaturas_no_minuto,
				criaturas_ativas,
				energia_estacao
			])
			minuto_atual += 1
			criaturas_no_minuto = 0

	# Assercoes de consistencia de Game Design
	assert(contagem_por_minuto.size() == 5, "A simulacao deve registrar exatamente 5 minutos de jogo.")
	
	var m1: Dictionary = contagem_por_minuto[0]
	var m5: Dictionary = contagem_por_minuto[4]
	
	# No minuto 1 (onboarding), o ritmo deve ser brando
	assert(m1["novas_criaturas"] <= 6, "Minuto 1 deve ter no maximo 6 criaturas para permitir aprendizado dos controles.")
	
	# No minuto 5 (climax), deve manter atividade constante
	assert(m5["novas_criaturas"] >= 5, "Minuto 5 deve manter geracao constante conforme o teto permitir.")
	
	# O teto de criaturas ativas nao pode violar o limite do motor
	assert(m5["criaturas_vivas_fim"] <= LIMITE_MAXIMO_CRIATURAS, "Populacao ativa de ameacas nao pode exceder o teto seguro de 16.")
	
	# A sobrevivencia energetica deve exigir interacao ativa com celulas
	assert(celulas_energia_inseridas >= 3, "O jogador deve precisar inserir pelo menos 3 celulas para manter os sistemas ativos.")
	assert(energia_estacao > 0.0, "A estacao deve manter sistemas minimos operacionais se o jogador abastecer as celulas.")
	
	print("Estatisticas finais: Total gerado=%d | Dispersas/Abatidas=%d | Celulas usadas=%d" % [
		total_criaturas_geradas,
		criaturas_eliminadas_ou_dispersas,
		celulas_energia_inseridas
	])
	return true
