-- Register Clever Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Clever Joker",
    ref_table = YARM_CONFIG.jokers.clever_joker,
    ref_value = "rebalance",
})

-- Clever Joker
-- Apply Clever Joker's rebalance when enabled.
if YARM_CONFIG.jokers.clever_joker.rebalance then
    SMODS.Joker:take_ownership("clever", {
        cost = 3,
    })
end