-- Default values for graphs when no provided.
-- Change them if you want, byt DON'T remove them! 
defaults = {
    max_value = 100.,
    critical_threshold = 90.,

    background = 0x00FF6E,
    foreground = 0x00FF6E,
    background_alpha = 0.2,
    foreground_alpha = 1.0,

    background_critical = 0xFA002E,
    foreground_critical = 0xFA002E,
    background_alpha_critical = 0.2,
    foreground_alpha_critical = 1.0,

    background_thickness = 5,
    foreground_thickness = 5,

    ring_start_angle = 0, 
    ring_end_angle = 360,
}

-- Define your graphs here
-- Each graph *must* define:
--    command (conky value to display)
--    graph_type ('bar' or 'ring')
--    x1, y1 (start point. On bar graphs, beginin of the graph. On ring graphs, upper left corner)
--    x2, y2 (end point. On bar graphs, end of the graph. On ring graphs, lower right corner)
-- And you can also re-define any of the default values for each specific graph
graphs = {
    -- bar examples
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 20, y1 = 50,
        x2 = 20, y2 = 100,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 30, y1 = 100,
        x2 = 30, y2 = 50,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 40, y1 = 50,
        x2 = 100, y2 = 50,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 100, y1 = 60,
        x2 = 40, y2 = 60,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 50, y1 = 70,
        x2 = 100, y2 = 100,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 50, y1 = 100,
        x2 = 100, y2 = 70,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 170, y1 = 70,
        x2 = 110, y2 = 100,
    },
    {
        command = 'cpu cpu0', graph_type = 'bar',
        x1 = 170, y1 = 100,
        x2 = 110, y2 = 70,
    },

    -- ring examples
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 200, y1 = 50,
        x2 = 250, y2 = 100,
    },
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 270, y1 = 50,
        x2 = 320, y2 = 100,
        ring_start_angle = 360, ring_end_angle = 0,
    },
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 200, y1 = 120,
        x2 = 250, y2 = 170,
        ring_start_angle = 0, ring_end_angle = 100,
    },
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 270, y1 = 120,
        x2 = 320, y2 = 170,
        ring_start_angle = 100, ring_end_angle = 0,
    },
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 200, y1 = 200,
        x2 = 250, y2 = 250,
        ring_start_angle = 0, ring_end_angle = 250,
    },
    {
        command = 'cpu cpu0', graph_type = 'ring',
        x1 = 270, y1 = 200,
        x2 = 320, y2 = 250,
        ring_start_angle = 250, ring_end_angle = 0,
    },
}
