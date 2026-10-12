-- Register Gluttonous Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Gluttonous Joker",
    ref_table = YARM_CONFIG.jokers.gluttonous_joker,
    ref_value = "rebalance",
})

-- Gluttonous Joker
if YARM_CONFIG.jokers.gluttonous_joker.rebalance then
    SMODS.Joker:take_ownership("j_gluttenous_joker", {
        config = {
            extra = {
            s_mult = 3,
            suit = "Clubs",
            increase = 1
            }
        },
        
        loc_vars = function(self, info_queue, card)
            return {
                key = "j_yarm_gluttonous_joker",
                vars = {
                    card.ability.extra.s_mult,
                    card.ability.extra.increase,
                    get_sinful_mult(card)
                }
            }
        end,

        calculate = function(self, card, context)
            if context.individual
                and context.cardarea == G.play
                and context.other_card
                and context.other_card:is_suit(card.ability.extra.suit)
                and not context.other_card.debuff then

                return {
                    mult = get_sinful_mult(card)
                }
            end
        end
    })
end
