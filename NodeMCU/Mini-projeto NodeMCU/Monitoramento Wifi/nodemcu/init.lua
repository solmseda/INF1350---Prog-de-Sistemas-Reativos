
print("[INIT] Inicializando Wi-Fi Monitor")

-- Pequeno atraso para permitir acesso
-- ao terminal em caso de problemas
local boot_timer = tmr.create()

boot_timer:alarm(3000, tmr.ALARM_SINGLE,
    function()
        local main = require("main")
        main.start()
    end
)
