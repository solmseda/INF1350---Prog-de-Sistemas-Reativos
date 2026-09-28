local EventManager = require("core.event_manager")

local GameStateMachine = require("core.state_machine")

local StageController = require("stages.stage_controller")

local Stage1 = require("stages.stage1")

local Player = require("entities.player")

local Enemy = require("entities.enemy")

function love.load()

    love.window.setMode(800, 600)

    EventManager.clear()

    GameStateMachine.load()

    Player.load()


    EventManager.on(
        "SPAWN_ENEMY",
        function(data)
            Enemy.create(data)
        end
    )


    EventManager.on(
        "START_GAME",
        function()
            StageController.load(
                Stage1
            )
        end
    )


    EventManager.emit("START_GAME")

end


function love.update(dt)

    local state = GameStateMachine.getState()

    if state == GameStateMachine.states.STAGE then

        StageController.update(dt)

        Player.update(dt)

        Enemy.update(dt)
    end
end


function love.draw()

    local state = GameStateMachine.getState()

    love.graphics.print("State: " .. state, 10, 10)

    love.graphics.print("Lives: " .. Player.lives, 10, 30)

    if state == GameStateMachine.states.STAGE then

        Player.draw()

        Enemy.draw()

    elseif state == GameStateMachine.states.BOSS then
        love.graphics.printf("BOSS", 0, 250, 800, "center")

    elseif state == GameStateMachine.states.GAME_OVER then
        love.graphics.printf("GAME OVER", 0, 250, 800, "center")
    end
end