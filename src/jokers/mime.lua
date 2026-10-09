-- Register Mime's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Mime",
    ref_table = YARM_CONFIG.jokers.mime,
    ref_value = "rebalance",
})

-- Mime
-- Apply Mime's rebalance when enabled.
if YARM_CONFIG.jokers.mime.rebalance then
    SMODS.Joker:take_ownership("mime", {
        cost = 7,
    })
end