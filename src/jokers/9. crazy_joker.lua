-- Register Crazy Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Crazy Joker",
    ref_table = YARM_CONFIG.jokers.crazy_joker,
    ref_value = "rebalance",
})

-- Crazy Joker
-- Apply Crazy Joker's rebalance when enabled.
if YARM_CONFIG.jokers.crazy_joker.rebalance then
    SMODS.Joker:take_ownership("crazy", {
        cost = 3,
    })
end