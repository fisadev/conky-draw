conky-draw
==========

Easily create beautiful conky graphs and draws.

The main idea is this: stop copying and pasting random code from the web to your monolithic conkyrc + something.lua. Start using a nicely defined set of visual elements, in a very clean config file, separated from the code that has the drawing logic.


Work in progress. Right now you can only define bar and ring graphs, and static lines and rings. But I'm working on:

* A short tutorial and some examples.
* Draw text elements (on arbitrary positions/areas, not like traditional conkyrc).
* More basic elements: filled circles, rectangles, ...
* Other more complex visual elements (example: clocks)

Installation
------------

1. Copy both ``conky_draw.lua`` and ``conky_draw_config.lua`` to your ``.conky`` folder (your own ``conkyrc`` should be there too).
2. Include this in your conkyrc:

.. code::

    lua_load ./conky_draw.lua
    lua_draw_hook_post main

3. Customize the ``conky_draw_config.lua`` file as you wish (examples below)
4. Be sure to run conky from **inside** your ``.conky`` folder. Example: ``cd .conky && conky -c conkyrc``


Basic examples
-------------

Not so nice examples, but better have something before we write a nice tutorial:

.. code:: lua

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


Available elements and their properties
---------------------------------------

Properties marked as **required** must be defined by you. The rest have default values, you can leave them undefined, or define them with the values you like.
 
But first, some general notions on the values of properties.

+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| If the property is a...| This is what you should know                                                                                                                       |
+========================+====================================================================================================================================================+
| point                  | Its value should be something with x and y values.                                                                                                 |
|                        | Example: ``from = {x=100, y=100}``                                                                                                                 |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| color                  | Its value should be a color in hexa.                                                                                                               |
|                        | Example (red): ``color = 0xFF0000``                                                                                                                |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| alpha level            | Its value should be a transpacency level from 0 (fully transparent) to 1 (solid, no transpacency).                                                 |
|                        | Example: ``alpha = 0.2``                                                                                                                           |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| angle                  | Its value should be expresed in **degrees**. Angle 0 is east, angle 90 is south, angle 180 is west, and angle 270 is north.                        |
|                        | Example: ``start_angle = 90``                                                                                                                      |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| thickness              | Its value should be the thickness in pixels.                                                                                                       |
|                        | Example: ``thickness = 5``                                                                                                                         |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| conky value            | Its value should be a string of a conky value to use.                                                                                              |
|                        | Example: ``conky_value = 'upspeedf eth0'``                                                                                                         |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| max value              | It should be maximum possible value for the conky value used in a graph. It's needed to calculate the length of the bars in the graphs, so be sure |
|                        | it's correct (for cpu usage values it's 100, for network speeds it's your top speed, etc.).                                                        |
|                        | Example: ``max_value = 100``                                                                                                                       |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| critical threshold     | It should be the value at which the graph should change appearance. If you don't want that, just leave it equal to max_value to disable appearance |
|                        | changes.                                                                                                                                           |
|                        | Example: ``critical_threshold = 90``                                                                                                               |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+

Now, the elements and properties
--------------------------------

**line**: a simple straight line from point A to point B.

:from (required): A point where the line should start.
:to (required): A point where the line should end.
:color: Color of the line.
:alpha: Transpacency level of the line.
:thickness: Thickness of the line.

**bar_graph**: a bar graph, able to display a value from conky, and optionaly able to change appearance when the value hits a "critical" threshold.

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| from (required)                | A point where the bar graph should start.                                                                                              |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| to (required)                  | A point where the bar graph should end.                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| conky_value (required)         | Conky value to use on the graph.                                                                                                       |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| max_value and                  | For the conky value being used on the graph.                                                                                           |
| critical_threshold             |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color,              | For the appearance of the background of the graph in normal conditions.                                                                |
| background_alpha and           |                                                                                                                                        |
| background_thickness           |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color, bar_alpha and       | For the appearance of the bar of the graph in normal conditions.                                                                       |
| bar_thickness                  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color_critical,     | For the appearance of the background of the graph when the value is above critical threshold.                                          |
| background_alpha_critical and  |                                                                                                                                        |
| background_thickness_critical  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color_critical,            | For the appearance of the bar of the graph when the value is above critical threshold.                                                 |
| bar_alpha_critical and         |                                                                                                                                        |
| bar_thickness_critical         |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

**ring**: a simple ring (can be a section of the ring too).

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| center (required)              | The center point of the ring.                                                                                                          |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| radius (required)              | The radius of the ring.                                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| color                          | Color of the ring.                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| alpha                          | Transpacency level of the ring.                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| thickness                      | Thickness of the ring.                                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| start_angle                    | Angle at which the arc starts. Useful to limit the ring to just a section of the circle.                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| end_angle                      | Angle at which the arc ends. Useful to limit the ring to just a section of the circle.                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| *Extra tip*: start_angle and end_angle can be swapped, to produce oposite arcs. If you don't understand this, just try what happens with this two examples:             |
|                                                                                                                                                                         |
| * ``start_angle=90, end_angle=180``                                                                                                                                     |
| * ``start_angle=180, end_angle=90``                                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

**ring_graph**: a ring graph (can be a section of the ring too) able to display a value from conky, and optionaly able to change appearance when the value hits a "critical" threshold.

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| center (required)              | The center point of the ring.                                                                                                          |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| radius (required)              | The radius of the ring.                                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| conky_value (required)         | Conky value to use on the graph.                                                                                                       |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| max_value and                  | For the conky value being used on the graph.                                                                                           |
| critical_threshold             |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color,              | For the appearance of the background of the graph in normal conditions.                                                                |
| background_alpha and           |                                                                                                                                        |
| background_thickness           |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color, bar_alpha and       | For the appearance of the bar of the graph in normal conditions.                                                                       |
| bar_thickness                  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color_critical,     | For the appearance of the background of the graph when the value is above critical threshold.                                          |
| background_alpha_critical and  |                                                                                                                                        |
| background_thickness_critical  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color_critical,            | For the appearance of the bar of the graph when the value is above critical threshold.                                                 |
| bar_alpha_critical and         |                                                                                                                                        |
| bar_thickness_critical         |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| start_angle                    | Angle at which the arc starts. Useful to limit the ring to just a section of the circle.                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| end_angle                      | Angle at which the arc ends. Useful to limit the ring to just a section of the circle.                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| *Extra tip*: start_angle and end_angle can be swapped, to produce oposite arcs. If you don't understand this, just try what happens with this two examples:             |
|                                                                                                                                                                         |
| * ``start_angle=90, end_angle=180``                                                                                                                                     |
| * ``start_angle=180, end_angle=90``                                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

**static_text**: not yet implemented.

**variable_text**: not yet implemented.

**clock**: not yet implemented.
