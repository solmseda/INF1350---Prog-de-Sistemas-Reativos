-- O codigo da conexao fica em RAM apenas enquanto houver uma requisicao.
return function(conn, on_close, first_data)
    local handle, producer, line = nil, nil, ""
    local function cleanup(c)
        if handle then handle:close(); handle = nil end
        producer, line = nil, nil
        c:on("receive", nil)
        c:on("sent", nil)
        c:on("disconnection", nil)
        c:on("reconnection", nil)
        if on_close then
            local release = on_close
            on_close = nil
            release()
        end
    end
    local function close(c)
        cleanup(c)
        c:close()
    end
    conn:on("disconnection", cleanup)
    conn:on("reconnection", cleanup)
    conn:on("sent", function(c)
        local chunk
        if handle then chunk = handle:read(512)
        elseif type(producer) == "string" then
            chunk, producer = producer, nil
        elseif producer then
            collectgarbage("collect")
            local ok, result = pcall(producer)
            if ok then chunk = result
            else print("[HTTP] Erro no envio:", tostring(result)) end
        end
        if chunk then c:send(chunk)
        else
            -- Fechar localmente nao deve depender de outro evento para liberar busy.
            close(c)
        end
    end)
    local function receive(c, data)
        if not line then return end -- apenas uma resposta por conexao
        line = line .. string.sub(data, 1, 258)
        local ending = string.find(line, "\r\n", 1, true)
        if not ending then
            if #line > 256 then close(c) end
            return
        end
        if ending > 257 then close(c); return end
        local method, path = string.match(string.sub(line, 1, ending - 1),
            "^(%u+) ([^ ?]+)[^ ]* HTTP/1%.[01]$")
        line = nil
        print("[HTTP] Rota:", tostring(path))
        local code, mime = "200 OK", "application/json"
        if not method then code = "400 Bad Request"
        elseif method ~= "GET" then code = "405 Method Not Allowed"
        elseif path == "/" then
            handle = file.open("index.html", "r")
            mime = "text/html; charset=utf-8"
            if not handle then
                print("[HTTP] Arquivo index.html ausente na placa")
                code = "404 Not Found"
            end
        elseif path == "/api/status" or path == "/api/networks" then
            collectgarbage("collect")
            local ok, result = pcall(dofile,
                path == "/api/status" and "http_status.lc" or "http_networks.lc")
            if ok then producer = result
            else
                print("[HTTP] Erro na API:", tostring(result))
                code = "500 Internal Server Error"
            end
        else code = "404 Not Found" end
        c:send("HTTP/1.0 " .. code .. "\r\nContent-Type: " .. mime ..
            "\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n")
    end
    conn:on("receive", receive)
    if first_data then receive(conn, first_data) end
end
