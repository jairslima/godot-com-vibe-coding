# Registro de Procedência de Assets (Asset Ledger)

> **ARQUIVO DE EXEMPLO FICTÍCIO (fixture de teste).** Esta tabela existe para demonstrar o auditor do Capítulo 44 (`src/core/license_manager.gd`) e alimentar os seus testes. Os arquivos, as ferramentas, os autores e as licenças citados NÃO existem neste repositório e NÃO descrevem o projeto. O registro verdadeiro do projeto está em `assets/LICENSES.md`.

Este documento registra a proveniência, licenciamento, autoria e intervenções humanas de todos os recursos externos e gerados por inteligência artificial utilizados no projeto **Estação Sobrevivência**.

## Metadados do Projeto
* **Projeto:** Estação Sobrevivência by Jair Lima
* **Versão da Engine:** Godot 4.7.2 Stable
* **Data da Última Auditoria:** 2026-10-06
* **Responsável pela Curadoria:** Jair Lima

---

## Tabela de Procedência de Assets

| Identificador do Arquivo | Categoria | Origem / Ferramenta | Autor / Provedor | Licença / Termos de Uso | Parâmetros / Prompt Utilizado | Transformação Humana Realizada | Status Comercial |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `res://icon.svg` | Ícone | Godot Engine | Juan Linietsky, Ariel Manzur | CC-BY 4.0 | N/A (logo oficial da engine) | Nenhuma (ícone de modelo) | Aprovado |
| `res://assets/textures/chao_metalico_albedo.png` | Textura | Stable Diffusion (geração local) | Jair Lima (operador) | Termos de Uso Local (Pesos OpenRAIL) | "seamless modular sci-fi metal floor plating, dark gray industrial panels, scratches, top-down view, 8k texture" | Delighting manual no GIMP, remoção de sombras pré-assadas e empacotamento em canal | Aprovado |
| `res://assets/textures/chao_metalico_normal.png` | Textura | Gerador de Normal Map (Filtro local) | Jair Lima | Domínio Público / Criação Própria | N/A (calculado a partir do mapa de albedo corrigido) | Ajuste de intensidade e inversão de canal Y no GIMP para padrão DirectX/OpenGL do Godot | Aprovado |
| `res://assets/models/criatura_sombra.glb` | Modelo 3D | Tripo3D (exportação glTF) | Jair Lima (operador) | Licença Comercial de Assinatura | "bipedal dark alien shadow creature, jagged limbs, glowing white visor face, sci-fi horror" | Retopologia manual no Blender (redução de 140k para 3.8k triângulos), realinhamento de pivô e criação de UV unwrap limpo | Aprovado |
| `res://assets/audio/alarme_estacao.wav` | Efeito Sonoro | ElevenLabs Sound Effects | Jair Lima (operador) | Licença Comercial Pro | "loud pulsing sci-fi station evacuation alarm horn, reverberant metallic room" | Corte de ruído residual, normalização em -3.0 dB e exportação PCM 16-bit 44.1 kHz no Audacity | Aprovado |
| `res://assets/audio/passo_metal.wav` | Efeito Sonoro | Freesound.org | InspectorJ | Creative Commons 0 (CC0 1.0) | N/A (gravação real de bota sobre chapa de aço) | Edição de transiente inicial e equalização passa-alta em 80 Hz | Aprovado |
| `res://assets/audio/trilha_suspense.ogg` | Música | Suno (geração instrumental) | Jair Lima (operador) | Licença Comercial Premier | "minimalist dark ambient drone, pulsating sub-bass, metallic tension, eerie space station soundtrack" | Edição de loop contínuo perfeitamente alinhado em zero-crossing no Audacity, masterização em -14 LUFS | Aprovado |
| `res://assets/fonts/inter_medium.ttf` | Fonte | Rasmus Andersson | Rasmus Andersson | SIL Open Font License 1.1 | N/A (família tipográfica de código aberto) | Nenhuma (arquivo binário original mantido com aviso de copyright OFL) | Aprovado |

---

## Termos e Declarações para Lojas (Steamworks Content Survey)

1. **Uso de IA Pré-Gerada (Pre-Generated AI):**
   * Os recursos visuais e sonoros gerados por ferramentas de inteligência artificial foram criados exclusivamente durante o processo de desenvolvimento e empacotados como arquivos estáticos finais.
   * Todos os modelos e texturas passaram por transformação, inspeção e retopologia humana prévia.
   * Nenhuma das criações reproduz marcas registradas de terceiros, identidades de pessoas reais nem material protegido por direitos autorais alheios.

2. **Uso de IA em Tempo de Execução (Live-Generated AI):**
   * O projeto não emprega modelos de linguagem nem geradores generativos em tempo real na versão padrão de distribuição.
