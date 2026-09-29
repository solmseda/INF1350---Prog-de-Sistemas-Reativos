local EventManager = require("core.event_manager")
local BulletManager = require("bullets.bullet_manager")

local Player = {}

Player.x = 400
Player.y = 500

Player.speed = 250
Player.focusSpeed = 120

Player.radius = 8

Player.lives = 3

Player.state = "normal"

Player.invincibleTimer = 0

Player.shootTimer = 0
Player.shootInterval = 0.12

function Player.load()

    Player.x = 400
    Player.y = 500

    Player.lives = 3

    Player.shootTimer = 0

    Player.state = "normal"

end

function Player.update(dt)

    if Player.state == "dead" then
        return
    end

    local speed = Player.speed

    if love.keyboard.isDown("lshift") then

        Player.state = "focus"

        speed = Player.focusSpeed

    elseif Player.state ~= "invincible" then

        Player.state = "normal"

    end

    if love.keyboard.isDown("left") then
        Player.x = Player.x - speed * dt
    end

    if love.keyboard.isDown("right") then
        Player.x = Player.x + speed * dt
    end

    if love.keyboard.isDown("up") then
        Player.y = Player.y - speed * dt
    end

    if love.keyboard.isDown("down") then
        Player.y = Player.y + speed * dt
    end

    Player.shootTimer = Player.shootTimer - dt

    if love.keyboard.isDown("z") and Player.shootTimer <= 0 then
        Player.shoot()
        Player.shootTimer = Player.shootInterval
    end

    if Player.state == "invincible" then
        Player.invincibleTimer = Player.invincibleTimer - dt

        if Player.invincibleTimer <= 0 then
            Player.state = "normal"
        end

    end

end

function Player.shoot()
    local bulletSpeed = 500
    local damage = 10

    BulletManager.create(Player.x, Player.y - 15, -math.pi / 2, bulletSpeed, "player", damage)
end

function Player.hit()

    if Player.state == "invincible" then
        return
    end

    Player.lives =
        Player.lives - 1

    EventManager.emit("PLAYER_HIT")

    if Player.lives <= 0 then
        Player.state = "dead"
        EventManager.emit("PLAYER_GAME_OVER")
        return
    end

    Player.state = "invincible"

    Player.invincibleTimer = 2
end

function Player.draw()

    love.graphics.circle("fill", Player.x, Player.y, 12)

    if Player.state == "focus" then
        love.graphics.circle("line", Player.x, Player.y, Player.radius)
    end
end

return Player