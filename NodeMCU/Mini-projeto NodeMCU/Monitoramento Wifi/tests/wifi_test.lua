package.path='NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/nodemcu/?.lua;'..package.path
local handlers={}
wifi={STATION=1,setmode=function() end,
    eventmon={STA_GOT_IP=1,STA_DISCONNECTED=2,register=function(event,callback) handlers[event]=callback end},
    sta={config=function() end,connect=function() end}}
local manager=require('wifi_manager')
local count=0
local callback=function() count=count+1 end
local weak=setmetatable({callback},{__mode='v'})
manager.start(callback);callback=nil
collectgarbage('collect');assert(weak[1])
handlers[1]({IP='10.0.0.2'})
collectgarbage('collect');assert(weak[1]==nil and count==1)
handlers[2]({reason=2});assert(not manager.is_connected())
handlers[1]({IP='10.0.0.3'})
assert(manager.is_connected() and manager.get_ip()=='10.0.0.3' and count==1)
print('PASS: callback de inicializacao liberado; reconexao mantem estado sem duplicar boot')
