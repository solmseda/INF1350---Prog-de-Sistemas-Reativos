local EventManager =
    require("core.event_manager")

local StageController = {}

StageController.timer = 0
StageController.events = {}
StageController.nextEvent = 1
StageController.running = false

function StageController.load(stage)

    StageController.timer = 0

    StageController.events =
        stage.events

    StageController.nextEvent = 1

    StageController.running = true

end

function StageController.update(dt)

    if not StageController.running then
        return
    end

    StageController.timer = StageController.timer + dt

    local event = StageController.events[StageController.nextEvent]

    while event ~= nil and StageController.timer >= event.time do
        EventManager.emit(
            event.event,
            event.data
        )

        StageController.nextEvent = StageController.nextEvent + 1

        event = StageController.events[StageController.nextEvent]
    end

    if StageController.nextEvent > #StageController.events then
        StageController.running = false
    end

end

function StageController.reset()
    StageController.timer = 0
    StageController.nextEvent = 1
    StageController.running = false
end

return StageController