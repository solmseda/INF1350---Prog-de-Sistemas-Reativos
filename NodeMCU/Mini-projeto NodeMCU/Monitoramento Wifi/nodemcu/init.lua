print("[INIT] Inicializando Wi-Fi Monitor")
if node.stripdebug then node.stripdebug(3) end

-- Compila antes de carregar main, quando ainda ha RAM para o compilador.
-- Regera em todo boot para nao executar bytecode antigo apos atualizar fontes.
local files = {"http_connection.lua", "http_status.lua", "http_networks.lua", "http_quote.lua"}
local index = 1
local timer = tmr.create()
local function boot()
    collectgarbage("collect")
    local name = files[index]
    if name then
        print("[INIT] Compilando:", name)
        local ok, err = pcall(node.compile, name)
        if not ok then
            print("[INIT] Falha na compilacao:", tostring(err))
            timer:unregister()
            return
        end
        index = index + 1
        timer:alarm(100, tmr.ALARM_SINGLE, boot)
    else
        timer:unregister()
        files = nil
        collectgarbage("collect")
        require("main").start()
        -- Os callbacks mantem so as funções necessarias em funcionamento.
        -- Libera as tabelas e funções de configuração que so executam no boot.
        package.loaded.main = nil
        package.loaded.wifi_manager = nil
    end
end
-- Atraso para permitir acesso ao terminal em caso de problema.
timer:alarm(3000, tmr.ALARM_SINGLE, boot)
