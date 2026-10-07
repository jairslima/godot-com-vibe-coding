# Registro de Procedência e Declaração de Inteligência Artificial

> **AVISO: ESTE DOCUMENTO É UM EXEMPLO DIDÁTICO.** A tabela abaixo é fictícia e existe para demonstrar o auditor de conformidade do Capítulo 48 do livro (`src/core/compliance_manager.gd`) e os seus testes. Os arquivos, as ferramentas, os autores e as licenças citados NÃO correspondem a assets reais deste repositório.
>
> **Realidade deste repositório:** não há imagens, sons, músicas nem modelos 3D gerados por IA nem de terceiros. O único arquivo gráfico é o `icon.svg`, um SVG geométrico simples escrito como código para o livro (Jair Lima, MIT; não é o logotipo do Godot). O código GDScript foi escrito com auxílio de agentes de IA, revisado por Jair Lima e validado com o Godot 4.7.2. Para o seu jogo, substitua a tabela pelos seus assets reais.

Projeto: Estação Sobrevivência by Jair Lima
Versão do Jogo: 1.0.0-release
Engine: Godot 4.7.2 Stable
Data de Auditoria: 2026-10-06

---

## 1. Sumário de Classificação para Lojas Digitais

* Uso de Ferramentas de IA: Sim
* Conteúdo Pré-gerado (Pre-Generated): Sim (conceitos visuais de referência e protótipos de texturas)
* Conteúdo Gerado ao Vivo (Live-Generated): Não (o jogo roda de forma 100% determinística offline sem modelos em tempo real)
* Restrições de Conteúdo Adulto: Não aplicável (jogo livre de conteúdo adulto)
* Política de Privacidade Configurada: https://estacaosobrevivencia.exemplo.com.br/privacidade

---

## 2. Inventário de Procedência de Ativos e Código

| Identificador do Ativo | Tipo de Recurso | Categoria de IA | Ferramenta / Modelo | Parâmetros / Prompt de Origem | Intervenção Humana Realizada | Termos de Licença / Uso | Status de Conformidade |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `icon.svg` | Imagem / Ícone | Humano Puro | Inkscape 1.3 | Desenho vetorial manual | Vetorização, paleta e exportação manual | Licença MIT do Projeto | APROVADO |
| `src/core/game_manager.gd` | Código GDScript | Híbrido Assistido | Claude Code / Sonnet | Arquitetura de ciclo de partida | Revisão de tipagem, sinais e testes headless | Autoria Humana / MIT | APROVADO |
| `src/core/spawner_progressivo.gd` | Código GDScript | Híbrido Assistido | Codex CLI | Algoritmo de taxas de spawn exponencial | Calibração de limites matemáticos e asserções | Autoria Humana / MIT | APROVADO |
| `src/entities/player/player.gd` | Código GDScript | Híbrido Assistido | Assistente de Código | Movimentação CharacterBody3D | Ajuste de mouse look, inércia e colisões | Autoria Humana / MIT | APROVADO |
| `src/entities/creature/creature.gd` | Código GDScript | Híbrido Assistido | Assistente de Código | Perseguição vetorial 3D | Ajuste de velocidade, dano e temporizador | Autoria Humana / MIT | APROVADO |
| `assets/sprites/concept_creature.png` | Arte Conceitual | Pré-gerado (Pre-Generated) | Modelo Generativo de Imagem | "Sci-fi alien quad predator concept sheet" | Seleção de silhueta, recorte e pintura manual | Termos Comerciais Pagos | APROVADO |
| `assets/audio/sfx_hit.wav` | Efeito Sonoro | Pré-gerado (Pre-Generated) | Sintetizador Neural de Áudio | "Mechanical impact metallic thud low frequency" | Equalização, corte de início e normalização PCM | Licença Comercial Vitalícia | APROVADO |
| `assets/LICENSES.md` | Documentação | Humano Puro | Editor de Texto | Estruturação de conformidade legal | Redação integral e checagem de fontes | Domínio Público / CC0 | APROVADO |

---

## 3. Diretrizes de Guardrails e Segurança Operacional

Para qualquer componente futuro que venha a incorporar geração ao vivo (Live-Generated):
1. Filtragem estrita de vocabulário e comandos em camada de backend próprio.
2. Limitação de taxa de requisições por segundo e por sessão de jogador.
3. Fallback determinístico offline automático em caso de falha de conexão ou resposta irregular.
4. Anonimização estrita de identificadores de jogador (minimização de dados LGPD/GDPR).
5. Disponibilização de mecanismo de reporte de conteúdo ofensivo via interface de usuário.
