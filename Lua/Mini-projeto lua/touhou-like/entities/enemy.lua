local Enemy = {}
Enemy.list = {}

local EventManager = require("core.event_manager")

function Enemy.create(data)
    local enemy = {
        x = data.x,
        y = data.y,

        targetY = data.targetY,

        width = 30,
        height = 30,

        speed = 100,

        hp = data.hp or 30,
        maxHp = data.hp or 30,

        state = "entering",

        timer = 0,

        shootTimer = 0,
        shootInterval = data.shootInterval or 1,
        attackDuration = data.attackDuration or 4,

        pattern = data.pattern or "aimed"
    }

    table.insert(Enemy.list, enemy)
end

function Enemy.update(dt)
    for i = #Enemy.list, 1, -1 do
        local enemy = Enemy.list[i]

        if enemy.state == "dead" then
            table.remove(Enemy.list, i)
        else
            if enemy.state == "entering" then
                enemy.y = enemy.y + enemy.speed * dt

                if enemy.y >= enemy.targetY then
                    enemy.y = enemy.targetY

                    enemy.state = "attacking"

                    enemy.timer = 0
                end

            elseif enemy.state == "attacking" then
                enemy.timer = enemy.timer + dt
                enemy.shootTimer = enemy.shootTimer + dt

                if enemy.shootTimer >=
                    enemy.shootInterval then
                    EventManager.emit("ENEMY_SHOOT", enemy)
                    enemy.shootTimer = 0
                end

                if enemy.timer >= enemy.attackDuration then
                    enemy.state = "leaving"
                end

            elseif enemy.state == "leaving" then
                enemy.y = enemy.y - enemy.speed * dt

                if enemy.y < -50 then
                    table.remove(Enemy.list, i)
                end
            end
        end
    end
end

function Enemy.draw()
    for _, enemy in ipairs(Enemy.list) do
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
    end
end

function Enemy.damage(enemy, damage)
    if enemy.state == "dead" then
        return
    end

    enemy.hp = enemy.hp - damage

    EventManager.emit(
        "ENEMY_DAMAGED",
        {
            enemy = enemy,
            damage = damage
        }
    )


    if enemy.hp <= 0 then
        enemy.hp = 0
        enemy.state = "dead"

        EventManager.emit("ENEMY_DESTROYED",enemy)

    end

end 

return Enemy