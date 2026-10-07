# Godot com Vibe Coding: projetos complementares

Código-fonte dos projetos do livro **Godot com Vibe Coding: Crie Jogos com Inteligência Artificial, Agentes e GDScript**, de **Jair Lima** (Lima Editora do Brasil, 1ª edição, 2026). O livro sai em volume único (edição digital) e em Volume 1, Volume 2 e Volume 3 (edição impressa).

Tudo foi escrito e testado com o **Godot 4.7.2 Stable** (lançado em 18 de agosto de 2026), no Windows 11, em GDScript. Versão base verificada em 7 de outubro de 2026. Não use o Godot 4.8 em desenvolvimento nem o Godot 3: o código usa APIs do Godot 4.

## Como usar

1. Instale o Godot 4.7.2 Standard (não a versão .NET): https://godotengine.org/download/archive/
2. Clone este repositório e abra a pasta do projeto desejado no Project Manager do Godot, por exemplo `projetos/arena-2d`.
3. Para conferir que o projeto abre sem erros, no terminal:

```bash
godot --headless --path projetos/arena-2d --import --quit-after 30
```

A saída não deve ter linhas com `ERROR`. Alguns projetos trazem scripts de validação (`validate.ps1` e `validate.sh`) e suítes de teste em `tools/` ou `tests/`.

## Projetos

| Pasta | Onde aparece no livro | O que é |
|---|---|---|
| `projetos/hello-godot` | Cap. 4 | primeiro projeto, para conferir a instalação |
| `projetos/gdscript-lab` | Cap. 6 e Apêndice B | exemplos de GDScript do livro |
| `projetos/arena-2d` | Caps. 8 a 12 | Projeto 1: Arena 2D (chatbot + vibe coding) |
| `projetos/arena-2d-bugs` | Cap. 13 | erros reais de GDScript para exercitar debugging |
| `projetos/alucinacoes-lab` | Cap. 14 | exemplos de "quando a IA inventa Godot" |
| `projetos/platformer-2d` | Caps. 16 a 22 e 28 a 30 | Projeto 2: Plataforma 2D (agente de repositório) |
| `projetos/git-advanced-lab` | Cap. 29 | laboratório de Git avançado e Git LFS (arquivos binários são marcadores) |
| `projetos/mcp-lab` | Cap. 26 | laboratório de MCP e Godot (sem o addon de terceiros, ver abaixo) |
| `projetos/security-lab` | Cap. 31 | auditoria de diff, segredos e permissões |
| `projetos/station-3d` | Caps. 32 a 36 | Projeto 3: Estação 3D |
| `projetos/ai-backend-lab` | Caps. 38 a 41 | cliente Godot e servidor de teste para IA dentro do jogo (sem chave real) |
| `projetos/estacao-sobrevivencia` | Caps. 42 a 48 | projeto final: da frase ao jogo publicado |

## Checkpoints (tags)

Cada checkpoint citado no livro é uma tag Git. Liste todas com `git tag`. Ao fazer `git checkout <tag>`, aparece apenas o projeto daquele checkpoint, na pasta `projetos/<nome>`.

* **Arena 2D:** `arena-00-bootstrap`, `arena-01-player`, `arena-02-enemy`, `arena-03-spawner`, `arena-04-health`, `arena-05-ui`, `arena-06-game-over`, `arena-07-polish`, `arena-08-release`. Um commit por checkpoint; os nove foram abertos em um clone limpo, sem erros, no Godot 4.7.2.
* **Plataforma 2D:** `platformer-00-bootstrap` a `platformer-09-ui-pause`.
* **Estação 3D:** `station3d-00-bootstrap`, `station3d-02-interaction`, `station3d-04-objectives` a `station3d-08-audio-lighting`.

O livro cita alguns checkpoints que não existem como tag (por exemplo `platformer-10-refactor`, `platformer-11-release` e `station3d-01-player-camera`): são pontos que você mesmo cria ao acompanhar o texto. O estado final de cada projeto está na branch `main`.

Para voltar ao estado final: `git checkout main`.

## Limites e avisos

* **Addon de terceiros:** o `mcp-lab` usou um addon comunitário de MCP para Godot cuja origem e licença não foram confirmadas. Ele **não** está neste repositório. O teste do laboratório não depende dele. Procure addons de MCP na Asset Library oficial e leia a licença de cada um.
* **Git LFS:** em `projetos/git-advanced-lab` os arquivos `.wav` e `.glb` são marcadores de texto, e as regras de LFS do `.gitattributes` estão desativadas, só para ilustrar o capítulo.
* **Erros propositais:** `projetos/alucinacoes-lab/casos_errados/` contém scripts com erros de propósito (o Capítulo 14 mostra a mensagem real do Godot para cada um), então `--check-only` neles deve falhar. Os testes de persistência do `platformer-2d` também imprimem linhas `ERROR` de propósito, ao simular saves corrompidos; o resultado final é "TODAS AS VERIFICACOES PASSARAM".
* **Documentos de exemplo:** `projetos/estacao-sobrevivencia/assets/LICENSES.md` e `docs/PROVENANCE.md` trazem uma tabela **fictícia**, usada para demonstrar o auditor do Capítulo 48 e os seus testes. Há um aviso no topo de cada um. O projeto não tem assets de terceiros nem gerados por IA.
* **Ícones:** os `icon.svg` são SVGs geométricos simples escritos como código para o livro. Não são o logotipo do Godot.
* **Exportação:** as pastas `build/` não são versionadas. Para gerar executáveis, instale os export templates 4.7.2 (Editor, Manage Export Templates) e siga o Capítulo 46.
* **Chaves de API:** nenhum projeto contém chave real. O servidor do `ai-backend-lab` é um simulador local, com tokens de mentira. Nunca coloque chaves em repositórios nem no jogo distribuído.
* **Assets:** os sons e as imagens são gerados por código ou criados para o livro; veja `assets/LICENSES.md` nos projetos que o possuem.

## Licença

Código sob licença MIT (arquivo `LICENSE`). O texto do livro não faz parte deste repositório e segue os direitos reservados da obra. O Godot Engine é distribuído sob licença MIT pela Godot Foundation.

## Contato

Jair Lima (jairslima@gmail.com): https://linktr.ee/Jairslima
