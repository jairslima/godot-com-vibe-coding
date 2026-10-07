# Game Design Document: Estação Sobrevivência by Jair Lima

## 1. Identidade e Premissa
* **Título Oficial:** Estação Sobrevivência by Jair Lima
* **Gênero:** Suspense de Sobrevivência em Primeira Pessoa (Sci-Fi Survival Horror)
* **Plataforma:** PC Desktop (Windows / Linux)
* **Engine:** Godot 4.7.2 Stable
* **Premissa:** O jogador precisa sobreviver a trezentos segundos (cinco minutos) em uma estação espacial abandonada enquanto criaturas aparecem progressivamente.

## 2. Pilares de Design
1. **Tensão Espacial:** Confinamento e constante senso de perseguição no ambiente tridimensional.
2. **Pressão Temporal:** Cronômetro contínuo de cinco minutos com escalada visível de ameaças.
3. **Loop Mínimo Fechado:** Movimentação, esquiva, sobrevivência e resolução clara de vitória ou derrota.

## 3. Escopo do MVP (Mínimo Produto Viável)
O objetivo do MVP é responder à pergunta: a perseguição e a escalada de tensão ao longo de cinco minutos proporcionam uma experiência engajante e desafiadora?
* Entra no MVP:
  - Controlador do jogador em primeira pessoa com movimentação fluida.
  - Criatura com inteligência artificial básica de perseguição direta.
  - Spawner progressivo que aumenta a frequência e quantidade de criaturas ao longo dos trezentos segundos.
  - Temporizador de 300 segundos com detecção automática de vitória.
  - Detecção de contato com criatura resultando em derrota imediata.
  - HUD minimalista exibindo cronômetro regressivo e mensagens de fim de jogo.
* Fora do MVP (iterações posteriores):
  - Coleta de baterias e consoles de energia.
  - Portas operáveis e trancas eletromecânicas.
  - Efeitos sonoros complexos e sintetizador de passos.
  - Armas de fogo e inventário.
