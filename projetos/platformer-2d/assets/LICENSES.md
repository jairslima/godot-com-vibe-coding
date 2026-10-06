# Registro de Licenças de Ativos (Asset Ledger)

Projeto: Plataforma 2D by Jair Lima
Versão: 1.0.0
Motor: Godot Engine 4.7.2 Stable (Windows 11)

## 1. Ativos Gráficos

* Arquivo: `res://icon.svg`
  * Origem: Logotipo oficial do Godot Engine
  * Autor: Andrea Calabro / Contribuidores do Godot Engine
  * Licença: Creative Commons Attribution 4.0 International (CC BY 4.0)
  * Uso no projeto: Textura base para os sprites do Jogador e Inimigo.

* Arquivo: `res://assets/sprites/tileset_atlas.png`
  * Origem: Gerador procedural em tempo de desenvolvimento (`tools/gerar_tileset.gd`)
  * Autor: Jair Lima
  * Licença: MIT License (2026)
  * Uso no projeto: Atlas de texturas para as camadas de terreno e fundo (TileSet/TileMapLayer).

## 2. Ativos de Áudio

* Sintetizador Procedural: `res://src/audio/sound_manager.gd`
  * Origem: Síntese de ondas de áudio PCM diretamente na memória RAM em tempo de execução via GDScript nativo.
  * Autor: Jair Lima
  * Licença: MIT License (2026)
  * Descrição: Gera proceduralmente efeitos sonoros de salto (tom ascendente), aterrissagem (impacto grave), impacto/dano (onda distorcida) e coleta de itens (arpejo) na classe nativa `AudioStreamWAV`, sem dependência de bibliotecas ou arquivos binários externos.
