-- Simula a ordem da inicializacao; nao gera bytecode para o ESP8266 no host.
local root='NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/nodemcu/'
local function check(fail)
    local events, started, calls, pending = {}, false, 0
    node={stripdebug=function(level) assert(level==3) end,
        compile=function(name)
            assert(not started)
            calls=calls+1;events[#events+1]=name
            if fail then error('compile failed') end
        end}
    tmr={ALARM_SINGLE=0,create=function()
        return {alarm=function(_,delay,_,fn)
            assert(delay==3000 or delay==100);pending=fn
        end,unregister=function() pending=nil end}
    end}
    package.loaded.main={start=function() assert(calls==4);started=true end}
    dofile(root..'init.lua')
    for i=1,5 do
        if not pending then break end
        local fn=pending;pending=nil;fn()
    end
    if fail then assert(not started and calls==1)
    else assert(started and events[1]=='http_connection.lua' and events[2]=='http_status.lua' and events[3]=='http_networks.lua' and events[4]=='http_quote.lua') end
end
check(false);check(true)
print('PASS: HTTP compilado antes de main; falha de compilacao interrompe boot')
