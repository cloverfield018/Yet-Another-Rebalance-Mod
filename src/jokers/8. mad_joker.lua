-- Register Mad Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Mad Joker",
    ref_table = YARM_CONFIG.jokers.mad_joker,
    ref_value = "rebalance",
})

-- Mad Joker
-- Apply Mad Joker's rebalance when enabled.
if YARM_CONFIG.jokers.mad_joker.rebalance then
    SMODS.Joker:take_ownership("mad", {
        cost = 3,
    })
end