-- Register Zany Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Zany Joker",
    ref_table = YARM_CONFIG.jokers.zany_joker,
    ref_value = "rebalance",
})

-- Zany Joker
-- Apply Zany Joker's rebalance when enabled.
if YARM_CONFIG.jokers.zany_joker.rebalance then
    SMODS.Joker:take_ownership("zany", {
        cost = 3,
    })
end