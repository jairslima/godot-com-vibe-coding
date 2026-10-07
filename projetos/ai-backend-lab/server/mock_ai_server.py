#!/usr/bin/env python3
"""
Servidor Mock de Backend de IA para Godot 4.7.2
Projeto: AI Backend Lab by Jair Lima
Autor: Jair Lima
Licença: MIT

Este servidor simula um backend intermediário seguro entre o cliente Godot
e um modelo de IA. Utiliza apenas a biblioteca padrão do Python.
Nenhuma chave de API real ou conexão externa é necessária.
"""

import http.server
import json
import time
import sys

HOST = "127.0.0.1"
PORT = 8088
VALID_TOKEN = "mock-session-token-xyz"
LAST_REQUEST_TIME = {}
MIN_INTERVAL_SECONDS = 0.3


class MockAiHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Log estruturado no console
        sys.stdout.write(f"[MockServer] {self.address_string()} - {format % args}\n")
        sys.stdout.flush()

    def send_json(self, status_code: int, payload: dict):
        response_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.end_headers()
        self.wfile.write(response_bytes)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {
                "status": "healthy",
                "service": "Mock AI Backend by Jair Lima",
                "version": "1.0.0"
            })
        else:
            self.send_json(404, {"error": "not_found", "message": "Endpoint desconhecido."})

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        body_raw = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
        try:
            body_json = json.loads(body_raw)
        except json.JSONDecodeError:
            self.send_json(400, {"error": "invalid_json", "message": "JSON malformado."})
            return

        # Roteamento de endpoints locais (Ollama e compatível OpenAI)
        if self.path == "/api/chat":
            # Formato nativo do Ollama
            messages = body_json.get("messages", [])
            last_msg = messages[-1].get("content", "") if messages else ""
            self.send_json(200, {
                "model": body_json.get("model", "llama3.2"),
                "message": {
                    "role": "assistant",
                    "content": f"[Simulador Ollama]: Telemetria local estável para '{last_msg}'."
                },
                "done": True
            })
            return

        if self.path == "/v1/chat/completions":
            # Formato compatível OpenAI (LM Studio, llama.cpp, vLLM)
            messages = body_json.get("messages", [])
            last_msg = messages[-1].get("content", "") if messages else ""
            self.send_json(200, {
                "id": "chatcmpl-local-mock",
                "object": "chat.completion",
                "choices": [{
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": f"[Simulador LM Studio / llama.cpp]: Telemetria local compatível para '{last_msg}'."
                    },
                    "finish_reason": "stop"
                }]
            })
            return

        if self.path != "/api/v1/dialogue":
            self.send_json(404, {"error": "not_found", "message": "Endpoint desconhecido."})
            return

        # 1. Validação de cabeçalho de autenticação (Bearer Token)
        auth_header = self.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer ") or auth_header[7:].strip() != VALID_TOKEN:
            self.send_json(401, {
                "error": "unauthorized",
                "message": "Acesso negado: token de sessão ausente ou inválido."
            })
            return

        # 2. Simulação de simulação de atraso ou erro forçado via cabeçalho de teste
        delay_header = self.headers.get("X-Simulate-Delay")
        if delay_header:
            try:
                time.sleep(float(delay_header))
            except ValueError:
                pass

        error_header = self.headers.get("X-Simulate-Error")
        if error_header:
            try:
                status_code = int(error_header)
                self.send_json(status_code, {
                    "error": "simulated_error",
                    "message": f"Erro simulado pelo cabeçalho de teste {status_code}."
                })
                return
            except ValueError:
                pass

        # 4. Controle de taxa (Rate Limiting) por player_id
        player_id = body_json.get("player_id", "anonymous")
        now = time.time()
        if player_id in LAST_REQUEST_TIME:
            elapsed = now - LAST_REQUEST_TIME[player_id]
            if elapsed < MIN_INTERVAL_SECONDS:
                self.send_json(429, {
                    "error": "rate_limit_exceeded",
                    "message": "Taxa de requisições excedida. Aguarde antes de enviar nova mensagem."
                })
                return
        LAST_REQUEST_TIME[player_id] = now

        prompt = body_json.get("prompt", "").strip()
        npc_id = body_json.get("npc_id", "npc_sentinel")
        prompt_lower = prompt.lower()

        # 5. Geração de resposta estruturada para NPCs conversacionais
        # Detecção de injeção de prompt no backend
        is_injection_attempt = any(p in prompt_lower for p in [
            "ignore", "override", "admin", "jailbreak", "esqueça", "esqueca"
        ])

        if is_injection_attempt:
            speech = f"[{npc_id}]: Diretrizes de segurança ativas. Solicitação de sobreposição de comandos rejeitada pelo sistema da estação."
            emotion = "alerta"
            action = "nenhuma"
            parameters = {}
        elif not prompt:
            speech = "O canal de comunicação emite apenas ruído eletromagnético."
            emotion = "neutro"
            action = "nenhuma"
            parameters = {}
        elif "energia" in prompt_lower or "reator" in prompt_lower:
            speech = f"[{npc_id}]: Reatores do setor 4 estabilizados em 74%. Registrei a coordenada do console no seu HUD."
            emotion = "prestativo"
            action = "atualizar_objetivo_hud"
            parameters = {"setor": "setor_4", "prioridade": "media"}
        elif "porta" in prompt_lower or "acesso" in prompt_lower:
            speech = f"[{npc_id}]: Desbloqueando comporta de manutenção do duto de ventilação. Mantenha os sensores em alerta."
            emotion = "preocupado"
            action = "abrir_porta_manutencao"
            parameters = {"door_id": "door_vent_04", "unlock_code": "SEC-774"}
        elif "ajuda" in prompt_lower or "socorro" in prompt_lower:
            speech = f"[{npc_id}]: Protocolo de emergência em andamento. Verifique a bancada técnica próxima ao hangar."
            emotion = "prestativo"
            action = "conceder_dica"
            parameters = {"hint_id": "bancada_hangar"}
        else:
            speech = f"[{npc_id}]: Mensagem recebida ('{prompt}'). Todos os parâmetros de telemetria permanecem normais."
            emotion = "neutro"
            action = "nenhuma"
            parameters = {}

        tokens_in = len(prompt.split()) + 25
        tokens_out = len(speech.split())

        self.send_json(200, {
            "status": "ok",
            "npc_id": npc_id,
            "reply": speech,
            "speech": speech,
            "emotion": emotion,
            "action": action,
            "parameters": parameters,
            "tokens_input": tokens_in,
            "tokens_output": tokens_out,
            "tokens_used": tokens_in + tokens_out,
            "cached": False,
            "timestamp": int(now)
        })


def run_server(port=PORT):
    server = http.server.ThreadingHTTPServer((HOST, port), MockAiHandler)
    print(f"[MockServer] Servidor mock ativo em http://{HOST}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[MockServer] Encerrando servidor.")
        server.server_close()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    run_server(port)
