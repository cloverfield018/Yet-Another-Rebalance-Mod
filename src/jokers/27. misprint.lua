-- Register Misprint's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Misprint",
    ref_table = YARM_CONFIG.jokers.misprint,
    ref_value = "rebalance",
})

-- Misprint
if YARM_CONFIG.jokers.misprint.rebalance then
    SMODS.Joker:take_ownership("misprint", {
        config = {
            extra = {
                min = 0,
                max = 27,
            }
        },
    })
end