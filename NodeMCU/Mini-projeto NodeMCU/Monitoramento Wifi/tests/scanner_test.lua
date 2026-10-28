-- Executar da raiz do repositorio. Simula o SDK, sem medir a RAM da placa.
package.path='NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/nodemcu/?.lua;'..package.path
local now, queue, scans, completions, late = 0, {}, 0, 0
local mode='ok'
local function post(delay,fn) queue[#queue+1]={at=now+delay,fn=fn} end
local function advance(limit)
    local n=0
    while true do
        table.sort(queue,function(a,b) return a.at<b.at end)
        if #queue==0 or queue[1].at>limit then break end
        local event=table.remove(queue,1); now=event.at; event.fn()
        n=n+1; assert(n<2000)
    end
    now=limit
end
node={heap=function() return 20000 end,task={post=function(fn) post(0,fn) end}}
tmr={ALARM_SINGLE=0,time=function() return now/1000 end,create=function()
    local timer={generation=0}
    function timer:stop() self.generation=self.generation+1 end
    function timer:unregister() self:stop() end
    function timer:alarm(delay,_,fn)
        self:stop(); local gen=self.generation
        post(delay,function() if gen==self.generation then fn(self) end end)
    end
    return timer
end}
wifi={sta={getap=function(cfg,_,cb)
    scans=scans+1
    if mode=='stuck' or (mode=='partial' and cfg.channel==2) then late=cb; return end
    post(3000,function() cb({['bssid'..cfg.channel]='SSID,-50,3,'..cfg.channel}) end)
end}}
local scanner=require('scanner')
local scheduler=require('scheduler')
local state=require('state_machine')
local function execute()
    assert(scanner.start(function(ok)
        completions=completions+1
        scheduler.next()
    end))
end
scheduler.start(execute,true)
advance(31000)
assert(completions==0 and scans==10, 'scheduler must not overlap a slow scan')
advance(42500)
assert(completions==1 and state.is('WAITING'))
advance(72499); assert(scans==13)
advance(72500); assert(scans==13)
advance(72750); assert(scans==14)
scheduler.stop()
advance(115000); assert(completions==2)
mode='stuck'
local failed=0
assert(scanner.start(function(ok) assert(not ok); failed=failed+1 end))
advance(now+107500)
assert(failed==1 and state.is('WAITING') and not scanner.is_scanning())
late({}); assert(failed==1 and state.is('WAITING'))
mode='partial'
local partial=false
assert(scanner.start(function(ok, received, missing)
    assert(not ok and received==12 and missing==1)
    partial=true
end))
advance(now+47500)
assert(partial and state.is('WAITING'))
local active,ch,result,received,missing=scanner.get_stats(); assert(not active and result=='partial' and received==12 and missing==1)
mode='ok'
assert(scanner.start(function(ok) assert(ok) end))
advance(now+42500)
assert(state.is('WAITING') and not scanner.is_scanning())
print('PASS: canal 2 sem callback, resultado parcial explicito, todos os canais sem resposta,  pausa entre canais, scan >30s sem sobreposicao, timeout, callback atrasado e recuperacao')

local st=require('network_store'); assert(st.get_count()==5); for _,info in pairs(st.snapshot()) do assert(info:find(',-50,',1,true)) end; print('PASS: limite fixo de 5, redes mais fortes, callbacks invalidos apos timeout')

local http_busy = true
package.loaded.http_server = {is_busy=function() return http_busy end}
local before = scans
assert(not scanner.start())
http_busy = false
assert(scanner.start(function(ok) assert(ok) end))
http_busy = true
advance(now + 1000)
assert(scans == before and scanner.is_scanning())
http_busy = false
advance(now + 42500)
assert(not scanner.is_scanning() and state.is('WAITING'))
print('PASS: novo canal aguarda a liberacao da conexao HTTP')

-- As redes da rodada anterior nao devem bloquear uma nova tentativa.
local store = require('network_store')
node.heap = function() return store.get_count() > 0 and 11000 or 14000 end
assert(scanner.start())
assert(store.get_count() == 0)
print('PASS: resultados antigos liberados antes da verificacao de heap')
