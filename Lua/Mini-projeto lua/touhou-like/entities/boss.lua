local EventManager = require("core.event_manager")

local Boss = {}

Boss.active = false

Boss.x = 400
Boss.y = -100

Boss.width = 60
Boss.height = 60

Boss.targetY = 100
Boss.speed = 100

Boss.maxHp = 1000
Boss.hp = 1000

Boss.state = "inactive"

Boss.attackTimer = 0

Boss.moveSpeed = 100

Boss.direction = 1

Boss.minX = 100
Boss.maxX = 700

Boss.targetX = nil

Boss.patternAngle = 0

Boss.secondaryAttackTimer = 0

function Boss.spawn()
    Boss.active = true

    Boss.x = 400 - Boss.width / 2
    Boss.y = -100

    Boss.hp = Boss.maxHp

    Boss.state = "entering"

    Boss.attackTimer = 0

    Boss.direction = 1

    Boss.patternAngle = 0

    Boss.attackTimer = 0
    Boss.secondaryAttackTimer = 0

    Boss.targetX = nil
end


function Boss.update(dt)
    if not Boss.active then
        return
    end

    if Boss.state == "entering" then

        Boss.y = Boss.y + Boss.speed * dt

        if Boss.y >= Boss.targetY then
            Boss.y = Boss.targetY

            Boss.changeState("phase1")
        end

    elseif Boss.state == "phase1" then
        Boss.updatePhase1(dt)

    elseif Boss.state == "phase2" then
        Boss.updatePhase2(dt)

    elseif Boss.state == "phase3" then
        Boss.updatePhase3(dt)

    elseif Boss.state == "defeated" then
        -- futuramente:
        -- animação de explosão
    end
end

function Boss.changeState(newState)
    print("Boss:",Boss.state, "->", newState)

    Boss.state = newState
    Boss.attackTimer = 0
    Boss.secondaryAttackTimer = 0
    Boss.patternAngle = 0
    Boss.targetX = nil

    EventManager.emit(
        "BOSS_PHASE_CHANGED",
        {
            boss = Boss,
            phase = newState
        }
    )
end

function Boss.updatePhase1(dt)
    Boss.moveHorizontal(dt, 80)

    Boss.attackTimer = Boss.attackTimer + dt

    Boss.secondaryAttackTimer = Boss.secondaryAttackTimer + dt

    -- Anel
    if Boss.attackTimer >= 1.2 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "ring",
                angle = Boss.patternAngle
            }
        )
        Boss.patternAngle = Boss.patternAngle + 0.15

        Boss.attackTimer = 0

    end

    -- Ataque direcionado
    if Boss.secondaryAttackTimer >= 2 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "aimed"
            }
        )
        Boss.secondaryAttackTimer = 0
    end
end

function Boss.updatePhase2(dt)
    Boss.moveToTarget(dt, 120)

    Boss.attackTimer = Boss.attackTimer + dt

    Boss.secondaryAttackTimer = Boss.secondaryAttackTimer + dt


    -- Espiral
    if Boss.attackTimer >= 0.12 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "spiral",
                angle = Boss.patternAngle
            }
        )

        Boss.patternAngle =Boss.patternAngle + 0.12
        Boss.attackTimer = 0
    end

    -- Spread
    if Boss.secondaryAttackTimer >= 2.5 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "spread"
            }
        )

        Boss.secondaryAttackTimer = 0
    end
end

function Boss.updatePhase3(dt)
    Boss.moveHorizontal(dt, 160)

    Boss.attackTimer =Boss.attackTimer + dt
    Boss.secondaryAttackTimer = Boss.secondaryAttackTimer + dt

    -- Espiral dupla
    if Boss.attackTimer >= 0.10 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "double_spiral",
                angle = Boss.patternAngle
            }
        )
        Boss.patternAngle = Boss.patternAngle + 0.10
        Boss.attackTimer = 0
    end

    -- Ataque pesado
    if Boss.secondaryAttackTimer >= 3 then
        EventManager.emit(
            "BOSS_SHOOT",
            {
                boss = Boss,
                pattern = "multi_ring"
            }
        )
        Boss.secondaryAttackTimer = 0
    end
end

function Boss.damage(damage)

    if not Boss.active then
        return
    end

    if Boss.state == "entering"
        or Boss.state == "defeated" then
        return
    end


    Boss.hp =
        Boss.hp - damage


    EventManager.emit(
        "BOSS_DAMAGED",
        {
            damage = damage,
            hp = Boss.hp
        }
    )


    if Boss.hp <= 0 then

        Boss.hp = 0

        Boss.changeState(
            "defeated"
        )

        Boss.active = false

        EventManager.emit(
            "BOSS_DEFEATED"
        )

        return

    end


    if Boss.hp <= Boss.maxHp * 0.35 and Boss.state ~= "phase3" then
        Boss.changeState("phase3")

        return
    end

    if Boss.hp <= Boss.maxHp * 0.70 and Boss.state == "phase1" then
        Boss.changeState("phase2")

    end
end

function Boss.moveHorizontal(dt, speed)
    Boss.x = Boss.x + Boss.direction * speed * dt

    if Boss.x >= Boss.maxX - Boss.width then
        Boss.x = Boss.maxX - Boss.width
        Boss.direction = -1

    elseif Boss.x <= Boss.minX then
        Boss.x = Boss.minX

        Boss.direction = 1
    end
end

function Boss.chooseTarget()

    Boss.targetX = love.math.random(Boss.minX, Boss.maxX - Boss.width)
end

function Boss.moveToTarget(dt, speed)
    if Boss.targetX == nil then
        Boss.chooseTarget()
    end

    local distance = Boss.targetX - Boss.x

    if math.abs(distance) < 5 then
        Boss.x = Boss.targetX

        Boss.chooseTarget()
        return
    end

    if distance > 0 then
        Boss.x = Boss.x + speed * dt
    else
        Boss.x = Boss.x - speed * dt
    end
end

function Boss.draw()

    if not Boss.active then
        return
    end

    love.graphics.rectangle("fill", Boss.x, Boss.y, Boss.width, Boss.height)

    local barX = 100
    local barY = 30
    local barWidth = 600
    local barHeight = 15

    local hpPercent =Boss.hp / Boss.maxHp

    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)

    love.graphics.rectangle("fill", barX, barY, barWidth * hpPercent, barHeight)

    love.graphics.print(
        "BOSS HP: "
        .. Boss.hp
        .. "/"
        .. Boss.maxHp,
        barX,
        barY + 20
    )

end

return Boss
