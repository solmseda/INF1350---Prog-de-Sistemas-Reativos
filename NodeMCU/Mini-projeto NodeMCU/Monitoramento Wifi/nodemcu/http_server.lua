local http_server = {}
local config = require("config")
local server, busy
local function release() busy = false end

local function close(c) c:close() end
local function request(c, data)
    c:on("receive", nil)
    collectgarbage("collect")
    print("[HTTP] Requisicao. Heap:", node.heap())
    if busy or require("scanner").is_scanning() or node.heap() < 10000 then
        c:send("HTTP/1.0 503 Busy\r\nRetry-After: 5\r\nConnection: close\r\n\r\n", close)
        return
    end
    busy = true
    local context = {}
    local ok, handler = pcall(dofile, "http_connection.lc")
    if ok then ok, handler = pcall(handler, c, release, data, context) end
    if not ok then
        print("[HTTP] Falha:", tostring(handler))
        if context.cleanup then context.cleanup(c) end
        busy = false
        c:close()
        collectgarbage("collect")
    end
end
local function accept(conn) conn:on("receive", request) end

function http_server.is_busy() return busy end
function http_server.start()
    if server then return end
    server = net.createServer(net.TCP, 5)
    server:listen(config.HTTP_PORT, accept)
    print("[HTTP] Servidor iniciado na porta " .. config.HTTP_PORT)
end
return http_server
