
print("[INIT] Inicializando Wi-Fi Monitor")

-- Reduz a RAM dos modulos carregados a seguir. Os logs continuam disponiveis,
-- mas os erros Lua deixam de incluir os numeros de linha desses modulos.
if node.stripdebug then
    node.stripdebug(3)
end

-- Pequeno atraso para permitir acesso
-- ao terminal em caso de problemas
local boot_timer = tmr.create()

boot_timer:alarm(3000, tmr.ALARM_SINGLE,
    function()
        boot_timer:unregister()
        local main = require("main")
        main.start()
    end
)
