-- Executado sob demanda: retorna o JSON pronto, sem reter outra funcao.
local store = require("network_store")
local config = require("config")
local active, channel, result, received, missing = require("scanner").get_stats()
-- Apenas o nome configuravel precisa de escape; os demais textos sao enums
-- internos ou o IP fornecido pelo firmware. Evita um objeto JSON com 14 campos.
local quote = dofile("http_quote.lc")
local identity = '{"device":' .. quote(config.DEVICE_NAME) .. '}'
return string.sub(identity, 1, -2) .. string.format(
    ',"scanning":%s,"channel":%d,"last_result":"%s","received":%d,' ..
    '"missing":%d,"unattempted":%d,"state":"%s","heap":%d,' ..
    '"uptime":%d,"ip":"%s","network_count":%d,"last_update":%d}',
    tostring(active), channel, result, received, missing,
    result == "not_started" and 0 or config.SCAN_LAST_CHANNEL - received - missing,
    require("state_machine").get_state(), node.heap(), tmr.time(),
    wifi.sta.getip() or "", store.get_count(), store.get_last_update())
