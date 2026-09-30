local EventManager = require("core.event_manager")

local GameStateMachine = {}

GameStateMachine.states = {
    MENU = "menu",
    STAGE = "stage",
    BOSS = "boss",
    GAME_OVER = "game_over",
    VICTORY = "victory"
}

GameStateMachine.currentState = nil

function GameStateMachine.load()
    GameStateMachine.currentState = GameStateMachine.states.MENU

    EventManager.on("START_GAME", function()
        GameStateMachine.changeState(GameStateMachine.states.STAGE)
    end)

    EventManager.on("STAGE_FINISHED", function()
        GameStateMachine.changeState(GameStateMachine.states.BOSS)
    end)

    EventManager.on("PLAYER_GAME_OVER", function()
        GameStateMachine.changeState(GameStateMachine.states.GAME_OVER)
    end)

    EventManager.on("BOSS_DEFEATED", function()
        GameStateMachine.changeState(GameStateMachine.states.VICTORY)
    end)
end

function GameStateMachine.changeState(newState)
    print("Game State:", GameStateMachine.currentState, "->", newState)

    GameStateMachine.currentState = newState
end

function GameStateMachine.getState()
    return GameStateMachine.currentState
end

return GameStateMachine