local EventManager = require("core.event_manager")

local GameStateMachine = require("core.state_machine")

local StageController = require("stages.stage_controller")

local Stage1 = require("stages.stage1")

local Player = require("entities.player")

local Enemy = require("entities.enemy")

local BulletManager = require("bullets.bullet_manager")

local BulletPatterns = require("bullets.bullet_patterns")

local Boss = require("entities.boss")

local waitingForEnemies = false

function love.load()
    love.window.setMode(800, 600)

    EventManager.clear()

    StageController.reset()
    Enemy.clear()
    BulletManager.clear()
    Boss.reset()
    waitingForEnemies = false

    GameStateMachine.load()

    Player.load()


    EventManager.on("SPAWN_ENEMY",
        function(data)
            Enemy.create(data)
        end
    )


    EventManager.on("START_GAME",
        function()
            StageController.load(
                Stage1
            )
        end
    )


    EventManager.emit("START_GAME")

    EventManager.on("ENEMY_SHOOT",
    function(enemy)
        local x = enemy.x + enemy.width / 2
        local y = enemy.y + enemy.height / 2

        if enemy.pattern == "spread" then
            BulletPatterns.spread(x, y, Player, 5, 0.15, 150)
        elseif enemy.pattern == "circle" then
            BulletPatterns.circle(x, y, 12, 120)
        else
            -- "aimed" is also the safe fallback for old stage data that
            -- does not define a pattern.
            BulletPatterns.aimed(x, y, Player, 150)
        end
    end
    )

    EventManager.on("ENEMY_DESTROYED",
        function(enemy)
            print("Enemy destroyed:", enemy.x,enemy.y)
        end
    )

    EventManager.on(
        "STAGE_WAVES_FINISHED",
        function()
            waitingForEnemies = true
        end
    )

    EventManager.on(
        "STAGE_FINISHED",
        function()
            BulletManager.clear()
            Boss.spawn()
        end
    )

    EventManager.on(
        "BOSS_SHOOT",
        function(data)
            local boss =data.boss

            local x = boss.x + boss.width / 2

            local y = boss.y + boss.height / 2

            if data.pattern == "ring" then
                BulletPatterns.rotatingCircle(x, y, 24, 110, data.angle or 0)

            elseif data.pattern == "aimed" then
                BulletPatterns.spread(x, y, Player, 5, 0.12, 180)

            elseif data.pattern == "spiral" then
                BulletPatterns.spiral(x, y, 4, data.angle or 0, 120)

            elseif data.pattern == "spread" then
                BulletPatterns.spread(x, y, Player, 7, 0.10, 180)

            elseif data.pattern == "double_spiral" then
                BulletPatterns.doubleSpiral(x, y, 3, data.angle or 0, 140)

            elseif data.pattern == "multi_ring" then
                BulletPatterns.multiRing(x, y, 20, 3, 100)
            end
        end
    )

    EventManager.on(
        "BOSS_PHASE_CHANGED",
        function(data)
            BulletManager.clear()

            print("Nova fase:", data.phase)
        end
    )
end

function Enemy.clear()
    Enemy.list = {}
end

function love.keypressed(key)
    local state = GameStateMachine.getState()
    local gameEnded = state == GameStateMachine.states.GAME_OVER
        or state == GameStateMachine.states.VICTORY

    if key == "r" and gameEnded then
        love.load()
    end
end

function love.update(dt)
    local state = GameStateMachine.getState()

    if state == GameStateMachine.states.STAGE then
        StageController.update(dt)

        Player.update(dt)

        Enemy.update(dt)

        BulletManager.update(dt, Player, Enemy, Boss)

        if waitingForEnemies and #Enemy.list == 0 then
            waitingForEnemies = false
            EventManager.emit("STAGE_FINISHED")
        end
        
    elseif state == GameStateMachine.states.BOSS then
        Player.update(dt)

        Boss.update(dt)

        BulletManager.update(dt, Player, Enemy, Boss)
    end
end


function love.draw()
    local state = GameStateMachine.getState()

    love.graphics.print("State: " .. state, 10, 10)

    love.graphics.print("Lives: " .. Player.lives, 10, 30)

    if state == GameStateMachine.states.STAGE then

        Player.draw()

        Enemy.draw()

        BulletManager.draw()

    elseif state == GameStateMachine.states.BOSS then
        Player.draw()
        Boss.draw()
        BulletManager.draw()

    elseif state == GameStateMachine.states.GAME_OVER then
        love.graphics.printf("GAME OVER", 0, 250, 800, "center")
        love.graphics.printf("Pressione R para reiniciar", 0, 280, 800, "center")

    elseif state ==
    GameStateMachine.states.VICTORY then

    love.graphics.printf("VICTORY", 0, 250, 800, "center")
    love.graphics.printf("Pressione R para reiniciar", 0, 280, 800, "center")
    end
end
