import std/[asyncdispatch, json, strformat, times]
import types, api, socket, stealth

type
  BotInstance* = ref object
    config*: AccountConfig
    api*: GameApiClient
    socket*: SigmaSocketClient
    status*: BotAccountStatus
    running*: bool

proc newBotInstance*(config: AccountConfig): BotInstance =
  new(result)
  result.config = config
  result.api = newGameApiClient(config.credentials.token)
  result.socket = newSigmaSocketClient()
  result.status = BotAccountStatus(
    id: config.id,
    alias: config.name,
    trainerName: config.name,
    bindIp: config.bindIp,
    outboundIp: if config.bindIp.len > 0: config.bindIp else: "SEU_IP_DA_VPS",
    level: 0,
    hp: 0,
    maxHp: 0,
    hpPercent: 0.0,
    gold: 0,
    goldFound: 0,
    diamonds: 0,
    xp: 0,
    xpIntoLevel: 0,
    xpToNextLevel: 0,
    xpPercent: 0.0,
    xpPerHour: 0.0,
    trainerXpGained: 0,
    kills: 0,
    killsPerMin: 0.0,
    captures: 0,
    shinies: 0,
    mapSlug: config.settings.huntSlug,
    mapName: config.settings.huntSlug,
    strategy: config.settings.strategy,
    inGame: false,
    inHunt: false,
    autoHuntActive: false,
    vipActive: false,
    vipExpiringSoon: false,
    leaderName: "",
    leaderLevel: 0,
    leaderHp: 0,
    leaderMaxHp: 0,
    leaderShiny: false,
    wildTarget: "",
    wildLevel: 0,
    wildHp: 0,
    wildMaxHp: 0,
    wildShiny: false,
    bestiaryCurrentKills: 0,
    bestiaryTargetKills: config.settings.bestiaryTargetKills,
    bestiaryTotalKills: 0,
    bestiaryCompletedCount: 0,
    bestiaryPendingCount: 0,
    teamSize: 0,
    connectedAt: 0,
    updatedAt: (epochTime() * 1000).int64,
    lastAction: "Iniciando sessão...",
    lastError: ""
  )
  result.running = false

proc logConsoleSummary*(self: BotInstance) =
  let st = self.status
  let vipStr = if st.vipActive: "VIP ATIVO" else: "SEM VIP"
  let connStr = if st.inGame: "CONECTADO" else: "CONECTANDO"

  echo fmt"[{self.config.id}: {st.trainerName} (Nv. {st.level}) │ IP: {st.outboundIp}] [ {connStr} ] [ {vipStr} ]"
  echo fmt"  🗺️  Rota: {st.mapSlug} │ ❤️  Vida: {st.hp}/{st.maxHp} │ ⚔️  Kills: {st.kills} ({st.killsPerMin:.1f}/m) │ ⚡ XP/h: {st.xpPerHour:.0f} │ 🎯 Caps: {st.captures}"
  echo fmt"  💰 Ouro: {st.gold} gp ({st.goldFound} gp) │ 💎 Diamantes: {st.diamonds} │ XP: {st.xpIntoLevel}/{st.xpToNextLevel} ({st.xpPercent:.1f}%)"
  echo fmt"  📝 Ação: {st.lastAction}"

proc run*(self: BotInstance) {.async.} =
  self.running = true

  while self.running:
    var token = self.api.accessToken
    if token.len == 0 and self.config.credentials.email.len > 0 and self.config.credentials.password.len > 0:
      let (tok, err) = await self.api.login(self.config.credentials.email, self.config.credentials.password)
      if tok.len > 0:
        token = tok
        self.status.lastError = ""
        self.status.lastAction = "Login realizado com sucesso! Obtendo ticket..."
      else:
        self.status.lastError = err
        self.status.lastAction = fmt"Erro: {err} (tentando em 30s)"
        self.logConsoleSummary()
        await sleepAsync(30000)
        continue

    if token.len > 0:
      try:
        let ticket = await self.api.getTicket()
        if ticket.len > 0:
          let connected = await self.socket.connect(ticket)
          if connected:
            self.status.inGame = true
            self.status.connectedAt = (epochTime() * 1000).int64
            self.status.lastAction = "Conectado ao WebSocket autoritativo."
            self.logConsoleSummary()

            while self.running and self.socket.isConnected:
              let msg = await self.socket.readMessage()
              if msg.len == 0: break
              # Process incoming JSON messages
      except CatchableError as e:
        self.status.lastError = e.msg
        self.status.lastAction = fmt"Erro: {e.msg} (tentando em 30s)"
        self.logConsoleSummary()

    self.status.inGame = false
    let reconnDelay = applyJitter(30000, 0.15)
    await sleepAsync(reconnDelay)
