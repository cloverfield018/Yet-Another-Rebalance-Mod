-- Register Gros Michel's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Gros Michel",
    ref_table = YARM_CONFIG.jokers.gros_michel,
    ref_value = "rebalance",
})

local gros_michel_rebalance =
    YARM_CONFIG.jokers.gros_michel.rebalance

local loyalty_card_rebalance =
    YARM_CONFIG.jokers.loyalty_card.rebalance

-- Gros Michel
if gros_michel_rebalance or loyalty_card_rebalance then
    SMODS.Joker:take_ownership("gros_michel", {
        -- Keep the original odds and only change Mult when enabled.
        config = {
            extra = {
                odds = 6,
                mult = gros_michel_rebalance and 12 or 15,
            }
        },

        loc_vars = function(self, info_queue, card)
            local numerator, denominator = SMODS.get_probability_vars(
                card,
                1,
                card.ability.extra.odds
            )

            return {
                key = loyalty_card_rebalance
                    and "j_yarm_gros_michel"
                    or nil,
                vars = {
                    card.ability.extra.mult,
                    numerator,
                    denominator,
                }
            }
        end,

        -- Replace extinction behavior only when Loyalty Card is rebalanced.
        calculate = loyalty_card_rebalance and function(self, card, context)
            if context.end_of_round
                and context.game_over == false
                and context.main_eval
                and not context.blueprint then

                if SMODS.pseudorandom_probability(
                    card,
                    'j_yarm_gros_michel',
                    1,
                    card.ability.extra.odds
                ) then
                    trigger_food_joker_event(card, "eaten")

                    SMODS.destroy_cards(card, nil, nil, true)
                    G.GAME.pool_flags.gros_michel_extinct = true

                    return {
                        message = localize('k_eaten_ex')
                    }
                else
                    return {
                        message = localize('k_safe_ex')
                    }
                end
            end

            if context.joker_main then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end or nil,
    })
end