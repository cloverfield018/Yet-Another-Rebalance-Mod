-- Register Wily Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Wily Joker",
    ref_table = YARM_CONFIG.jokers.wily_joker,
    ref_value = "rebalance",
})

-- Wily Joker
-- Apply Wily Joker's rebalance when enabled.
if YARM_CONFIG.jokers.wily_joker.rebalance then
    SMODS.Joker:take_ownership("wily", {
        cost = 3,
    })
end