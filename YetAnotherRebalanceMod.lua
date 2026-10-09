local mod = SMODS.current_mod
local path = mod.path
local config = mod.config

YARM_CONFIG = config


-- Find the config UIBox recursively so the settings panel can be refreshed.
local function find_yarm_config_uibox(nodes)

    if not nodes then
        return nil
    end

    for _, node in ipairs(nodes) do

        if node.n == G.UIT.O
            and node.config
            and node.config.object
            and node.config.object.definition
            and node.config.object.definition.config
            and node.config.object.definition.config.id == "yarm_config_tab"
        then
            return node.config.object
        end

        local result = find_yarm_config_uibox(node.nodes)

        if result then
            return result
        end

    end

    return nil

end


-- Save the settings and rebuild the config panel to reflect their changes.
local function save_config()

    SMODS.save_mod_config(mod)

    local yarm_config_uibox =
        find_yarm_config_uibox(G.OVERLAY_MENU.definition.nodes)

    if not yarm_config_uibox then
        return
    end

    local menu_wrap = yarm_config_uibox.parent

    menu_wrap.config.object:remove()

    menu_wrap.config.object = UIBox({
        definition = mod.config_tab(),
        config = {
            parent = menu_wrap,
            type = "cm",
        },
    })

    menu_wrap.UIBox:recalculate()

end


G.FUNCS.yarm_restart_game = function()

    SMODS.save_mod_config(mod)
    SMODS.restart_game()

end


local function create_restart_container()

    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            padding = 0.1,
            outline = 1,
            r = 0.1,
        },
        nodes = {

            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.2,
                },
                nodes = {

                    {
                        n = G.UIT.T,
                        config = {
                            text = "Restart the game to apply changes.",
                            colour = G.C.WHITE,
                            scale = 0.4,
                        },
                    },

                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minh = 0.6,
                            button = "yarm_restart_game",
                            r = 0.1,
                            padding = 0.1,
                            colour = G.C.RED,
                        },
                        nodes = {

                            {
                                n = G.UIT.T,
                                config = {
                                    text = "Restart",
                                    colour = G.C.WHITE,
                                    scale = 0.4,
                                },
                            },

                        },
                    },

                },
            },

        },
    }

end


local TOGGLE_PADDING = 0.1


-- Build a toggle and its optional subtoggles inside a single outlined container.
local function create_toggle_container(toggle)

    local nodes = {}

    -- Toggle principal
    table.insert(nodes, {

        n = G.UIT.C,
        config = {
            align = "cl",
            padding = 0.05,
        },
        nodes = {

            {
                n = G.UIT.C,
                config = {
                    align = "cl",
                    padding = -0.25,
                },
                nodes = {

                    create_toggle({
                        col = true,
                        label = "",
                        w = 0,
                        scale = 0.85,
                        ref_table = toggle.ref_table,
                        ref_value = toggle.ref_value,
                        callback = save_config,
                    }),

                },
            },

            {
                n = G.UIT.C,
                config = {
                    align = "cl",
                    padding = 0.3,
                },
                nodes = {

                    {
                        n = G.UIT.T,
                        config = {
                            text = toggle.label,
                            scale = 0.4,
                            colour = G.C.UI.TEXT_LIGHT,
                        },
                    },

                },
            },

        },
    })


    -- Subtoggles
    if toggle.subtoggles then

        for _, subtoggle in ipairs(toggle.subtoggles) do

            table.insert(nodes, {

                n = G.UIT.C,
                config = {
                    align = "cl",
                    padding = 0.05,
                },
                nodes = {

                    {
                        n = G.UIT.C,
                        config = {
                            align = "cl",
                            padding = -0.25,
                        },
                        nodes = {

                            create_toggle({
                                col = true,
                                label = "",
                                w = 0,
                                scale = 0.7,
                                ref_table = subtoggle.ref_table,
                                ref_value = subtoggle.ref_value,
                                callback = save_config,
                            }),

                        },
                    },

                    {
                        n = G.UIT.C,
                        config = {
                            align = "cl",
                            padding = 0.25,
                        },
                        nodes = {

                            {
                                n = G.UIT.T,
                                config = {
                                    text = subtoggle.label,
                                    scale = 0.3,
                                    colour = G.C.UI.TEXT_LIGHT,
                                },
                            },

                        },
                    },

                },
            })

        end

    end


    -- Contenedor exterior del toggle.
    -- Este es el único que tiene outline.
    return {
        n = G.UIT.C,
        config = {
            align = "cl",
            padding = TOGGLE_PADDING,
            outline = 1,
            r = 0.1,
        },
        nodes = nodes,
    }

end


-- Estimate text width using the active game's font to support row layout.
local function get_text_width(text, scale)

    local font = G.LANG.font
    local width = 0

    for _, c in utf8.chars(text) do

        local char_width =
            font.FONT:getWidth(c)
            * scale
            * G.TILESCALE
            * font.FONTSCALE

        width = width
            + char_width
            / (G.TILESIZE * G.TILESCALE)

    end

    return width

end


-- Estimate the full width of a toggle, including its labels and spacing.
local function get_toggle_width(toggle)

    local width = 0

    -- Checkbox + texto principal
    width = width + 0.55
    width = width + get_text_width(toggle.label, 0.4)

    -- Padding entre checkbox y texto
    width = width + 0.3

    -- Padding exterior del toggle
    width = width + 0.1


    -- Subtoggles
    if toggle.subtoggles then

        for _, subtoggle in ipairs(toggle.subtoggles) do

            width = width + 0.45
            width = width + get_text_width(subtoggle.label, 0.3)
            width = width + 0.25
            width = width + 0.1

        end

    end

    return width

end


function mod.config_tab()

    local toggles = {}

    -- Recopilar los toggles registrados por cada Joker.
    for _, toggle in ipairs(YARM_CONFIG_TOGGLES or {}) do
        table.insert(toggles, toggle)
    end

    -- Placeholders para probar el layout.
    table.insert(toggles, {
        label = "Placeholder A",
        placeholder = true,
    })

    table.insert(toggles, {
        label = "Placeholder B",
        placeholder = true,
    })

    table.insert(toggles, {
        label = "Placeholder C",
        placeholder = true,
    })

    table.insert(toggles, {
        label = "Placeholder D",
        placeholder = true,
    })

    local toggle_rows = {}

    -- Restart: una sola fila propia.
    table.insert(toggle_rows, {
        n = G.UIT.R,
        config = {
            align = "cm",
            padding = 0.01,
        },
        nodes = {
            create_restart_container(),
        },
    })

    local available_width = 9
    local rows = {}
    local row_widths = {}

    -- Distribuir cada toggle en la primera fila donde entre.
    for _, toggle in ipairs(toggles) do
        local toggle_width = get_toggle_width(toggle)
        local placed = false

        for i, row in ipairs(rows) do
            if row_widths[i] + toggle_width <= available_width then
                table.insert(row, create_toggle_container(toggle))
                row_widths[i] = row_widths[i] + toggle_width
                placed = true
                break
            end
        end

        -- Si no entra en ninguna fila, crear una nueva.
        if not placed then
            table.insert(rows, {
                create_toggle_container(toggle)
            })

            table.insert(row_widths, toggle_width)
        end
    end

    -- Añadir las filas calculadas después de la fila de reinicio.
    for _, row in ipairs(rows) do
        table.insert(toggle_rows, {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.01,
            },
            nodes = row,
        })
    end

    return {
        n = G.UIT.ROOT,

        config = {
            id = "yarm_config_tab",
            r = 0.01,
            minw = 7,
            align = "tm",
            padding = 0.2,
            colour = G.C.BLACK,
            outline = 1,
        },

        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.2,
                },
                nodes = toggle_rows,
            },
        },
    }
end



-- Localization

dofile(path .. "localization/en-us.lua")


-- Functions

dofile(path .. "functions/sinful.lua")


-- Jokers

dofile(path .. "src/jokers/jimbo.lua")
dofile(path .. "src/jokers/greedy_joker.lua")
dofile(path .. "src/jokers/lusty_joker.lua")
dofile(path .. "src/jokers/wrathful_joker.lua")
dofile(path .. "src/jokers/gluttonous_joker.lua")
dofile(path .. "src/jokers/four_fingers.lua")


-- Other content

dofile(path .. "src/tarots.lua")
dofile(path .. "src/enhancements.lua")
