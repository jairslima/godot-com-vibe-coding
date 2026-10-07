# CONTRATO OPERACIONAL DE SEGURANCA: Security Lab by Jair Lima

## 1. Niveis de Privilegio
- LEITURA: permitida para inspecao de arquivos e diagnostico.
- EDICAO: restrita exclusivamente ao diretorio `res://src/` e `res://tests/`.
- EXECUCAO: permitida apenas para validacao CLI do Godot 4.7.2 headless.
- REDE / SERVICOS: PROIBIDO acesso externo ou requisicoes de rede.
- PUBLICACAO: estritamente proibida a agentes. Exclusividade humana.

## 2. Segredos e Credenciais
- NUNCA declare constantes ou variaveis contendo chaves de API, senhas, tokens ou URLs de producao.
- NUNCA faca commit de arquivos `.env` ou credenciais locais.
- Qualquer parametro de autenticacao deve ser fornecido via variaveis de ambiente locais em desenvolvimento e verificado contra `.gitignore`.

## 3. Dependencias
- PROIBIDO adicionar plugins, addons, GDExtensions ou bibliotecas externas sem autorizacao previa por escrito.
- Utilize exclusivamente as APIs nativas do Godot 4.7.2 Stable.

## 4. Git e Rollback
- Proibido executar `git push --force` ou `git reset --hard`.
- Apresentar relatorio de diff respondendo as 8 perguntas do checklist antes de solicitar commit.
