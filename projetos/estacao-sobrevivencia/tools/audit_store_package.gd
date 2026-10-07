@tool
extends SceneTree

# Script utilitário para auditar pacote de distribuição para lojas digitais e manifestos SteamPipe
# Executado via CLI headless: godot --headless --path "projetos/estacao-sobrevivencia" -s res://tools/audit_store_package.gd

func _init() -> void:
	print("[STORE_AUDIT] Iniciando auditoria do pacote de distribuicao e manifestos de loja...")
	
	# 1. Validar existência dos manifestos SteamPipe
	var vdf_app: String = "res://tools/steam/app_build_480.vdf"
	var vdf_depot: String = "res://tools/steam/depot_build_481.vdf"
	assert(FileAccess.file_exists(vdf_app), "Manifesto app_build_480.vdf ausente no disco")
	assert(FileAccess.file_exists(vdf_depot), "Manifesto depot_build_481.vdf ausente no disco")
	print("[STORE_AUDIT] Manifestos VDF do SteamPipe localizados com sucesso.")
	
	# 2. Inspecionar conteúdo do manifesto para garantir branch não pública
	var f_vdf: FileAccess = FileAccess.open(vdf_app, FileAccess.READ)
	assert(f_vdf != null, "Falha ao ler manifesto app_build_480.vdf")
	var texto_vdf: String = f_vdf.get_as_text()
	f_vdf.close()
	
	assert(not texto_vdf.contains('"SetLive" "default"'), "ERRO CRITICO: O manifesto nao pode ter como alvo a branch publica 'default' por script!")
	assert(texto_vdf.contains('"SetLive" "internal_testing"'), "O manifesto deve ter como alvo um canal de teste interno ('internal_testing')")
	print("[STORE_AUDIT] Regra de branch de teste validada: SetLive aponta para canal interno.")
	
	# 3. Validar arquivos binários na pasta de build
	var dir_build: DirAccess = DirAccess.open("res://build")
	if dir_build == null:
		push_warning("[STORE_AUDIT] Pasta build/ nao encontrada diretamente via res://, verificando via sistema de arquivos...")
		var caminho_global_build: String = ProjectSettings.globalize_path("res://build")
		dir_build = DirAccess.open(caminho_global_build)
		
	assert(dir_build != null, "Pasta build/ ausente no projeto")
	
	var arquivos_na_build: PackedStringArray = dir_build.get_files()
	print("[STORE_AUDIT] Arquivos encontrados na pasta build: " + str(arquivos_na_build))
	
	# Garantir ausência de arquivos proibidos (segredos, temporários, código de teste)
	var arquivos_proibidos: Array[String] = [".env", ".env.local", "secrets.json", "private_key.pem", "id_rsa"]
	for arq in arquivos_na_build:
		for proibido in arquivos_proibidos:
			assert(not arq.to_lower().contains(proibido), "ARQUIVO PROIBIDO DETECTADO NA PASTA DE DISTRIBUICAO: " + arq)
		assert(not arq.ends_with(".tmp"), "Arquivo temporario detectado na pasta de distribuicao: " + arq)
	print("[STORE_AUDIT] Auditoria de segredos concluida: nenhum arquivo sensivel presente no pacote.")
	
	# 4. Validar arquivo de licenças de terceiros
	var caminho_licenses: String = "res://assets/LICENSES.md"
	assert(FileAccess.file_exists(caminho_licenses), "Arquivo assets/LICENSES.md obrigatorio para conformidade com lojas")
	print("[STORE_AUDIT] Arquivo assets/LICENSES.md confirmado para conformidade legal e de lojas.")
	
	print("[STORE_AUDIT] Sucesso: Pacote e manifestos de loja aprovados na auditoria.")
	quit(0)
