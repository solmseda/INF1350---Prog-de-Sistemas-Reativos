local BulletManager = require("bullets.bullet_manager")
local BulletPatterns = {}

function BulletPatterns.single(x, y, angle, speed)
    BulletManager.create(x, y, angle, speed)
end


function BulletPatterns.circle(x, y, amount, speed)
    local fullCircle = math.pi * 2

    for i = 0, amount - 1 do
        local angle = (fullCircle / amount) * i
        BulletManager.create(x, y, angle, speed, "enemy", 1)
    end
end


function BulletPatterns.aimed(x, y, player, speed)
    local angle = math.atan2(player.y - y, player.x - x)
    BulletManager.create(x, y, angle, speed, "enemy", 1)
end


function BulletPatterns.spread(x, y, player, amount, spacing, speed)
    local baseAngle = math.atan2(player.y - y, player.x - x)
    local middle = (amount - 1) / 2

    for i = 0, amount - 1 do
        local offset = (i - middle) * spacing
        BulletManager.create(x, y, baseAngle + offset, speed, "enemy", 1)
    end
end

-- Círculo com rotação inicial
function BulletPatterns.rotatingCircle(
    x,
    y,
    amount,
    speed,
    rotation
)

    local fullCircle = math.pi * 2

    for i = 0, amount - 1 do

        local angle =
            rotation
            + (fullCircle / amount) * i

        BulletManager.create(
            x,
            y,
            angle,
            speed,
            "enemy",
            1
        )

    end

end


-- Vários anéis com velocidades diferentes
function BulletPatterns.multiRing(
    x,
    y,
    amount,
    rings,
    baseSpeed
)

    for ring = 1, rings do

        local speed =
            baseSpeed + (ring - 1) * 35

        local rotation =
            (ring - 1) * 0.1

        BulletPatterns.rotatingCircle(
            x,
            y,
            amount,
            speed,
            rotation
        )

    end

end

function BulletPatterns.spiral(x, y, arms, angle, speed)
    local fullCircle = math.pi * 2

    for i = 0, arms - 1 do
        local bulletAngle = angle + (fullCircle / arms) * i

        BulletManager.create(x, y, bulletAngle, speed, "enemy", 1)
    end
end

function BulletPatterns.doubleSpiral(x,y,arms, angle, speed)
    BulletPatterns.spiral(x, y, arms, angle, speed)

    BulletPatterns.spiral(x, y, arms, -angle, speed)
end

return BulletPatterns