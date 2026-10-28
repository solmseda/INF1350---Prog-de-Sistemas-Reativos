local scanner = {}
local config = require("config")
local state = require("state_machine")
local store = require("network_store")
local timer = tmr.create()
local channel, received, missing, complete
local active, waiting = false, false
local token = 0
local step

local function finish(success)
    timer:unregister()
    active, waiting = false, false
    token = token + 1 -- invalida callbacks atrasados
    if received > 0 then
        state.set_state("PROCESSING")
        store.finish()
    end
    if not success then state.set_state("ERROR") end
    state.set_state("WAITING")
    local callback = complete
    complete = nil
    if callback then callback(success, received, missing) end
end

local function advance()
    waiting = false
    channel = channel + 1
    timer:alarm(config.SCAN_CHANNEL_DELAY, tmr.ALARM_SINGLE, step)
end

local function receive(results, request)
    if not active or not waiting or request ~= token then return end
    timer:stop()
    if type(results) ~= "table" then finish(false); return end
    received = received + 1
    for bssid, info in pairs(results) do
        store.add_result(bssid, info)
        results[bssid] = nil
    end
    advance()
end

local function timeout()
    print("[SCANNER] Canal sem resposta:", channel)
    missing = missing + 1
    advance()
end

step = function()
    if not active then return end
    if channel > config.SCAN_LAST_CHANNEL then finish(missing == 0); return end
    collectgarbage("collect")
    print("[SCANNER] Canal:", channel, "Heap:", node.heap())
    if node.heap() < config.SCAN_MIN_HEAP then
        print("[SCANNER] Memoria insuficiente")
        finish(false)
        return
    end
    token = token + 1
    local request = token
    waiting = true
    timer:alarm(config.SCAN_CHANNEL_TIMEOUT, tmr.ALARM_SINGLE, timeout)
    local ok, err = pcall(wifi.sta.getap,
        {channel = channel, show_hidden = 0}, 1,
        function(results) receive(results, request) end)
    if not ok then
        print("[SCANNER] Erro:", tostring(err))
        finish(false)
    end
end

function scanner.start(callback)
    if active or not state.is("WAITING") then return false end
    collectgarbage("collect")
    print("[SCANNER] Heap antes:", node.heap())
    if node.heap() < config.SCAN_MIN_HEAP then return false end
    store.clear()
    state.set_state("SCANNING")
    channel, received, missing = 1, 0, 0
    complete, active = callback, true
    -- Retorna ao event loop antes de iniciar o primeiro canal.
    timer:alarm(config.SCAN_CHANNEL_DELAY, tmr.ALARM_SINGLE, step)
    return true
end

function scanner.is_scanning() return active end
function scanner.get_network_count() return store.get_count() end
return scanner
