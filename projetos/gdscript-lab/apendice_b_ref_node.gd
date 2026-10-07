# ARQUIVO:
# res://apendice_b_ref_node.gd
#
# ANEXAR AO NODE:
# Nenhum (classe de referência, herda de CharacterBody2D)
#
# CENA:
# Nenhuma (validação estática via --check-only)
#
# INPUTS NECESSÁRIOS:
# move_left, move_right, move_up, move_down, sprint
#
# DEPENDÊNCIAS:
# Nenhuma
#
# VERSÃO TESTADA:
# Godot 4.7.2 Stable (Windows 11)
#
# RESULTADO ESPERADO:
# Passa na validação estática (godot --check-only) sem erros de parse.
# Consolida os trechos de anotação, acesso a nós, ciclo de vida e movimento do Apêndice B.

class_name ApendiceBRefNode
extends CharacterBody2D

var velocidade: float = 300.0
var direcao: Vector2 = Vector2.ZERO

# --- Anotação @export e variantes ---
@export var velocidade_movimento: float = 300.0
@export var altura_salto: float = -420.0
@export var cena_projetil: PackedScene
@export_range(10, 100, 5) var valor_limitado: int = 50
@export_file("*.tscn") var arquivo_cena: String = ""
@export_multiline var descricao: String = ""

# --- Acesso a nós com @onready, $ e % ---
@onready var visual_sprite: Sprite2D = $Sprite2D
@onready var barra_progresso: ProgressBar = %VidaBarra

# --- Ciclo de vida ---
func _ready() -> void:
	print("Nó pronto na Scene Tree")
	if barra_progresso != null:
		barra_progresso.value = 100

func _process(delta: float) -> void:
	position.x += velocidade * delta

func _physics_process(delta: float) -> void:
	direcao = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direcao * velocidade
	move_and_slide()

# --- Leitura de entrada ---
func ler_sprint() -> void:
	if Input.is_action_pressed("sprint"):
		velocidade = velocidade_movimento * 1.6

# --- Acesso defensivo a nós ---
func acessar_nos() -> void:
	var animador: Node = get_node("AnimationPlayer")
	var audio: Node = get_node_or_null("AudioStreamPlayer2D")
	if audio != null:
		print("Audio presente")
	var colisor: Node = $CollisionShape2D
	var status: Label = %StatusRotulo
	print(animador, colisor, status)

# --- Instanciação e descarte ---
const CENA_INIMIGO := preload("res://inimigo.gd")

func instanciar() -> void:
	var inimigo_script: GDScript = CENA_INIMIGO
	print(inimigo_script)

func exemplo_fila() -> void:
	queue_free()

# --- Temporizador assíncrono ---
func exemplo_async() -> void:
	await get_tree().create_timer(0.2).timeout
	print("Aguardou 0,2 segundos")

# --- Recarregar a cena atual ---
func reiniciar_cena() -> void:
	get_tree().reload_current_scene()
