# PLANS.md - Planos de Execução do Projeto (ExecPlans)

Este arquivo documenta o histórico e o planejamento de tarefas complexas que envolvem múltiplos arquivos ou subsistemas no projeto Plataforma 2D.

---

## ExecPlan-01: Expansão do Sistema de Colecionáveis e Estatísticas de Fase

- **Status:** CONCLUÍDO
- **Data:** Outubro de 2026
- **Responsável:** Desenvolvedor humano e Agente de Terminal

### 1. Intenção e Objetivo
Criar o componente `Coin` desacoplado, integrá-lo à fase `Level01`, conectar o sinal de coleta à pontuação do jogo via `SaveManager` e criar uma suíte de testes headless para validação contínua.

### 2. Estado Atual e Dependências
- `Level01` possui plataformas sólidas e jogador funcional.
- `SaveManager` possui método `adicionar_pontos(qtd: int)`.
- HUD exibe pontuação quando recebe sinal atualizado.

### 3. Passos de Execução
- [x] Passo 1: Criar cena `src/components/coin.tscn` e script `src/components/coin.gd`.
- [x] Passo 2: Instanciar moedas sobre as plataformas de `src/levels/level_01.tscn`.
- [x] Passo 3: Implementar tratamento de coleta em `src/levels/level_01.gd` e emissão de sinais.
- [x] Passo 4: Criar cena e script de teste headless em `src/levels/test_coin_collection.tscn` e `.gd`.
- [x] Passo 5: Executar validação via terminal com `godot_console --headless`.

### 4. Critérios de Verificação e Evidências
- 5 testes automatizados aprovados sem erros.
- Fila de quadros estável por 30 quadros na cena `level_01.tscn`.
- Nenhuma dependência cíclica entre `Coin` e `Player`.

---

## ExecPlan-02: Template para Novas Tarefas Complexas

- **Status:** PENDENTE / RASCUNHO
- **Data:** [Data de Início]
- **Responsável:** [Agente / Humano]

### 1. Intenção e Objetivo
[Descreva com clareza o objetivo da feature ou refatoração.]

### 2. Estado Atual e Diagnóstico
[Quais arquivos existem hoje? Quais nós estão envolvidos?]

### 3. Passos Planejados
- [ ] Passo 1: [Ação atômica]
- [ ] Passo 2: [Ação atômica]
- [ ] Passo 3: [Criação ou atualização de teste headless]

### 4. Critérios de Verificação
- [Critério 1: comando de validação CLI]
- [Critério 2: asserção esperada]
