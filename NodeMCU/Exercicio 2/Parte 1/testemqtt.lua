-- Pode MUDAR meu id para o nÃºmero da placa!!!!
-- local mqttServer = "terrasim.inf.puc-rio.br"
local mqttServer = "broker.hivemq.com"

local meuid = node.chipid()
local m = mqtt.Client("clientid " .. meuid, 120)

function publica(c)
  c:publish("inf1350-a","alo de " .. meuid,0,0, 
            function(client) print("mandou!") end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  publica(client)
  client:subscribe("inf1350-b", 0, novaInscricao)
end 

m:connect(mqttServer, 1883, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)