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
    end
    return value
end


function draw_line(display, element)
    -- draw a line

    -- deltas for x and y (cairo expects a point and deltas for both axis)
    local x_side = element.to.x - element.from.x -- not abs! because they are deltas
    local y_side = element.to.y - element.from.y -- and the same here

    -- draw line
    cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
    cairo_set_line_width(display, element.thickness);
    cairo_move_to(display, element.from.x, element.from.y);
    cairo_rel_line_to(display, x_side, y_side);
    cairo_stroke(display);
end


function draw_bar_graph(display, element)
    -- draw a bar graph
    -- Used a little bit of trigonometry to be able to draw bars in any direction! :)
    
    -- get current value
    local value = get_conky_value(element.conky_value, true)

    if value > element.max_value then
        value = element.max_value
    end
    
    -- dimensions of the full graph
    local x_side = element.to.x - element.from.x
    local y_side = element.to.y - element.from.y
    local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
    local angle = math.atan2(y_side, x_side)

    -- dimensions of the value bar
    local bar_hypotenuse = value * (hypotenuse / element.max_value)
    local bar_x_side = bar_hypotenuse * math.cos(angle)
    local bar_y_side = bar_hypotenuse * math.sin(angle)

    -- is it in critical value?
    local color_critical_or_not_suffix = ''
    local alpha_critical_or_not_suffix = ''
    local thickness_critical_or_not_suffix = ''
    if value >= element.critical_threshold then
        if element.change_color_on_critical then
            color_critical_or_not_suffix = '_critical'
        end
        if element.change_alpha_on_critical then
            alpha_critical_or_not_suffix = '_critical'
        end
        if element.change_thickness_on_critical then
            thickness_critical_or_not_suffix = '_critical'
        end
    end

    -- background line (full graph)
    background_line = {
        from = element.from,
        to = element.to,

        color = element['background_color' .. color_critical_or_not_suffix],
        alpha = element['background_alpha' .. alpha_critical_or_not_suffix],
        thickness = element['background_thickness' .. thickness_critical_or_not_suffix],
    }

    -- bar line
    bar_line = {
        from = element.from,
        to = {x=element.from.x + bar_x_side, y=element.from.y + bar_y_side},

        color = element['bar_color' .. color_critical_or_not_suffix],
        alpha = element['bar_alpha' .. alpha_critical_or_not_suffix],
        thickness = element['bar_thickness' .. thickness_critical_or_not_suffix],
    }

    -- draw both lines
    draw_line(display, background_line)
    draw_line(display, bar_line)
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
    arc_drawer(display, element.center.x, element.center.y, element.radius, start_angle, end_angle)
    cairo_stroke(display);
end


function draw_ring_graph(display, element)
    -- draw a ring graph
    
    -- get current value
    local value = get_conky_value(element.conky_value, true)

    if value > element.max_value then
        value = element.max_value
    end

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
        center = element.center,
        radius = element.radius,

        start_angle = element.start_angle,
        end_angle = element.end_angle,

        color = element['background_color' .. critical_or_not_suffix],
        alpha = element['background_alpha' .. critical_or_not_suffix],
        thickness = element['background_thickness' .. critical_or_not_suffix],
    }

    -- bar ring
    bar_ring = {
        center = element.center,
        radius = element.radius,

        start_angle = element.start_angle,
        end_angle = element.start_angle + bar_degrees,

        color = element['bar_color' .. critical_or_not_suffix],
        alpha = element['bar_alpha' .. critical_or_not_suffix],
        thickness = element['bar_thickness' .. critical_or_not_suffix],
    }

    -- draw both rings
    draw_ring(display, background_ring)
    draw_ring(display, bar_ring)
end


function draw_variable_text(display, element)
    error('variable_text element kind not implemented')
end


function draw_static_text(display, element)
    error('static_text element kind not implemented')
end


function draw_clock(display, element)
    error('clock element kind not implemented')
end


-- properties that the user *must* define, because they don't have default
-- values
requirements = {
    line = {'from', 'to'},
    bar_graph = {'from', 'to', 'conky_value'},
    ring = {'center', 'radius'},
    ring_graph = {'center', 'radius', 'conky_value'},
    variable_text = {},
    static_text = {},
    clock = {},
}


-- Default values for properties that can have a default value
defaults = {
    bar_graph = {
        max_value = 100.,
        critical_threshold = 90.,

        background_color = 0x00FF6E,
        background_alpha = 0.2,
        background_thickness = 5,

        bar_color = 0x00FF6E,
        bar_alpha = 1.0,
        bar_thickness = 5,

        background_color_critical = 0xFA002E,
        background_alpha_critical = 0.2,
        background_thickness_critical = 5,

        bar_color_critical = 0xFA002E,
        bar_alpha_critical = 1.0,
        bar_thickness_critical = 5,

        change_color_on_critical = true,
        change_alpha_on_critical = false,
        change_thickness_on_critical = false,

        draw_function = draw_bar_graph,
    },
    ring_graph = {
        max_value = 100.,
        critical_threshold = 90.,

        background_color = 0x00FF6E,
        background_alpha = 0.2,
        background_thickness = 5,

        bar_color = 0x00FF6E,
        bar_alpha = 1.0,
        bar_thickness = 5,

        background_color_critical = 0xFA002E,
        background_alpha_critical = 0.2,
        background_thickness_critical = 5,

        bar_color_critical = 0xFA002E,
        bar_alpha_critical = 1.0,
        bar_thickness_critical = 5,

        change_color_on_critical = true,
        change_alpha_on_critical = false,
        change_thickness_on_critical = false,

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
    clock = {
        draw_function = draw_clock,
    },
}


function check_requirements(elements)
    -- check every element has the required properties
    for i, element in pairs(elements) do
        -- find the requirements for that element kind
        kind_requirements = requirements[element.kind]
        -- if there are defined requirements for that element kind
        if  kind_requirements ~= nil then
            -- check all of them are defined by the user
            for i, property in pairs(kind_requirements) do
                if element[property] == nil then
                    error('You defined a ' .. element.kind .. ' without specifying its "' .. property .. '" value')
                end
            end
        else
            -- we don't know which properties has to have, BUT, it always needs
            -- a draw_function
            if element.draw_function == nil then
                error('You defined a ' .. element.kind .. ', which is unknown element kind to me. Was it a typo? or are you trying to define a custom element kind but forgot to define its draw_function?')
            end
        end
    end
end


function fill_defaults(elements)
    -- fill each each element with the missing values, using the defaults
    for i, element in pairs(elements) do
        -- find the defaults for that element kind
        kind_defaults = defaults[element.kind]
        -- only if there are defined defaults for that element kind
        if  kind_defaults ~= nil then
            -- fill the element with the defaults (for the properties without
            -- value)
            for key, value in pairs(kind_defaults) do
                if element[key] == nil then
                    element[key] = kind_defaults[key]
                end
            end
        end
    end
end


function conky_main()
    if conky_window == nil then 
        return
    end

    check_requirements(elements)
    fill_defaults(elements)

    local surface = cairo_xlib_surface_create(conky_window.display, 
                                              conky_window.drawable, 
                                              conky_window.visual, 
                                              conky_window.width, 
                                              conky_window.height)
    local display = cairo_create(surface)

    if tonumber(conky_parse('${updates}')) > 3 then
        for i, element in pairs(elements) do
            element.draw_function(display, element)
        end
    end

    cairo_surface_destroy(surface)
end

