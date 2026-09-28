local Enemy = {}

Enemy.list = {}

function Enemy.create(data)
    local enemy = {
        x = data.x,
        y = data.y,

        targetY = data.targetY,

        width = 30,
        height = 30,

        speed = 100,

        state = "entering",

        timer = 0
    }

    table.insert(Enemy.list, enemy)
end

function Enemy.update(dt)
    for i = #Enemy.list, 1, -1 do

        local enemy = Enemy.list[i]

        if enemy.state == "entering" then

            enemy.y = enemy.y + enemy.speed * dt

            if enemy.y >= enemy.targetY then
                enemy.y = enemy.targetY

                enemy.state = "attacking"

                enemy.timer = 0
            end

        elseif enemy.state == "attacking" then
            enemy.timer = enemy.timer + dt

            if enemy.timer >= 3 then
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

function Enemy.draw()
    for _, enemy in ipairs(Enemy.list) do
        love.graphics.rectangle(
            "fill",
            enemy.x,
            enemy.y,
            enemy.width,
            enemy.height
        )
    end
end

return Enemy