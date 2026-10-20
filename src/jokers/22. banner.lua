-- Register Banner's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Banner",
    ref_table = YARM_CONFIG.jokers.banner,
    ref_value = "rebalance",
})

-- Banner
if YARM_CONFIG.jokers.banner.rebalance then
    SMODS.Joker:take_ownership("banner", {
        config = {
            extra = 40,
        },

        loc_vars = function(self, info_queue, card)
            local chips = card.ability.extra or self.config.extra
            local discards = G.GAME.current_round.discards_left or 0
            local total_chips = chips * discards

            return {
                key = "j_yarm_banner",
                vars = {
                    chips,
                    total_chips,
                }
            }
        end,

        calculate = function(self, card, context)
            if context.joker_main then
                local chips = card.ability.extra or self.config.extra
                local discards = G.GAME.current_round.discards_left or 0
                local total_chips = chips * discards

                if total_chips > 0 then
                    return {
                        chips = total_chips,
                    }
                end
            end
        end,
    })
end