class_name InimigoConfig
extends Resource

## Nome de exibicao e identificacao da categoria do inimigo.
@export var nome: String = "Inimigo Padrao"

## Pontos de vida maximos da entidade.
@export var vida_maxima: int = 50

## Velocidade de deslocamento na arena em pixels por segundo.
@export var velocidade: float = 120.0

## Dano causado ao jogador ao entrar em colisao.
@export var dano_contato: int = 15

## Cor de modulacao visual para diferenciar tipos de inimigos.
@export var cor_modulacao: Color = Color(1.0, 0.4, 0.4, 1.0)
