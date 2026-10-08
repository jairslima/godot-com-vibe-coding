# Registro de Procedência e Declaração de Inteligência Artificial

Projeto: Estação Sobrevivência by Jair Lima
Engine: Godot 4.7.2 Stable
Data de Auditoria: 2026-10-07

O inventário fictício usado para demonstrar o auditor do Capítulo 48 está em `tests/fixtures/PROVENANCE_exemplo.md`. Este arquivo descreve o que o projeto realmente contém.

---

## 1. Sumário de Classificação para Lojas Digitais

* Uso de Ferramentas de IA: Sim, como ferramenta de desenvolvimento (escrita e revisão de código)
* Conteúdo Pré-gerado (Pre-Generated): Não (nenhum arquivo de arte, som, música, narrativa ou localização gerado por IA)
* Conteúdo Gerado ao Vivo (Live-Generated): Não (o jogo roda de forma determinística e offline)
* Restrições de Conteúdo Adulto: Não aplicável
* Política de Privacidade: este projeto de demonstração não coleta dados; antes de publicar um jogo real, publique a sua política e informe o endereço real na loja

---

## 2. Inventário de Procedência de Ativos e Código

| Identificador do Ativo | Tipo de Recurso | Categoria de IA | Ferramenta / Modelo | Parâmetros / Prompt de Origem | Intervenção Humana Realizada | Termos de Licença / Uso | Status de Conformidade |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `icon.svg` | Imagem / Ícone | Humano Assistido | Código SVG escrito com auxílio de IA | Quadrado arredondado com formas básicas | Revisão de cores e formas | MIT | APROVADO |
| `src/**/*.gd` | Código GDScript | Híbrido Assistido | Agentes de IA de codificação | Arquitetura e regras descritas em tarefas | Revisão de tipagem, sinais e testes headless | Autoria Humana / MIT | APROVADO |

---

## 3. Diretrizes de Guardrails e Segurança Operacional

Para qualquer componente futuro que venha a incorporar geração ao vivo (Live-Generated):
1. Filtragem estrita de vocabulário e comandos em camada de backend próprio.
2. Limitação de taxa de requisições por segundo e por sessão de jogador.
3. Fallback determinístico offline automático em caso de falha de conexão ou resposta irregular.
4. Anonimização estrita de identificadores de jogador (minimização de dados LGPD/GDPR).
5. Disponibilização de mecanismo de reporte de conteúdo ofensivo via interface de usuário.
