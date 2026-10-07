local led1 = 0
local led2 = 6
local function disparapiscapisca (led, tempo)
    local function piscapisca(timer)
        gpio.write(led, bit.band(gpio.read(led)+1,1))
    end
    -- coloca o pino dos leds em modo de saida
    gpio.mode(led, gpio.OUTPUT)
    -- apaga o led
    gpio.write(led, gpio.LOW);
    tmr.create():alarm(tempo, tmr.ALARM_AUTO, piscapisca)
end
-- cada led pisca em tempo diferente
disparapiscapisca (led1, 500)
disparapiscapisca (led2, 750)