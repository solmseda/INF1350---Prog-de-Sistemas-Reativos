-- Executar da raiz do repositorio: lua "NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/tests/http_test.lua"
local root = 'NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/nodemcu/'
package.path = root .. '?.lua;' .. package.path
local real_dofile = dofile
-- No host, usa o fonte correspondente; o bytecode NodeMCU e gerado na placa.
dofile = function(name) return real_dofile(root .. name:gsub("%.lc$", ".lua")) end
local queue, accept, opened = {}, nil, 0
local heap = 15000
node = {heap=function() return heap end}
tmr = {time=function() return 100 end}
wifi = {sta={getip=function() return '10.0.0.2' end}}
local scanning=false
package.loaded.scanner = {is_scanning=function() return scanning end,get_stats=function()
    return false, 0, 'partial', 7, 6
end}
package.loaded.state_machine = {get_state=function() return 'WAITING' end}
-- Substituto do encoder apenas no host: o firmware fornece sjson.
local function encode(value)
    if type(value)=='string' then
        return '"' .. value:gsub('[%z\1-\31\\"]', function(c)
            return string.format('\\u%04x',string.byte(c))
        end) .. '"'
    elseif type(value)=='number' or type(value)=='boolean' then return tostring(value) end
    local parts={}
    for key,item in pairs(value) do parts[#parts+1]=encode(key)..':'..encode(item) end
    return '{'..table.concat(parts,',')..'}'
end
sjson = {encode=function() error('sjson nao deve ser usado nas respostas HTTP') end}
file = {open=function(name)
    local f=io.open(root..name,'rb')
    if not f then return nil end
    opened=opened+1
    return {read=function(_,size) return f:read(size) end,
        close=function() f:close(); opened=opened-1 end}
end}
net = {TCP=1,createServer=function(_,timeout)
    assert(timeout==5)
    return {listen=function(_,port,fn) assert(port==80); accept=fn end}
end}
local fail_send = false
local function socket()
    local s={events={},chunks={},closed=false}
    function s:on(event,fn) self.events[event]=fn end
    function s:send(chunk,callback)
        if fail_send then fail_send = false; error('simulated send OOM') end
        assert(not self.closed and #chunk<=512)
        self.chunks[#self.chunks+1]=chunk
        queue[#queue+1]=function()
            local fn=callback or self.events.sent
            if fn and not self.closed then fn(self) end
        end
    end
    function s:close()
        if self.closed then return end
        self.closed=true
        -- Fechamento local NAO dispara automaticamente disconnection.
        -- Isso evita que o mock esconda um busy preso apos enviar o HTML.
    end
    function s:receive(data) if self.events.receive then self.events.receive(self,data) end end
    accept(s)
    return s
end
local function drain()
    local steps=0
    while #queue>0 do
        table.remove(queue,1)(); steps=steps+1; assert(steps<1000)
    end
end
local function request(path,method)
    local s=socket();s:receive((method or 'GET')..' '..path..' HTTP/1.1\r\nHost: test\r\n\r\n');drain()
    assert(s.closed and opened==0)
    return table.concat(s.chunks)
end
local store=require('network_store')
require('http_server').start()
local speculative=socket()
local status=request('/api/status')
speculative:close()
assert(status:find('200 OK',1,true) and status:find('"last_result":"partial"',1,true))
assert(not status:find(require('config').WIFI_PASSWORD,1,true))
assert(request('/api/networks'):match('%[%]$'))
store.add_result('aa','Cafe,"<script>, WiFi,-40,3,6')
local networks=request('/api/networks')
assert(networks:find('\\u0022',1,true) and networks:find('"rssi":-40',1,true))
local fragmented=socket(); fragmented:receive('GET /api/sta');fragmented:receive('tus HTTP/1.1\r');fragmented:receive('\n');drain()
assert(table.concat(fragmented.chunks):find('200 OK',1,true))
local html=socket();html:receive('GET / HTTP/1.1\r\n\r\n')
local busy=socket();busy:receive("GET / HTTP/1.1\r\n\r\n");drain();assert(table.concat(busy.chunks):find('503',1,true))
local f=assert(io.open(root..'index.html','rb'));local expected=f:read('*a');f:close()
assert(table.concat(html.chunks):match('\r\n\r\n(.*)')==expected and opened==0)
assert(not require('http_server').is_busy())
assert(request('/api/status'):find('200 OK',1,true))
assert(request('/api/networks'):find('200 OK',1,true))
local aborted=socket();aborted:receive('GET / HTTP/1.1\r\n\r\n');aborted.events.disconnection(aborted);aborted:close();drain();assert(opened==0)
scanning=true
local during=socket();during:receive('GET /api/status HTTP/1.1\r\n\r\n');drain()
assert(table.concat(during.chunks):find('503',1,true))
scanning=false
heap=9000
local low=socket();low:receive("GET / HTTP/1.1\r\n\r\n");drain();assert(table.concat(low.chunks):find('503',1,true))
heap=15000
local malformed=socket();malformed:receive('garbage\r\n');drain()
assert(table.concat(malformed.chunks):find('400',1,true))
assert(request('/missing'):find('404',1,true))
assert(request('/api/status','POST'):find('405',1,true))
local long=socket();long:receive(string.rep('x',257));assert(long.closed)
assert(request('/api/status'):find('200 OK',1,true))
fail_send=true
local broken=socket();broken:receive('GET / HTTP/1.1\r\n\r\n');drain()
assert(broken.closed and opened==0 and not require('http_server').is_busy())
assert(request('/api/status'):find('200 OK',1,true))
-- O snapshot conserva a resposta enquanto o scanner substitui seus dados.
local api=dofile('http_networks.lua')
assert(api()=='[');store.clear();assert(api():find('"rssi":-40',1,true));assert(api()==']' and api()==nil)
print('PASS: status, JSON vazio/escape, snapshot, TCP fragmentado, streaming, concorrencia, desconexao, 404/405 e limite de requisicao')
