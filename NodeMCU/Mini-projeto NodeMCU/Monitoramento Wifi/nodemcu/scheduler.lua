
local scheduler = {}

local config = require("config")

local timer = tmr.create()
local running = false
local callback = nil

local function schedule_next()
    if not running then
        return
    end

    timer:alarm(
        config.SCAN_INTERVAL,
        tmr.ALARM_SINGLE,
        function()
            if running and callback then
                callback()
            end
        end
    )
end

function scheduler.start(on_tick, immediate)
    if running then
        return
    end

    callback = on_tick
    running = true

    print("[SCHEDULER] Iniciado")
    print("[SCHEDULER] Intervalo: " ..
          config.SCAN_INTERVAL .. " ms")

    if immediate then
        -- A conclusao da primeira rodada agenda a proxima, sem timer paralelo.
        callback()
    else
        schedule_next()
    end
end

function scheduler.next()
    schedule_next()
end

function scheduler.stop()
    running = false
    timer:stop()
    print("[SCHEDULER] Parado")
end

return scheduler
