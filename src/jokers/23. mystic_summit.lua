-- Register Mystic Summit's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Mystic Summit",
    ref_table = YARM_CONFIG.jokers.mystic_summit,
    ref_value = "rebalance",
})

-- Mystic Summit
if YARM_CONFIG.jokers.mystic_summit.rebalance then
    SMODS.Joker:take_ownership("mystic_summit", {
        config = {
            extra = {
                mult = 6,
            }
        },

        loc_vars = function(self, info_queue, card)
            local mult = card.ability.extra.mult
            local discards = G.GAME.current_round.discards_left or 0
            local total_mult = mult * discards

            return {
                key = "j_yarm_mystic_summit",
                vars = {
                    mult,
                    total_mult,
                }
            }
        end,

        calculate = function(self, card, context)
            if context.joker_main then
                local mult = card.ability.extra.mult
                local discards = G.GAME.current_round.discards_left or 0
                local total_mult = mult * discards

                if total_mult > 0 then
                    return {
                        mult = total_mult,
                    }
                end
            end
        end,
    })
end