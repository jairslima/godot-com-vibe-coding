# ARQUIVO:
# res://cenarios_bugs/caso3_sinal_desconectado.gd
#
# ANEXAR AO NODE:
# CasoSinalDesconectado (Node)
#
# CENA:
# res://cenarios_bugs/cenario_bugs.tscn
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# Nenhum
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Demonstrar erro de conexao com sinal inexistente e resolucao com sinais tipados.

extends Node
class_name CasoSinalDesconectado

signal vida_atualizada(nova_vida: int)

var sinal_foi_ouvido: bool = false

func _on_vida_atualizada(nova_vida: int) -> void:
	sinal_foi_ouvido = true
	print("[Caso 3 - Sinais] Callback executado com sucesso! Nova vida: ", nova_vida)

## Funcao que reproduz tentativa de conectar sinal inexistente.
func reproduzir_bug() -> void:
	# Dispara: ERROR: In Object of type 'Node': Attempt to connect nonexistent signal 'sinal_fantasma'
	connect("sinal_fantasma", Callable(self, "_on_vida_atualizada"))

## Funcao com a solucao tipada e conexao verificada.
func executar_solucao() -> bool:
	sinal_foi_ouvido = false
	if not vida_atualizada.is_connected(_on_vida_atualizada):
		vida_atualizada.connect(_on_vida_atualizada)
	
	vida_atualizada.emit(100)
	
	assert(sinal_foi_ouvido, "O sinal deveria ter sido recebido pelo receptor!")
	print("[Caso 3 - Sinais] Conexao tipada e emissao validadas com sucesso.")
	return sinal_foi_ouvido
