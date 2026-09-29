local Stage1 = {}

Stage1.events = {
    {
        time = 2,
        event = "SPAWN_ENEMY",
        data = {
            x = 100,
            y = -30,
            targetY = 140,

            hp = 30,
            pattern = "aimed",

            shootInterval = 1.5,
            attackDuration = 4
        }
    },

    {
        time = 3,
        event = "SPAWN_ENEMY",
        data = {
            x = 350,
            y = -30,
            targetY = 120,

            hp = 30,
            pattern = "aimed",

            shootInterval = 1.5,
            attackDuration = 4
        }
    },

    {
        time = 4,
        event = "SPAWN_ENEMY",
        data = {
            x = 650,
            y = -30,
            targetY = 140,

            hp = 30,
            pattern = "aimed",

            shootInterval = 1.5,
            attackDuration = 4
        }
    },

    {
        time = 12,
        event = "SPAWN_ENEMY",
        data = {
            x = 100,
            y = -30,
            targetY = 120,

            hp = 40,
            pattern = "aimed",

            shootInterval = 1.0,
            attackDuration = 5
        }
    },

    {
        time = 12.5,
        event = "SPAWN_ENEMY",
        data = {
            x = 250,
            y = -30,
            targetY = 170,

            hp = 40,
            pattern = "aimed",

            shootInterval = 1.0,
            attackDuration = 5
        }
    },

    {
        time = 13,
        event = "SPAWN_ENEMY",
        data = {
            x = 400,
            y = -30,
            targetY = 120,

            hp = 40,
            pattern = "aimed",

            shootInterval = 1.0,
            attackDuration = 5
        }
    },

    {
        time = 13.5,
        event = "SPAWN_ENEMY",
        data = {
            x = 550,
            y = -30,
            targetY = 170,

            hp = 40,
            pattern = "aimed",

            shootInterval = 1.0,
            attackDuration = 5
        }
    },

    {
        time = 14,
        event = "SPAWN_ENEMY",
        data = {
            x = 700,
            y = -30,
            targetY = 120,

            hp = 40,
            pattern = "aimed",

            shootInterval = 1.0,
            attackDuration = 5
        }
    },

    {
        time = 22,
        event = "SPAWN_ENEMY",
        data = {
            x = 150,
            y = -30,
            targetY = 150,

            hp = 60,
            pattern = "spread",

            shootInterval = 1.5,
            attackDuration = 6
        }
    },

    {
        time = 23,
        event = "SPAWN_ENEMY",
        data = {
            x = 400,
            y = -30,
            targetY = 100,

            hp = 70,
            pattern = "spread",

            shootInterval = 1.5,
            attackDuration = 6
        }
    },

    {
        time = 24,
        event = "SPAWN_ENEMY",
        data = {
            x = 650,
            y = -30,
            targetY = 150,

            hp = 60,
            pattern = "spread",

            shootInterval = 1.5,
            attackDuration = 6
        }
    },

    {
        time = 32,
        event = "SPAWN_ENEMY",
        data = {
            x = 200,
            y = -30,
            targetY = 130,

            hp = 80,
            pattern = "circle",

            shootInterval = 2.0,
            attackDuration = 7
        }
    },

    {
        time = 33,
        event = "SPAWN_ENEMY",
        data = {
            x = 600,
            y = -30,
            targetY = 130,

            hp = 80,
            pattern = "circle",

            shootInterval = 2.0,
            attackDuration = 7
        }
    },

    {
        time = 41,
        event = "SPAWN_ENEMY",
        data = {
            x = 100,
            y = -30,
            targetY = 160,

            hp = 50,
            pattern = "aimed",

            shootInterval = 0.8,
            attackDuration = 7
        }
    },

    {
        time = 42,
        event = "SPAWN_ENEMY",
        data = {
            x = 300,
            y = -30,
            targetY = 110,

            hp = 70,
            pattern = "spread",

            shootInterval = 1.2,
            attackDuration = 7
        }
    },

    {
        time = 43,
        event = "SPAWN_ENEMY",
        data = {
            x = 500,
            y = -30,
            targetY = 110,

            hp = 70,
            pattern = "spread",

            shootInterval = 1.2,
            attackDuration = 7
        }
    },

    {
        time = 44,
        event = "SPAWN_ENEMY",
        data = {
            x = 700,
            y = -30,
            targetY = 160,

            hp = 50,
            pattern = "aimed",

            shootInterval = 0.8,
            attackDuration = 7
        }
    },

    {
        time = 51,
        event = "SPAWN_ENEMY",
        data = {
            x = 100,
            y = -30,
            targetY = 120,

            hp = 60,
            pattern = "aimed",

            shootInterval = 0.7,
            attackDuration = 7
        }
    },

    {
        time = 51.5,
        event = "SPAWN_ENEMY",
        data = {
            x = 250,
            y = -30,
            targetY = 170,

            hp = 80,
            pattern = "spread",

            shootInterval = 1.0,
            attackDuration = 7
        }
    },

    {
        time = 52,
        event = "SPAWN_ENEMY",
        data = {
            x = 400,
            y = -30,
            targetY = 100,

            hp = 120,
            pattern = "circle",

            shootInterval = 1.5,
            attackDuration = 7
        }
    },

    {
        time = 52.5,
        event = "SPAWN_ENEMY",
        data = {
            x = 550,
            y = -30,
            targetY = 170,

            hp = 80,
            pattern = "spread",

            shootInterval = 1.0,
            attackDuration = 7
        }
    },

    {
        time = 53,
        event = "SPAWN_ENEMY",
        data = {
            x = 700,
            y = -30,
            targetY = 120,

            hp = 60,
            pattern = "aimed",

            shootInterval = 0.7,
            attackDuration = 7
        }
    },

    {
        time = 60,
        event = "STAGE_WAVES_FINISHED"
    }

}

return Stage1