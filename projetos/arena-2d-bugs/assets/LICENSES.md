# Registro de Licencas de Ativos (Asset Ledger)

Projeto: Arena 2D by Jair Lima
Versao: 1.0.0
Motor: Godot Engine 4.7.2 Stable (Windows 11)

## 1. Ativos Graficos

* Arquivo: `res://icon.svg`
  * Origem: SVG geometrico simples, escrito como codigo (quadrado arredondado com formas básicas), criado para o livro
  * Autor: Jair Lima, com auxílio de IA para escrever o codigo do SVG
  * Licenca: MIT License (2026)
  * Observacao: nao é o logotipo do Godot Engine nem derivado dele.
  * Uso no projeto: ícone do projeto de exercícios.

## 2. Ativos de Audio

* Gerador Procedural: `res://gerador_audio.gd`
  * Origem: Sintetizador de ondas PCM em tempo de execucao escrito em GDScript nativo.
  * Autor: Jair Lima
  * Licenca: MIT License (2026)
  * Descricao: Gera bipes de impacto (hit) e melodias de derrota (game over) diretamente na memoria RAM usando a classe nativa `AudioStreamWAV`, sem dependencia de arquivos de audio proprietarios externos.
