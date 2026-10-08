# Registro de Procedência de Assets (Asset Ledger)

Este documento registra a procedência, a licença, a autoria e a intervenção humana dos recursos do projeto **Estação Sobrevivência**.

## Metadados do Projeto

* **Projeto:** Estação Sobrevivência by Jair Lima
* **Versão da Engine:** Godot 4.7.2 Stable
* **Data da Última Auditoria:** 2026-10-07
* **Responsável pela Curadoria:** Jair Lima

---

## Tabela de Procedência de Assets

Este projeto não usa assets externos e não contém imagens, sons, músicas nem modelos 3D gerados por IA. Todo o visual do jogo é geometria criada por código. O inventário completo e fictício usado para demonstrar o auditor do Capítulo 44 está em `tests/fixtures/LICENSES_exemplo.md`.

| Identificador do Arquivo | Categoria | Origem / Ferramenta | Autor / Provedor | Licença / Termos de Uso | Parâmetros / Prompt Utilizado | Transformação Humana Realizada | Status Comercial |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `res://icon.svg` | Ícone | SVG geométrico simples escrito como código para o livro | Jair Lima, com auxílio de IA para escrever o código do SVG | MIT License (2026) | N/A (não é o logotipo do Godot) | Revisão e ajuste de cores e formas | Aprovado |
| `res://src/**/*.gd` | Código GDScript | Agentes de IA (assistência de escrita) | Jair Lima (orquestração e revisão) | MIT License (2026) | N/A | Revisão de tipagem, sinais e testes headless no Godot 4.7.2 | Aprovado |

---

## Termos e Declarações para Lojas (Steamworks Content Survey)

1. **Conteúdo pré-gerado por IA que acompanha o jogo:** nenhum. O projeto não contém arquivos de arte, som, música, narrativa ou localização gerados por IA.
2. **Conteúdo gerado por IA durante a execução (Live-Generated):** nenhum. O jogo roda de forma determinística e offline.
3. **Uso de IA como ferramenta de desenvolvimento:** sim, na escrita e na revisão do código, com testes e revisão humana. A documentação do Steamworks informa que ganhos de eficiência com ferramentas de IA no desenvolvimento não são o foco do formulário; confirme a orientação vigente da loja antes de enviar.
