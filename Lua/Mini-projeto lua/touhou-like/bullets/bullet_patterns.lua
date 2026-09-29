local BulletManager = require("bullets.bullet_manager")
local BulletPatterns = {}

function BulletPatterns.single(x, y, angle, speed)
    BulletManager.create(x, y, angle, speed)
end


function BulletPatterns.circle(x, y, amount, speed)
    local fullCircle = math.pi * 2

    for i = 0, amount - 1 do
        local angle = (fullCircle / amount) * i
        BulletManager.create(x, y, angle, speed)
    end
end


function BulletPatterns.aimed(x, y, player, speed)
    local angle = math.atan2(player.y - y, player.x - x)
    BulletManager.create(x, y, angle, speed)
end


function BulletPatterns.spread(x, y, player, amount, spacing, speed)
    local baseAngle = math.atan2(player.y - y, player.x - x)
    local middle = (amount - 1) / 2

    for i = 0, amount - 1 do
        local offset = (i - middle) * spacing
        BulletManager.create(x, y, baseAngle + offset, speed)
    end
end


return BulletPatterns