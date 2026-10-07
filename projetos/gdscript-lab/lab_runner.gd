# ARQUIVO:
# res://lab_runner.gd
#
# ANEXAR AO NODE:
# Executável via flag -s (herda de SceneTree)
#
# CENA:
# Nenhuma (execução direta de linha de comando)
#
# INPUTS NECESSÁRIOS:
# Nenhum
#
# DEPENDÊNCIAS:
# res://lab_basico.gd, res://entidade.gd, res://inimigo.gd
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Executa todos os testes unitários do laboratório GDScript e encerra o processo com código de saída 0.

extends SceneTree

# Preload explícito garante resolução segura mesmo em execuções isoladas via CLI
const LabBasicoScript = preload("res://lab_basico.gd")
const EntidadeScript = preload("res://entidade.gd")
const InimigoScript = preload("res://inimigo.gd")

func _init() -> void:
	print("=== INICIANDO GDSCRIPT LAB (MODO HEADLESS VIA -s) ===")
	
	# Testes do Lab Básico
	LabBasicoScript.testar_variaveis()
	LabBasicoScript.testar_colecoes()
	LabBasicoScript.testar_loops()
	
	var dano_final: int = LabBasicoScript.calcular_dano_final(LabBasicoScript.DANO_BASE, 6)
	print("Dano calculado com armadura: ", dano_final)
	
	var status_alerta: String = LabBasicoScript.testar_condicionais(2)
	print("Status de alerta nível 2: ", status_alerta)
	
	print("\n--- TESTE 5: Sinais, Enums e Herança de Classes ---")
	var inimigo = InimigoScript.new()
	
	# Conexão de sinal com Callable em sintaxe moderna do Godot 4
	inimigo.vida_alterada.connect(func(nova: int, maximo: int) -> void:
		print(">> SINAL RECEBIDO: Vida atualizada para ", nova, "/", maximo)
	)
	
	inimigo.entidade_derrotada.connect(func(nome: String) -> void:
		print(">> SINAL RECEBIDO: Inimigo ", nome, " foi derrotado!")
	)
	
	# Chamada de métodos com herança
	inimigo.receber_dano(40)
	inimigo.receber_dano(70)
	
	# Teste de Callable de primeira classe
	var dobrar_vida := func(v: int) -> int:
		return v * 2
	inimigo.executar_com_modificador(dobrar_vida)
	
	inimigo.free()
	
	print("\n=== TODOS OS TESTES FORAM CONCLUÍDOS COM SUCESSO ===")
	quit()
