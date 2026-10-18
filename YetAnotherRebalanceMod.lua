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


local YARM_CONFIG_ROWS_PER_PAGE = 5
local yarm_config_page = 1
local YARM_CONFIG_PANEL_WIDTH = 10.5

-- Refresh the configuration panel.
local function refresh_config_tab()
    local yarm_config_uibox =
        find_yarm_config_uibox(G.OVERLAY_MENU.definition.nodes)

    if not yarm_config_uibox then return end

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

-- Save settings and refresh the configuration panel.
local function save_config()
    SMODS.save_mod_config(mod)
    refresh_config_tab()
end

G.FUNCS.yarm_config_prev_page = function()
    if yarm_config_page > 1 then
        yarm_config_page = yarm_config_page - 1
        refresh_config_tab()
    end
end

G.FUNCS.yarm_config_next_page = function()
    yarm_config_page = yarm_config_page + 1
    refresh_config_tab()
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
    for _, toggle in ipairs(YARM_CONFIG_TOGGLES or {}) do
        table.insert(toggles, toggle)
    end

    -- Calculate toggle rows using the existing width estimation.
    local available_width = 9
    local rows = {}
    local row_widths = {}

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

        if not placed then
            table.insert(rows, { create_toggle_container(toggle) })
            table.insert(row_widths, toggle_width)
        end
    end

    -- Page 1 has 5 toggle rows plus Restart.
    -- Subsequent pages have 6 toggle rows each.
    local first_page_toggle_rows = YARM_CONFIG_ROWS_PER_PAGE - 1
    local remaining_rows = math.max(0, #rows - first_page_toggle_rows)
    local page_count = 1 + math.ceil(
        remaining_rows / YARM_CONFIG_ROWS_PER_PAGE
    )

    -- Keep the current page within valid bounds.
    yarm_config_page = math.max(
        1,
        math.min(yarm_config_page, page_count)
    )

    local toggle_rows = {}

    -- Restart occupies the first row on page 1.
    if yarm_config_page == 1 then
        table.insert(toggle_rows, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.01 },
            nodes = { create_restart_container() },
        })
    end

    -- Determine which toggle rows belong to this page.
    local first_row
    local last_row

    if yarm_config_page == 1 then
        first_row = 1
        last_row = math.min(#rows, first_page_toggle_rows)
    else
        first_row = first_page_toggle_rows
            + 1
            + (yarm_config_page - 2) * YARM_CONFIG_ROWS_PER_PAGE

        last_row = math.min(
            #rows,
            first_row + YARM_CONFIG_ROWS_PER_PAGE - 1
        )
    end

    for i = first_row, last_row do
        table.insert(toggle_rows, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.01 },
            nodes = rows[i],
        })
    end

    -- Navigation row is separate from the six content rows.
    local navigation_nodes = {}

    if yarm_config_page > 1 then
        table.insert(navigation_nodes, {
            n = G.UIT.C,
            config = {
                align = "cm",
                button = "yarm_config_prev_page",
                colour = G.C.BLUE,
                minw = 1.2,
                minh = 0.5,
                padding = 0.08,
                r = 0.1,
                hover = true,
            },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = "Previous",
                        scale = 0.35,
                        colour = G.C.WHITE,
                    },
                },
            },
        })
    end

    table.insert(navigation_nodes, {
        n = G.UIT.C,
        config = {
            align = "cm",
            padding = 0.15,
        },
        nodes = {
            {
                n = G.UIT.T,
                config = {
                    text = "Page " .. yarm_config_page
                        .. " / " .. page_count,
                    scale = 0.4,
                    colour = G.C.WHITE,
                },
            },
        },
    })

    if yarm_config_page < page_count then
        table.insert(navigation_nodes, {
            n = G.UIT.C,
            config = {
                align = "cm",
                button = "yarm_config_next_page",
                colour = G.C.BLUE,
                minw = 1.2,
                minh = 0.5,
                padding = 0.08,
                r = 0.1,
                hover = true,
            },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = "Next",
                        scale = 0.35,
                        colour = G.C.WHITE,
                    },
                },
            },
        })
    end

    table.insert(toggle_rows, {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.08 },
        nodes = navigation_nodes,
    })

    
    return {
        n = G.UIT.ROOT,
        config = {
            id = "yarm_config_tab",
            r = 0.01,
            minw = YARM_CONFIG_PANEL_WIDTH,
            maxw = YARM_CONFIG_PANEL_WIDTH,
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
                    minw = YARM_CONFIG_PANEL_WIDTH - 0.4,
                    maxw = YARM_CONFIG_PANEL_WIDTH - 0.4,
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
dofile(path .. "functions/food.lua")


-- Jokers

dofile(path .. "src/jokers/1. jimbo.lua")
dofile(path .. "src/jokers/2. greedy_joker.lua")
dofile(path .. "src/jokers/3. lusty_joker.lua")
dofile(path .. "src/jokers/4. wrathful_joker.lua")
dofile(path .. "src/jokers/5. gluttonous_joker.lua")
dofile(path .. "src/jokers/7. zany_joker.lua")
dofile(path .. "src/jokers/8. mad_joker.lua")
dofile(path .. "src/jokers/9. crazy_joker.lua")
dofile(path .. "src/jokers/10. droll_joker.lua")
dofile(path .. "src/jokers/12. wily_joker.lua")
dofile(path .. "src/jokers/13. clever_joker.lua")
dofile(path .. "src/jokers/14. devious_joker.lua")
dofile(path .. "src/jokers/15. crafty_joker.lua")
dofile(path .. "src/jokers/18. four_fingers.lua")
dofile(path .. "src/jokers/19. mime.lua")
dofile(path .. "src/jokers/20. credit_card.lua")
dofile(path .. "src/jokers/21. ceremonial_dagger.lua")
dofile(path .. "src/jokers/22. banner.lua")
dofile(path .. "src/jokers/23. mystic_summit.lua")
dofile(path .. "src/jokers/24. marble_joker.lua")
dofile(path .. "src/jokers/25. loyalty_card.lua")
dofile(path .. "src/jokers/26. 8_ball.lua")
dofile(path .. "src/jokers/27. misprint.lua")
dofile(path .. "src/jokers/29. raised_fist.lua")
dofile(path .. "src/jokers/30. chaos_the_clown.lua")
dofile(path .. "src/jokers/38. gros_michel.lua")


-- Other content

dofile(path .. "src/tarots.lua")
dofile(path .. "src/enhancements.lua")


-- Tests
--assert(SMODS.load_file("tests.lua"))()