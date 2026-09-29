local BulletManager = {}

BulletManager.bullets = {}


function BulletManager.create(x, y, angle, speed, owner, damage)
    local bullet = {
        x = x,
        y = y,

        angle = angle,
        speed = speed,

        radius = 5,

        owner = owner or "enemy",
        damage = damage or 1
    }

    table.insert(BulletManager.bullets, bullet)
end


function BulletManager.update(dt, player, Enemy, Boss)
    local bullets = BulletManager.bullets

    for i = #bullets, 1, -1 do

        -- Um evento (por exemplo, a troca de fase do chefe) pode chamar
        -- BulletManager.clear() enquanto este loop ainda está em execução.
        if bullets ~= BulletManager.bullets then
            return
        end

        local bullet = bullets[i]

        -- mvoimentação do tiro
        bullet.x = bullet.x + math.cos(bullet.angle) * bullet.speed * dt

        bullet.y = bullet.y + math.sin(bullet.angle) * bullet.speed * dt

        local removeBullet = false


        -- tiro do inimigo no jogador

        if bullet.owner == "enemy" then
            if BulletManager.checkCircleCollision(
                bullet.x,
                bullet.y,
                bullet.radius,
                player.x,
                player.y,
                player.radius
            ) then
                player.hit()

                removeBullet = true
            end

        end

        -- tiro do jogador no inimigo
        if bullet.owner == "player" then
            -- tiro no inimigo
            for j = #Enemy.list, 1, -1 do
                local enemy = Enemy.list[j]

                if BulletManager.checkEnemyCollision(bullet, enemy) then
                    Enemy.damage(enemy, bullet.damage)

                    removeBullet = true
                    break
                end
            end

            -- Tiro no Boss
            if not removeBullet and Boss.active then
                if BulletManager.checkBossCollision(bullet,Boss) then
                    Boss.damage(bullet.damage)

                    removeBullet = true
                end
            end
        end

        -- tiro saiu da tela
        if bullet.x < -50 or bullet.x > 850 or bullet.y < -50 or bullet.y > 650 then
            removeBullet = true
        end

        if removeBullet then
            table.remove(bullets,i)
        end
    end
end


function BulletManager.checkCircleCollision(x1, y1, r1,x2, y2, r2)
    local dx = x1 - x2
    local dy = y1 - y2

    local radius = r1 + r2

    return dx * dx + dy * dy <= radius * radius
end


function BulletManager.checkEnemyCollision(bullet, enemy)
    return bullet.x >= enemy.x
        and bullet.x <= enemy.x + enemy.width
        and bullet.y >= enemy.y
        and bullet.y <= enemy.y + enemy.height
end

function BulletManager.checkBossCollision(bullet,boss)
    return bullet.x >= boss.x
        and bullet.x <= boss.x + boss.width
        and bullet.y >= boss.y
        and bullet.y <= boss.y + boss.height
end


function BulletManager.draw()
    for _, bullet in ipairs(BulletManager.bullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.radius)
    end
end


function BulletManager.clear()
    BulletManager.bullets = {}
end

return BulletManager
