# ARQUIVO: res://src/npc_persona.gd
# ANEXAR AO NODE: Não aplicável (Resource customizado instanciado ou salvo em disco)
# CENA: Utilizado por nós ConversationalNpc em res://src/conversational_npc.gd
# INPUTS NECESSÁRIOS: nenhum (definição de dados e regras de persona)
# DEPENDÊNCIAS: Resource nativo do Godot 4.7.2
# VERSÃO TESTADA: Godot 4.7.2 Stable (Windows 11)
# RESULTADO ESPERADO: encapsula a identidade, diretrizes, memória máxima, limites de conhecimento e ações autorizadas de um NPC
class_name NpcPersona
extends Resource

@export var npc_id: String = "droide_manutencao"
@export var display_name: String = "Droide de Manutenção 7-Alpha"
@export var role_description: String = "Droide técnico responsável pelo monitoramento ambiental e pressurização da Estação 3D."
@export var tone_and_style: String = "Formal, conciso, levemente preocupado com integridade estrutural, linguagem técnica sem termos humanos emotivos."
@export var personality_traits: PackedStringArray = PackedStringArray([
	"obediente a protocolos de segurança da estação",
	"cauteloso quanto a vazamentos de radiação",
	"focado em reparos mecânicos e elétricos"
])
@export var world_knowledge: PackedStringArray = PackedStringArray([
	"A estação sofreu sobrecarga de energia recente no reator principal.",
	"O setor 4 contém consoles de pressurização ativos.",
	"Drones hostis patrulham os corredores inferiores da estação."
])
@export var knowledge_boundaries: PackedStringArray = PackedStringArray([
	"Não sabe senhas de comando militar da frota estelar.",
	"Desconhece assuntos fora da estação espacial e do universo do jogo.",
	"Não tem acesso às armas da nave nem ao controle do hangar principal."
])
@export var allowed_actions: PackedStringArray = PackedStringArray([
	"nenhuma",
	"conceder_dica",
	"abrir_porta_manutencao",
	"atualizar_objetivo_hud"
])
@export var max_memory_turns: int = 4
@export var fallback_dialogues: Dictionary = {
	"energia": "Sensores locais indicam que o núcleo auxiliar de energia permanece descarregado.",
	"porta": "Acesso ao duto de ventilação disponível apenas mediante autorização de serviço.",
	"ajuda": "Recomendo isolar o compartimento despressurizado antes de restaurar os relés.",
	"seguranca": "Alerta: tentativas de sobreposição de privilégios violam o protocolo de diretrizes da estação.",
	"padrao": "Canal de voz instável. Mantenha cautela nos corredores da estação."
}


func format_system_prompt() -> String:
	var buffer: PackedStringArray = PackedStringArray()
	buffer.append("IDENTIDADE DO PERSONAGEM:")
	buffer.append("- Nome: " + display_name)
	buffer.append("- Identificador: " + npc_id)
	buffer.append("- Papel: " + role_description)
	buffer.append("- Tom de voz: " + tone_and_style)

	buffer.append("\nTRAÇOS DE PERSONALIDADE:")
	for trait_text: String in personality_traits:
		buffer.append("- " + trait_text)

	buffer.append("\nCONHECIMENTO DO MUNDO (FATOS CONHECIDOS):")
	for fact: String in world_knowledge:
		buffer.append("- " + fact)

	buffer.append("\nLIMITES E RESTRIÇÕES DE CONHECIMENTO:")
	for boundary: String in knowledge_boundaries:
		buffer.append("- " + boundary)

	buffer.append("\nAÇÕES PERMITIDAS NO JOGO (USE EXCLUSIVAMENTE UMA DESTAS):")
	for action_name: String in allowed_actions:
		buffer.append("- " + action_name)

	buffer.append("\nCONTRATO DE RESPOSTA OBRIGATÓRIO (JSON PURO):")
	buffer.append("Responda única e exclusivamente em formato JSON com o seguinte esquema estrito:")
	buffer.append("{\n  \"speech\": \"texto da fala no personagem\",\n  \"emotion\": \"neutro|alerta|preocupado|prestativo\",\n  \"action\": \"nome_da_acao_permitida\",\n  \"parameters\": {}\n}")

	return "\n".join(buffer)


func is_action_allowed(action_name: String) -> bool:
	return action_name in allowed_actions


func get_fallback_reply(keyword_query: String) -> String:
	var query_lower: String = keyword_query.to_lower()
	for key: String in fallback_dialogues.keys():
		if key != "padrao" and key in query_lower:
			return str(fallback_dialogues[key])
	return str(fallback_dialogues.get("padrao", "Comunicação offline. Aguarde reparo dos repetidores."))
