import std/[asyncdispatch, asynchttpserver, json, times]
import types, bot

type
  WebServer* = ref object
    bots*: seq[BotInstance]
    port*: int

proc newWebServer*(bots: seq[BotInstance], port: int): WebServer =
  new(result)
  result.bots = bots
  result.port = port

proc start*(self: WebServer) {.async.} =
  var server = newAsyncHttpServer()
  let port = self.port
  let bots = self.bots

  proc cb(req: Request) {.async.} =
    if req.url.path == "/api/status":
      var accArray = newJArray()
      let nowMs = (epochTime() * 1000).int64

      for b in bots:
        let st = b.status
        accArray.add(%*{
          "id": st.id,
          "alias": st.alias,
          "trainerName": st.trainerName,
          "bindIp": st.bindIp,
          "outboundIp": st.outboundIp,
          "level": st.level,
          "hp": st.hp,
          "maxHp": st.maxHp,
          "hpPercent": st.hpPercent,
          "gold": st.gold,
          "goldFound": st.goldFound,
          "diamonds": st.diamonds,
          "xp": st.xp,
          "xpIntoLevel": st.xpIntoLevel,
          "xpToNextLevel": st.xpToNextLevel,
          "xpPercent": st.xpPercent,
          "xpPerHour": st.xpPerHour,
          "trainerXpGained": st.trainerXpGained,
          "kills": st.kills,
          "killsPerMin": st.killsPerMin,
          "captures": st.captures,
          "shinies": st.shinies,
          "mapSlug": st.mapSlug,
          "mapName": st.mapName,
          "strategy": st.strategy,
          "inGame": st.inGame,
          "inHunt": st.inHunt,
          "autoHuntActive": st.autoHuntActive,
          "vipActive": st.vipActive,
          "vipExpiringSoon": st.vipExpiringSoon,
          "leaderName": st.leaderName,
          "leaderLevel": st.leaderLevel,
          "leaderHp": st.leaderHp,
          "leaderMaxHp": st.leaderMaxHp,
          "leaderShiny": st.leaderShiny,
          "wildTarget": st.wildTarget,
          "wildLevel": st.wildLevel,
          "wildHp": st.wildHp,
          "wildMaxHp": st.wildMaxHp,
          "wildShiny": st.wildShiny,
          "bestiaryCurrentKills": st.bestiaryCurrentKills,
          "bestiaryTargetKills": st.bestiaryTargetKills,
          "bestiaryTotalKills": st.bestiaryTotalKills,
          "bestiaryCompletedCount": st.bestiaryCompletedCount,
          "bestiaryPendingCount": st.bestiaryPendingCount,
          "teamSize": st.teamSize,
          "connectedAt": st.connectedAt,
          "updatedAt": nowMs,
          "lastAction": st.lastAction,
          "lastError": st.lastError
        })

      let payload = %*{
        "serverTime": nowMs,
        "ramMB": 1.25,
        "accounts": accArray
      }

      let headers = newHttpHeaders([
        ("Content-Type", "application/json; charset=utf-8"),
        ("Access-Control-Allow-Origin", "*"),
        ("Cache-Control", "no-cache, no-store, must-revalidate")
      ])
      await req.respond(Http200, $payload, headers)
    else:
      let html = "<h1>Sigma Native Nim Multi-Bot Online</h1><p>Visite /api/status para telemetria.</p>"
      await req.respond(Http200, html, newHttpHeaders([("Content-Type", "text/html; charset=utf-8")]))

  server.listen(Port(port))
  echo "[Dashboard] Servidor HTTP de telemetria ativo na porta ", port
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      await sleepAsync(10)
