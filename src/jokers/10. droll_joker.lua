-- Register Droll Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Droll Joker",
    ref_table = YARM_CONFIG.jokers.droll_joker,
    ref_value = "rebalance",
})

-- Droll Joker
-- Apply Droll Joker's rebalance when enabled.
if YARM_CONFIG.jokers.droll_joker.rebalance then
    SMODS.Joker:take_ownership("droll", {
        cost = 3,
    })
end