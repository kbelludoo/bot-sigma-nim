import std/[asyncdispatch, httpclient, json, strutils]

const
  BaseUrl = "https://api.poke.sigmaproject.online"
  OriginUrl = "https://poke.sigmaproject.online"
  UserAgentStr = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

type
  GameApiClient* = ref object
    accessToken*: string

proc newGameApiClient*(initialToken: string = ""): GameApiClient =
  new(result)
  result.accessToken = initialToken

proc createHeaders(self: GameApiClient): HttpHeaders =
  result = newHttpHeaders([
    ("Content-Type", "application/json"),
    ("Accept", "application/json, text/plain, */*"),
    ("Origin", OriginUrl),
    ("Referer", OriginUrl & "/"),
    ("User-Agent", UserAgentStr)
  ])
  if self.accessToken.len > 0:
    result.add("Authorization", "Bearer " & self.accessToken)

proc login*(self: GameApiClient, email, pass: string): Future[tuple[token: string, errMsg: string]] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = BaseUrl & "/auth/login"
  let payload = %*{"email": email, "password": pass}
  try:
    let resp = await client.post(url, $payload)
    let body = await resp.body
    let parsed = parseJson(body)
    if resp.code == Http200:
      let token = parsed{"accessToken"}.getStr("")
      self.accessToken = token
      result = (token, "")
    else:
      let errStr = parsed{"error"}.getStr("Erro desconhecido")
      let codeStr = parsed{"code"}.getStr("")
      let fullErr = if codeStr.len > 0:
                      "Login falhou (" & $resp.code & "): " & errStr & " (código: Some(\"" & codeStr & "\"))"
                    else:
                      "Login falhou (" & $resp.code & "): " & errStr
      result = ("", fullErr)
  except CatchableError as e:
    result = ("", "Falha na conexão de login: " & e.msg)

proc getTicket*(self: GameApiClient): Future[string] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = BaseUrl & "/game/ticket"
  let resp = await client.post(url, "{}")
  if resp.code == Http200:
    let body = await resp.body
    let parsed = parseJson(body)
    result = parsed{"ticket"}.getStr("")
  else:
    raise newException(IOError, "POST /game/ticket failed: " & $resp.code)

proc getTrainerMe*(self: GameApiClient): Future[JsonNode] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = BaseUrl & "/trainer/me"
  let resp = await client.get(url)
  if resp.code == Http200:
    let body = await resp.body
    result = parseJson(body)
  else:
    raise newException(IOError, "GET /trainer/me failed: " & $resp.code)
