-- Food Jokers
local food_jokers = {
    j_gros_michel = true,
    j_ice_cream = true,
    j_egg = true,
    j_cavendish = true,
    j_turtle_bean = true,
    j_diet_cola = true,
    j_popcorn = true,
    j_ramen = true,
    j_seltzer = true,
}

-- Track processed events without keeping removed cards alive.
local processed_food_events = setmetatable({}, {
    __mode = "k"
})

local function yarm_food_log(message)
    local line = "[YARM Food] " .. tostring(message)

    if sendDebugMessage then
        sendDebugMessage(line)
    else
        print(line)
    end
end

-- Register a Joker as a Food Joker.
function add_food_joker(key)
    food_jokers[key] = true
end

-- Check whether a Joker is a Food Joker.
function is_food_joker(card)
    if not card
        or not card.config
        or not card.config.center then
        return false
    end

    return food_jokers[card.config.center.key] == true
end

-- Check whether Loyalty Card's Food synergy is active.
function is_loyalty_food_synergy_active()
    if not YARM_CONFIG
        or not YARM_CONFIG.jokers
        or not YARM_CONFIG.jokers.loyalty_card
        or not YARM_CONFIG.jokers.loyalty_card.rebalance then
        return false
    end

    if not G.jokers or not G.jokers.cards then
        return false
    end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config
            and joker.config.center
            and joker.config.center.key == "j_loyalty_card" then
            return true
        end
    end

    return false
end

-- Reduce Loyalty Card's countdown when a Food Joker
-- is bought or eaten.
function trigger_food_joker_event(food_card, event)
    if not is_food_joker(food_card) then
        return
    end

    yarm_food_log(
        "EVENT"
        .. " | event=" .. tostring(event)
        .. " | food=" .. tostring(food_card.config.center.key)
    )

    if event ~= "bought" and event ~= "eaten" then
        return
    end

    -- Prevent the same event from being processed twice.
    local card_events = processed_food_events[food_card]

    if not card_events then
        card_events = {}
        processed_food_events[food_card] = card_events
    end

    if card_events[event] then
        yarm_food_log("IGNORED DUPLICATE EVENT | " .. tostring(event))
        return
    end

    card_events[event] = true

    if not is_loyalty_food_synergy_active() then
        return
    end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config
            and joker.config.center
            and joker.config.center.key == "j_loyalty_card"
            and joker.ability then

            local extra = joker.ability.extra
            local cycle = extra.every + 1

            if joker.ability.loyalty_countdown == nil then
                joker.ability.loyalty_countdown = extra.every
            end

            if joker.ability.food_steps_pending == nil then
                joker.ability.food_steps_pending = 0
            end

            yarm_food_log(
                "BEFORE FOOD STEP"
                .. " | countdown=" .. tostring(joker.ability.loyalty_countdown)
                .. " | loyalty_remaining=" .. tostring(joker.ability.loyalty_remaining)
                .. " | pending=" .. tostring(joker.ability.food_steps_pending)
            )

            local remaining = joker.ability.loyalty_countdown

            -- Advance one step, preserving overflow for later cycles.
            if remaining > 0 then
                remaining = remaining - 1
                joker.ability.loyalty_countdown = remaining
            else
                joker.ability.food_steps_pending =
                    (joker.ability.food_steps_pending + 1) % cycle
            end

            joker.ability.loyalty_remaining = remaining

            yarm_food_log(
                "AFTER FOOD STEP"
                .. " | countdown=" .. tostring(joker.ability.loyalty_countdown)
                .. " | loyalty_remaining=" .. tostring(joker.ability.loyalty_remaining)
                .. " | pending=" .. tostring(joker.ability.food_steps_pending)
            )

            -- Wiggle immediately when a Food Joker activates Loyalty Card.
            if remaining == 0 then
                local eval = function(c)
                    return c.ability.loyalty_countdown == 0
                end

                juice_card_until(joker, eval, true)
            end
        end
    end
end