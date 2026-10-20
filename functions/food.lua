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

-- Food Jokers whose automatic consumption is currently recognized.
-- Add entries here as each Food Joker's consumption is implemented.
local consumed_food_jokers = {
    j_gros_michel = true,
}

-- Track processed events without keeping removed cards alive.
local processed_food_events = setmetatable({}, {
    __mode = "k"
})

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

-- Check whether a Food Joker's automatic consumption is recognized.
function is_consumed_food_joker(card)
    if not is_food_joker(card) then
        return false
    end

    return consumed_food_jokers[card.config.center.key] == true
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

-- Apply one Food Joker step to a single Loyalty Card.
-- While the countdown is running the step is applied immediately.
-- While Loyalty Card is Active! (countdown at zero) the step is stored
-- as pending and consumed by the following activation.
local function apply_food_reduction(joker)
    if not joker.ability or joker.debuff then
        return
    end

    local extra = joker.ability.extra

    if joker.ability.loyalty_countdown == nil then
        joker.ability.loyalty_countdown = extra.every
    end

    if joker.ability.food_steps_pending == nil then
        joker.ability.food_steps_pending = 0
    end

    local remaining = joker.ability.loyalty_countdown

    -- Advance one step. While Active! the step is stored as pending so it
    -- can shorten the next cycle instead of being lost at zero.
    if remaining > 0 then
        remaining = remaining - 1
        joker.ability.loyalty_countdown = remaining
    else
        joker.ability.food_steps_pending =
            joker.ability.food_steps_pending + 1
    end

    joker.ability.loyalty_remaining = remaining

    -- Wiggle immediately when a Food Joker activates Loyalty Card.
    if remaining == 0 then
        local eval = function(c)
            return c.ability.loyalty_countdown == 0
        end

        juice_card_until(joker, eval, true)
    end
end

-- Reduce Loyalty Card's countdown when a Food Joker
-- is bought or consumed.
function trigger_food_joker_event(food_card, event)
    if not is_food_joker(food_card) then
        return
    end

    if event ~= "bought" and event ~= "eaten" then
        return
    end

    -- Only self-consumption is recognized for now, and only for the
    -- Food Jokers that currently implement it.
    if event == "eaten" and not is_consumed_food_joker(food_card) then
        return
    end

    -- Prevent the same event from being processed twice.
    local card_events = processed_food_events[food_card]

    if not card_events then
        card_events = {}
        processed_food_events[food_card] = card_events
    end

    if card_events[event] then
        return
    end

    card_events[event] = true

    if not is_loyalty_food_synergy_active() then
        return
    end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config
            and joker.config.center
            and joker.config.center.key == "j_loyalty_card" then

            apply_food_reduction(joker)
        end
    end
end
