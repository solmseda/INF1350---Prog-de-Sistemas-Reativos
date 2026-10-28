-- Uma rede por envio; este arquivo nao carrega a implementacao de status.
local store = require("network_store")
local snapshot = store.snapshot()
local quote = dofile("http_quote.lc")
local key, started, ended
return function()
    if ended then return nil end
    if not started then started = true; return "[" end
    local bssid, info = next(snapshot, key)
    if not bssid then ended = true; snapshot = nil; return "]" end
    local ssid, rssi, authmode, channel =
        string.match(info, "^(.*),(-?%d+),(%d+),(%d+)$")
    local body = string.format('{"ssid":%s,"rssi":%d,"authmode":%d,"channel":%d,"bssid":%s}',
        quote(ssid), tonumber(rssi), tonumber(authmode), tonumber(channel), quote(bssid))
    local prefix = key and "," or ""
    key = bssid
    return prefix .. body
end
