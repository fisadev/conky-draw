require 'cairo'
require 'conky_draw_config'


function hexa_to_rgb(color, alpha)
    -- ugh, whish this wans't an oneliner
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end


function choose_colors(graph, value)
    -- choose normal or critical colors based on the value and critical threshold
    if value < graph.critical_threshold then
        return {
            background = graph.background,
            foreground = graph.foreground,
            background_alpha = graph.background_alpha,
            foreground_alpha = graph.foreground_alpha,
        }
    else
        return {
            background = graph.background_critical,
            foreground = graph.foreground_critical,
            background_alpha = graph.background_alpha_critical,
            foreground_alpha = graph.foreground_alpha_critical,
        }
    end
end


function draw_bar(display, graph, value)
    -- draw a bar
    -- I used a little bit of trigonometry to be able to draw bars in any direction! :)
    
    -- colors
    local colors = choose_colors(graph, value)
    
    -- dimensions of the full graph
    local x_side = graph.x2 - graph.x1 -- not abs! because later is used as a movement
    local y_side = graph.y2 - graph.y1 -- and the same here
    local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
    local angle = math.atan2(y_side, x_side)

    -- dimensions of the value bar
    local bar_hypotenuse = value * (hypotenuse / graph.max_value)
    local bar_x_side = bar_hypotenuse * math.cos(angle)
    local bar_y_side = bar_hypotenuse * math.sin(angle)

    -- draw background line (full graph)
    cairo_set_source_rgba(display, hexa_to_rgb(colors.background, colors.background_alpha))
    cairo_set_line_width(display, graph.background_thickness);
    cairo_move_to(display, graph.x1, graph.y1);
    cairo_rel_line_to(display, x_side, y_side);
    cairo_stroke(display);

    -- draw foreground line (bar)
    cairo_set_source_rgba(display, hexa_to_rgb(colors.foreground, colors.foreground_alpha))
    cairo_set_line_width(display, graph.foreground_thickness);
    cairo_move_to(display, graph.x1, graph.y1);
    cairo_rel_line_to(display, bar_x_side, bar_y_side);
    cairo_stroke(display);
end


function draw_ring(display, graph, value)
    -- colors
    local colors = choose_colors(graph, value)

    -- the user types degrees, but we need radians
    local start_angle, end_angle = math.rad(graph.ring_end_angle), math.rad(graph.ring_start_angle)

    -- dimensions of the full graph
    local x_side = math.abs(graph.x2 - graph.x1)
    local y_side = math.abs(graph.y2 - graph.y1)
    local radius = math.min(x_side, y_side) / 2.
    local x_center = graph.x1 + x_side / 2.
    local y_center = graph.y1 + y_side / 2.
    local radians = end_angle - start_angle

    -- dimensions of the value bar
    local bar_radians = value * (radians / graph.max_value)

    -- direction of the ring
    local arc_drawer = cairo_arc 
    if start_angle > end_angle then
        arc_drawer = cairo_arc_negative
    end

    -- draw background ring (full graph)
    cairo_set_source_rgba(display, hexa_to_rgb(colors.background, colors.background_alpha))
    cairo_set_line_width(display, graph.background_thickness);
    arc_drawer(display, x_center, y_center, radius, start_angle, end_angle)
    cairo_stroke(display);

    -- draw foreground ring (full graph)
    cairo_set_source_rgba(display, hexa_to_rgb(colors.foreground, colors.foreground_alpha))
    cairo_set_line_width(display, graph.foreground_thickness);
    arc_drawer(display, x_center, y_center, radius, start_angle, start_angle + bar_radians)
    cairo_stroke(display);
end


function fill_defaults(graphs, defaults)
    -- fill each graph table with the missing values, using the defaults
    for i, graph in pairs(graphs) do
        for key, value in pairs(defaults) do
            if graph[key] == nil then
                graph[key] = defaults[key]
            end
        end
    end
end


function conky_main()
    if conky_window == nil then 
        return
    end

    fill_defaults(graphs, defaults)

    local surface = cairo_xlib_surface_create(conky_window.display, 
                                              conky_window.drawable, 
                                              conky_window.visual, 
                                              conky_window.width, 
                                              conky_window.height)
    local display = cairo_create(surface)

    
    if tonumber(conky_parse('${updates}')) > 3 then
        for i, graph in pairs(graphs) do
            local value = tonumber(conky_parse(string.format('${%s}', graph.command))) 

            if value ~= nil then
                if graph.graph_type == 'bar' then
                    draw_bar(display, graph, value)
                elseif graph.graph_type == 'ring' then
                    draw_ring(display, graph, value)
                end
            end
        end
    end

    cairo_surface_destroy(surface)
end

