-- Define your visual elements here
-- For a complete list on the possible elements and their properties, go
-- to https://github.com/fisadev/conky-draw/
-- (and be sure to use the lastest version)

elements = {
    {
        kind = 'line',
        from = {x=200, y=200},
        to = {x=300, y=400},

        color = 0xFF00FF,
        alpha = 1,
        thickness = 3,
    },
    {
        kind = 'ring',
        center = {x=200, y=200},
        radius = 50,

        color = 0xFF00FF,
        alpha = 1,
        thickness = 3,

        start_angle = 270,
        end_angle = 90,
    },
    {
        kind = 'bar_graph',
        conky_value = 'cpu cpu0',
        from = {x=200, y=200},
        to = {x=300, y=300},
    },
    {
        kind = 'ring_graph',
        conky_value = 'cpu cpu0',
        center = {x=200, y=200},
        radius = 80,

        start_angle = 0,
        end_angle = 270,
    },
}
