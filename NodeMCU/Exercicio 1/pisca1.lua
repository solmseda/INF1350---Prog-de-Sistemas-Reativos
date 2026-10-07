local led1 = 0
local led2 = 6
local meusleds = {led1, led2}
for _,ledi in ipairs (meusleds) do
    gpio.mode(ledi, gpio.OUTPUT)
    gpio.write(ledi, gpio.LOW);
end
local function piscapisca (t)
    for _,led in ipairs (meusleds) do
     gpio.write(led, bit.band(gpio.read(led)+1,1))
    end
end
-- cria e dispara timer
local mytimer = tmr.create()
mytimer:register(1000, tmr.ALARM_AUTO, piscapisca)
mytimer:start()