local EventManager = require("core.event_manager")

local GameStateMachine = require("core.state_machine")

local StageController = require("stages.stage_controller")

local Stage1 = require("stages.stage1")

local Player = require("entities.player")

local Enemy = require("entities.enemy")

local BulletManager = require("bullets.bullet_manager")

local BulletPatterns = require("bullets.bullet_patterns")

local Boss = require("entities.boss")

function love.load()
    love.window.setMode(800, 600)

    EventManager.clear()

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
        BulletPatterns.aimed(
            enemy.x + enemy.width / 2, 
            enemy.y + enemy.height / 2,
            Player,
            150
        )
    end
    )

    EventManager.on("ENEMY_DESTROYED",
        function(enemy)
            print("Enemy destroyed:", enemy.x,enemy.y)
        end
    )

    EventManager.on(
        "STAGE_FINISHED",
        function()
            Enemy.clear()
            BulletManager.clear()
            Boss.spawn()
        end
    )

    EventManager.on(
        "BOSS_SHOOT",
        function(data)

            local boss =data.boss

            local x = boss.x + boss.width / 2

            local y = boss.y + boss.height

            if data.pattern == "circle" then

                BulletPatterns.circle(x, y, 24, 100)

            elseif data.pattern == "spread" then
                BulletPatterns.spread(x, y, Player, 7, 0.12, 170)

            elseif data.pattern == "final" then
                BulletPatterns.circle( x, y, 32, 130)

                BulletPatterns.spread(x, y, Player, 5, 0.15, 200)
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

function love.update(dt)
    local state = GameStateMachine.getState()

    if state == GameStateMachine.states.STAGE then
        StageController.update(dt)

        Player.update(dt)

        Enemy.update(dt)

        BulletManager.update(dt, Player, Enemy, Boss)
        
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

    elseif state ==
    GameStateMachine.states.VICTORY then

    love.graphics.printf("VICTORY", 0, 250, 800, "center")
    end
end
