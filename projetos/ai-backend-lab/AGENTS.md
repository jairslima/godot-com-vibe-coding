# Contrato Operacional para Agentes - AI Backend Lab by Jair Lima

## Versão do Motor
- Godot 4.7.2 Stable (Windows 11).

## Linguagem e Padrões
- GDScript com tipagem estática obrigatória (`:=`, `-> void`, `Array[String]`, etc.).
- Não utilizar APIs antigas do Godot 3 (como `JSON.print()` ou `OS.get_unix_time()`). Usar `JSON.stringify()`, `Time.get_unix_time_from_system()`.
- Chaves de API reais nunca entram no cliente nem no repositório.

## Validação Obrigatória
Antes de considerar tarefas concluídas:
1. Executar importação: `godot_console --headless --path . --import`
2. Executar suíte de testes: `godot_console --headless --path . --scene res://tests/test_ai_network.tscn --quit-after 20`
3. O código de saída deve ser 0.
