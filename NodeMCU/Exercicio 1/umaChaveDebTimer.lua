local led1 = 0
local sw1 = 3
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
function trocaled(level,timestamp)
    gpio.trig(sw1)
    gpio.write(led1, bit.band(gpio.read(led1)+1,1))
    tmr.create():alarm(200, tmr.ALARM_SINGLE,
        function(t)
        gpio.trig(sw1, "down", trocaled)
        end)
end
gpio.trig(sw1, "down", trocaled)