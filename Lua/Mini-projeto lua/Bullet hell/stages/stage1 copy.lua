local Stage1 = {}

Stage1.events = {

    {
        time = 2,

        event = "SPAWN_ENEMY",

        data = {
            x = 100,
            y = -30,
            targetY = 150
        }
    },

    {
        time = 3,

        event = "SPAWN_ENEMY",

        data = {
            x = 250,
            y = -30,
            targetY = 180
        }
    },

    {
        time = 4,

        event = "SPAWN_ENEMY",

        data = {
            x = 400,
            y = -30,
            targetY = 150
        }
    },

    {
        time = 8,

        event = "SPAWN_ENEMY",

        data = {
            x = 550,
            y = -30,
            targetY = 200
        }
    },

    {
        time = 12,

        event = "SPAWN_ENEMY",

        data = {
            x = 700,
            y = -30,
            targetY = 160
        }
    },

    {
        time = 20,

        event = "STAGE_FINISHED"
    }

}

return Stage1