# bot-sigma-nim ⚡

Automação autônoma nativa para **Sigma Project Online** reescrita 100% em **Nim 2.2** com modelo de gerenciamento de memória ORC (`--mm:orc`), zero overhead de Garbage Collector e ultra-baixo consumo de memória RAM.

## 🚀 Destaques da Arquitetura Nim
- **100% Paridade de Heurística e Métricas**: Compatível com as métricas JSON de telemetria expostas na porta padrão (`3002`) sob `/api/status`.
- **Motor Anti-Detecção com Pacing e Jitter Orgânico**: Variação randômica de $\pm 20\%$ nos intervalos de caça e ações para evitar assinaturas temporais determinísticas.
- **Operação 24/7 Contínua sem Pausas Forçadas**: Otimizado para jogabilidade de idle contínua.
- **Protocolo de Sessão Autoritativo**: Autenticação REST `/auth/login`, aquisição de ticket `/game/ticket` e conexão com WebSocket de combate e eventos.
- **Consumo de Memória Extremamente Reduzido**: Binário estático e compacto compilado via Zig toolchain.

## 📦 Compilação
```bash
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-sigma-linux-nim main.nim
```

## ⚙️ Configuração
Copie `accounts.example.json` para `accounts.json` e insira suas credenciais:
```json
[
  {
    "id": "acc1",
    "name": "kbelludoo",
    "enabled": true,
    "email": "user@exemplo.com",
    "password": "senha-segura",
    "huntSlug": "auto",
    "autoHunt": true,
    "autoCatch": true,
    "autoHeal": true,
    "autoDaily": true
  }
]
```
