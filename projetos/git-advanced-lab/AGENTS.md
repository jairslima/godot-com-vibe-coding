# AGENTS.md: Regras de Engenharia e Controle de Versão

## Projeto
Git Advanced Lab by Jair Lima (Godot 4.7.2 Stable)

## Regras Inegociáveis de Git para Agentes
1. Nunca execute `git push --force` ou `git push -f` sob nenhuma circunstância. A reescrita de histórico remoto destrói commits de outros colaboradores e agentes.
2. Nunca execute `git reset --hard` sem autorização humana expressa e documentada no prompt. Alterações não comitadas devem ser preservadas com `git stash` ou descartadas seletivamente via `git restore <arquivo>`.
3. Sempre crie uma branch isolada (`feature/<nome>`) antes de iniciar qualquer implementação multi-arquivo.
4. Execute `git status` e `git diff` antes de solicitar aprovação de alterações para auditar modificações acidentais.
5. Assets pesados (*.glb, *.png, *.wav) devem ser rastreados pelo Git LFS conforme definido em `.gitattributes`.
6. Valide a integridade do projeto via CLI antes de comitar:
   `godot_console --headless --path . --import`
   `godot_console --headless --path . --scene res://tests/test_git_runner.tscn`
