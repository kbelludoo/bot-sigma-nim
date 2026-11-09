import std/[asyncdispatch, json, uri]
import ws

type
  SigmaSocketClient* = ref object
    ws*: WebSocket
    isConnected*: bool

proc newSigmaSocketClient*(): SigmaSocketClient =
  new(result)
  result.isConnected = false

proc connect*(self: SigmaSocketClient, ticket: string): Future[bool] {.async.} =
  let wsUrl = "wss://api.poke.sigmaproject.online/ws?ticket=" & encodeUrl(ticket)
  try:
    self.ws = await newWebSocket(wsUrl)
    self.isConnected = true
    result = true
  except CatchableError as e:
    echo "[Sigma WS] Erro de conexão WebSocket: ", e.msg
    self.isConnected = false
    result = false

proc sendJson*(self: SigmaSocketClient, val: JsonNode): Future[bool] {.async.} =
  if self.ws == nil or not self.isConnected: return false
  try:
    await self.ws.send($val)
    result = true
  except CatchableError as e:
    echo "[Sigma WS] Erro ao enviar pacote: ", e.msg
    self.isConnected = false
    result = false

proc readMessage*(self: SigmaSocketClient): Future[string] {.async.} =
  if self.ws == nil or not self.isConnected: return ""
  try:
    result = await self.ws.receiveStrPacket()
  except CatchableError:
    self.isConnected = false
    result = ""
