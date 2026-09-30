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

Boss.moveSpeed = 100

Boss.direction = 1

Boss.minX = 100
Boss.maxX = 700

Boss.targetX = nil

Boss.patternAngle = 0

Boss.attackCoroutines = {}

local function wait(seconds)
    local elapsed = 0

    while elapsed < seconds do
        elapsed = elapsed + (coroutine.yield() or 0)
    end
end

local function createAttackCoroutine(phase, interval, attack)
    return coroutine.create(function()
        while Boss.active and Boss.state == phase do
            wait(interval)

            if Boss.active and Boss.state == phase then
                attack()
            end
        end
    end)
end

function Boss.reset()
    Boss.active = false
    Boss.x = 400 - Boss.width / 2
    Boss.y = -100
    Boss.hp = Boss.maxHp
    Boss.state = "inactive"
    Boss.attackCoroutines = {}
    Boss.patternAngle = 0
    Boss.targetX = nil
    Boss.direction = 1
end

function Boss.spawn()
    Boss.active = true

    Boss.x = 400 - Boss.width / 2
    Boss.y = -100

    Boss.hp = Boss.maxHp

    Boss.state = "entering"

    Boss.direction = 1

    Boss.patternAngle = 0

    Boss.attackCoroutines = {}

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
        Boss.moveHorizontal(dt, 80)
        Boss.updateAttackCoroutines(dt)

    elseif Boss.state == "phase2" then
        Boss.moveToTarget(dt, 120)
        Boss.updateAttackCoroutines(dt)

    elseif Boss.state == "phase3" then
        Boss.moveHorizontal(dt, 160)
        Boss.updateAttackCoroutines(dt)

    elseif Boss.state == "defeated" then
        -- futuramente:
        -- animação de explosão
    end
end

function Boss.changeState(newState)
    print("Boss:",Boss.state, "->", newState)

    Boss.state = newState
    Boss.patternAngle = 0
    Boss.targetX = nil

    Boss.startAttackCoroutines(newState)

    EventManager.emit(
        "BOSS_PHASE_CHANGED",
        {
            boss = Boss,
            phase = newState
        }
    )
end

function Boss.emitAttack(pattern, angle)
    EventManager.emit(
        "BOSS_SHOOT",
        {
            boss = Boss,
            pattern = pattern,
            angle = angle
        }
    )
end

function Boss.startAttackCoroutines(phase)
    Boss.attackCoroutines = {}

    local function add(interval, attack)
        local routine = createAttackCoroutine(phase, interval, attack)
        table.insert(Boss.attackCoroutines, routine)

        -- Inicia a corrotina e a deixa pausada no primeiro wait.
        local ok, message = coroutine.resume(routine)
        if not ok then
            error(message)
        end
    end

    if phase == "phase1" then
        add(1.2, function()
            Boss.emitAttack("ring", Boss.patternAngle)
            Boss.patternAngle = Boss.patternAngle + 0.15
        end)

        add(2, function()
            Boss.emitAttack("aimed")
        end)

    elseif phase == "phase2" then
        add(0.12, function()
            Boss.emitAttack("spiral", Boss.patternAngle)
            Boss.patternAngle = Boss.patternAngle + 0.12
        end)

        add(2.5, function()
            Boss.emitAttack("spread")
        end)

    elseif phase == "phase3" then
        add(0.10, function()
            Boss.emitAttack("double_spiral", Boss.patternAngle)
            Boss.patternAngle = Boss.patternAngle + 0.10
        end)

        add(3, function()
            Boss.emitAttack("multi_ring")
        end)
    end
end

function Boss.updateAttackCoroutines(dt)
    for _, routine in ipairs(Boss.attackCoroutines) do
        if coroutine.status(routine) == "suspended" then
            local ok, message = coroutine.resume(routine, dt)

            if not ok then
                error(message)
            end
        end
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

    love.graphics.print("BOSS HP: " .. Boss.hp .. "/" .. Boss.maxHp, barX, barY + 20)
end

return Boss
