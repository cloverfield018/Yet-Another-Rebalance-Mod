-- Greedy Joker
SMODS.Joker:take_ownership("j_greedy_joker", {
    config = {
        extra = {
            s_mult = 3,
            suit = "Diamonds",
            increase = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            key = "j_yarm_greedy_joker",
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