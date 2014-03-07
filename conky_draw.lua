require 'cairo'
require 'conky_draw_config'


function hexa_to_rgb(color, alpha)
    -- ugh, whish this wans't an oneliner
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end


function get_conky_value(conky_value, is_number)
    -- evaluate a conky template to get its current value
    -- example: "cpu cpu0" --> 20

    local value = conky_parse(string.format('${%s}', conky_value))
    if is_number then
        value = tonumber(value) 
    return value
end


function draw_line(display, element)
    -- draw a line

    -- deltas for x and y (cairo expects a point and deltas for both axis)
    local x_side = element.x2 - element.x1 -- not abs! because they are deltas
    local y_side = element.y2 - element.y1 -- and the same here

    -- draw line
    cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
    cairo_set_line_width(display, element.thickness);
    cairo_move_to(display, element.x1, element.y1);
    cairo_rel_line_to(display, x_side, y_side);
    cairo_stroke(display);
end


function draw_bar_graph(display, element)
    -- draw a bar graph
    -- Used a little bit of trigonometry to be able to draw bars in any direction! :)
    
    -- get current value
    local value = get_conky_value(element.conky_value, true)
    
    -- dimensions of the full graph
    local x_side = element.x2 - element.x1
    local y_side = element.y2 - element.y1
    local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
    local angle = math.atan2(y_side, x_side)

    -- dimensions of the value bar
    local bar_hypotenuse = value * (hypotenuse / element.max_value)
    local bar_x_side = bar_hypotenuse * math.cos(angle)
    local bar_y_side = bar_hypotenuse * math.sin(angle)

    -- is it in critical value?
    local critical_or_not_suffix = ''
    if value >= element.critical_threshold then
        critical_or_not_suffix = '_critical'
    end

    -- background line (full graph)
    background_line = {
        x1 = element.x1,
        y1 = element.y1,

        x2 = element.x2,
        y2 = element.y2,

        color = element['background_color' + critical_or_not_suffix],
        alpha = element['background_alpha' + critical_or_not_suffix],
        thickness = element['background_thickness' + critical_or_not_suffix],
    }

    -- foreground line (bar)
    foreground_line = {
        x1 = element.x1,
        x2 = element.x1 + bar_x_side,

        y1 = element.y1,
        y2 = element.y1 + bar_y_side,

        color = element['foreground_color' + critical_or_not_suffix],
        alpha = element['foreground_alpha' + critical_or_not_suffix],
        thickness = element['foreground_thickness' + critical_or_not_suffix],
    }

    -- draw both lines
    draw_line(display, background_line)
    draw_line(display, foreground_line)
end


function draw_ring(display, element)
    -- draw a ring

    -- the user types degrees, but we need radians
    local start_angle, end_angle = math.rad(element.start_angle), math.rad(element.end_angle)

    -- direction of the ring changes the function we must call
    local arc_drawer = cairo_arc 
    if start_angle > end_angle then
        arc_drawer = cairo_arc_negative
    end

    -- draw the ring
    cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
    cairo_set_line_width(display, element.thickness);
    arc_drawer(display, element.x, element.y, element.radius, start_angle, end_angle)
    cairo_stroke(display);
end


function draw_ring_graph(display, element)
    -- draw a ring graph
    
    -- get current value
    local value = get_conky_value(element.conky_value, true)

    -- dimensions of the full graph
    local degrees = element.end_angle - element.start_angle

    -- dimensions of the value bar
    local bar_degrees = value * (degrees / element.max_value)

    -- is it in critical value?
    local critical_or_not_suffix = ''
    if value >= element.critical_threshold then
        critical_or_not_suffix = '_critical'
    end

    -- background ring (full graph)
    background_ring = {
        x = element.x,
        y = element.y,
        radius = element.radius,

        start_angle = element.start_angle,
        end_angle = element.end_angle,

        color = element['background_color' + critical_or_not_suffix],
        alpha = element['background_alpha' + critical_or_not_suffix],
        thickness = element['background_thickness' + critical_or_not_suffix],
    }

    -- foreground ring (bar)
    foreground_ring = {
        x = element.x,
        y = element.y,
        radius = element.radius,

        start_angle = element.start_angle,
        end_angle = element.end_angle + bar_degrees,

        color = element['foreground_color' + critical_or_not_suffix],
        alpha = element['foreground_alpha' + critical_or_not_suffix],
        thickness = element['foreground_thickness' + critical_or_not_suffix],
    }

    -- draw both rings
    draw_ring(display, background_ring)
    draw_ring(display, foreground_ring)
end


function draw_variable_text(display, element)
    error('variable_text element kind not implemented')
end


function draw_static_text(display, element)
    error('static_text element kind not implemented')
end


-- Default values for visual elements when not provided.
defaults = {
    bar_graph = {
        max_value = 100.,
        critical_threshold = 90.,

        background = 0x00FF6E,
        foreground = 0x00FF6E,
        background_alpha = 0.2,
        foreground_alpha = 1.0,
        background_thickness = 5,
        foreground_thickness = 5,

        background_critical = 0xFA002E,
        foreground_critical = 0xFA002E,
        background_alpha_critical = 0.2,
        foreground_alpha_critical = 1.0,
        background_thickness_critical = 5,
        foreground_thickness_critical = 5,

        draw_function = draw_bar_graph,
    },
    ring_graph = {
        max_value = 100.,
        critical_threshold = 90.,

        background = 0x00FF6E,
        foreground = 0x00FF6E,
        background_alpha = 0.2,
        foreground_alpha = 1.0,
        background_thickness = 5,
        foreground_thickness = 5,

        background_critical = 0xFA002E,
        foreground_critical = 0xFA002E,
        background_alpha_critical = 0.2,
        foreground_alpha_critical = 1.0,
        background_thickness_critical = 5,
        foreground_thickness_critical = 5,

        start_angle = 0, 
        end_angle = 360,

        draw_function = draw_ring_graph,
    },
    line = {
        color = 0x00FF6E,
        alpha = 0.2,
        thickness = 5,

        draw_function = draw_line,
    },
    ring = {
        color = 0x00FF6E,
        alpha = 0.2,
        thickness = 5,

        start_angle = 0, 
        end_angle = 360,

        draw_function = draw_ring,
    },
    variable_text = {
        color = 0x00FF6E,

        draw_function = draw_variable_text,
    },
    static_text = {
        color = 0x00FF6E,

        draw_function = draw_static_text,
    },
}


function fill_defaults(elements)
    -- fill each each element with the missing values, using the defaults
    for i, element in pairs(elements) do
        -- only if there are defined defaults for that element kind
        if defaults[element.kind] ~= nil then
            -- fill the element with the defaults (for the properties without
            -- value)
            for key, value in pairs(defaults[element.kind]) do
                if element[key] == nil then
                    element[key] = defaults[key]
                end
            end
        end
    end
end


function conky_main()
    if conky_window == nil then 
        return
    end

    fill_defaults(elements)

    local surface = cairo_xlib_surface_create(conky_window.display, 
                                              conky_window.drawable, 
                                              conky_window.visual, 
                                              conky_window.width, 
                                              conky_window.height)
    local display = cairo_create(surface)

    if tonumber(conky_parse('${updates}')) > 3 then
        for i, element in pairs(elements) do
            if element[draw_function] == nil then
                error("Unknown element kind, can't draw it: " + element.kind)
            else
                element.draw_function(display, element)
            end
        end
    end

    cairo_surface_destroy(surface)
end

