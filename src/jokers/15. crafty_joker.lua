-- Register Crafty Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Crafty Joker",
    ref_table = YARM_CONFIG.jokers.crafty_joker,
    ref_value = "rebalance",
})

-- Crafty Joker
-- Apply Crafty Joker's rebalance when enabled.
if YARM_CONFIG.jokers.crafty_joker.rebalance then
    SMODS.Joker:take_ownership("crafty", {
        cost = 3,
    })
end