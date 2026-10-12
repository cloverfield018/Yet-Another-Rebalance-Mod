-- Register Devious Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Devious Joker",
    ref_table = YARM_CONFIG.jokers.devious_joker,
    ref_value = "rebalance",
})

-- Devious Joker
-- Apply Devious Joker's rebalance when enabled.
if YARM_CONFIG.jokers.devious_joker.rebalance then
    SMODS.Joker:take_ownership("devious", {
        cost = 3,
    })
end