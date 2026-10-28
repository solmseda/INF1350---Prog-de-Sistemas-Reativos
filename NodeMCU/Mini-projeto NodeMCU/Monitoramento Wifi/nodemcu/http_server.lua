
local http_server = {}

local server = nil

function http_server.start()
    if server then
        return
    end

    server = net.createServer(net.TCP, 30)

    server:listen(80, function(connection)
        connection:on("receive", function(conn, request)
            print("[HTTP] Requisicao recebida")

            local body = "Wi-Fi Monitor funcionando!"

            local response =
                "HTTP/1.1 200 OK\r\n" ..
                "Content-Type: text/plain\r\n" ..
                "Content-Length: " .. #body .. "\r\n" ..
                "Connection: close\r\n" ..
                "\r\n" ..
                body

            conn:send(response, function(c)
                c:close()
            end)
        end)
    end)

    print("[HTTP] Servidor iniciado na porta 80")
end

return http_server
