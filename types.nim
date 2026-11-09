import std/[json, options]

type
  GameCredentials* = object
    email*: string
    password*: string
    token*: string

  GameSettings* = object
    huntSlug*: string
    autoHunt*: bool
    autoCatch*: bool
    autoHeal*: bool
    autoDaily*: bool
    autoSpin*: bool
    autoEvolve*: bool
    ballId*: int
    shinyBallId*: int
    strategy*: string
    bestiaryTargetKills*: int

  AccountConfig* = object
    id*: string
    name*: string
    enabled*: bool
    bindIp*: string
    credentials*: GameCredentials
    settings*: GameSettings

  BotAccountStatus* = object
    id*: string
    alias*: string
    trainerName*: string
    bindIp*: string
    outboundIp*: string
    level*: int
    hp*: int
    maxHp*: int
    hpPercent*: float
    gold*: int64
    goldFound*: int64
    diamonds*: int64
    xp*: int64
    xpIntoLevel*: int64
    xpToNextLevel*: int64
    xpPercent*: float
    xpPerHour*: float
    trainerXpGained*: int64
    kills*: int64
    killsPerMin*: float
    captures*: int
    shinies*: int
    mapSlug*: string
    mapName*: string
    strategy*: string
    inGame*: bool
    inHunt*: bool
    autoHuntActive*: bool
    vipActive*: bool
    vipExpiringSoon*: bool
    leaderName*: string
    leaderLevel*: int
    leaderHp*: int
    leaderMaxHp*: int
    leaderShiny*: bool
    wildTarget*: string
    wildLevel*: int
    wildHp*: int
    wildMaxHp*: int
    wildShiny*: bool
    bestiaryCurrentKills*: int
    bestiaryTargetKills*: int
    bestiaryTotalKills*: int
    bestiaryCompletedCount*: int
    bestiaryPendingCount*: int
    teamSize*: int
    connectedAt*: int64
    updatedAt*: int64
    lastAction*: string
    lastError*: string

proc parseAccountConfig*(node: JsonNode): AccountConfig =
  result.id = node{"id"}.getStr("")
  result.name = node{"name"}.getStr(result.id)
  result.enabled = node{"enabled"}.getBool(true)
  result.bindIp = node{"bindIP"}.getStr(node{"bind_ip"}.getStr(""))

  # Credentials (nested or flat)
  let cred = node{"credentials"}
  if cred != nil:
    result.credentials.email = cred{"email"}.getStr("")
    result.credentials.password = cred{"password"}.getStr("")
    result.credentials.token = cred{"token"}.getStr("")
  else:
    result.credentials.email = node{"email"}.getStr("")
    result.credentials.password = node{"password"}.getStr("")
    result.credentials.token = node{"token"}.getStr("")

  # Settings (nested or flat)
  result.settings.huntSlug = "auto"
  result.settings.autoHunt = true
  result.settings.autoCatch = true
  result.settings.autoHeal = true
  result.settings.autoDaily = true
  result.settings.autoSpin = true
  result.settings.autoEvolve = true
  result.settings.ballId = 1
  result.settings.shinyBallId = 3
  result.settings.strategy = "rush"
  result.settings.bestiaryTargetKills = 120

  let sett = node{"settings"}
  let s = if sett != nil: sett else: node

  if s.hasKey("huntSlug"): result.settings.huntSlug = s["huntSlug"].getStr("auto")
  elif s.hasKey("hunt_slug"): result.settings.huntSlug = s["hunt_slug"].getStr("auto")

  if s.hasKey("autoHunt"): result.settings.autoHunt = s["autoHunt"].getBool(true)
  elif s.hasKey("auto_hunt"): result.settings.autoHunt = s["auto_hunt"].getBool(true)

  if s.hasKey("autoCatch"): result.settings.autoCatch = s["autoCatch"].getBool(true)
  elif s.hasKey("auto_catch"): result.settings.autoCatch = s["auto_catch"].getBool(true)

  if s.hasKey("autoHeal"): result.settings.autoHeal = s["autoHeal"].getBool(true)
  elif s.hasKey("auto_heal"): result.settings.autoHeal = s["auto_heal"].getBool(true)

  if s.hasKey("autoDaily"): result.settings.autoDaily = s["autoDaily"].getBool(true)
  elif s.hasKey("auto_daily"): result.settings.autoDaily = s["auto_daily"].getBool(true)

  if s.hasKey("strategy"): result.settings.strategy = s["strategy"].getStr("rush")
  if s.hasKey("bestiaryTargetKills"): result.settings.bestiaryTargetKills = s["bestiaryTargetKills"].getInt(120)
