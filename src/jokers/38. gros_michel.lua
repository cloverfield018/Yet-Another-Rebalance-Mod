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
    local gros_michel = {
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
    }

    -- Keep the original odds and only change Mult when enabled.
    -- When the rebalance toggle is off, `config` is omitted so the
    -- vanilla values (+15 Mult, 1 in 6) are preserved.
    if gros_michel_rebalance then
        gros_michel.config = {
            extra = {
                odds = 6,
                mult = 12,
            }
        }
    end

    -- Replace the vanilla extinction behavior only while Loyalty Card's
    -- Food synergy is rebalanced. When it is off, `calculate` is omitted
    -- so `take_ownership` keeps the vanilla implementation untouched.
    if loyalty_card_rebalance then
        gros_michel.calculate = function(self, card, context)
            if context.end_of_round
                and context.main_eval
                and not context.blueprint then

                -- Returning nil here would fall through to the vanilla
                -- end_of_round branch, which has no game_over guard.
                -- Short-circuit it with a no-op so Gros Michel is not
                -- eaten on a lost round.
                if context.game_over then
                    return nil, true
                end

                -- Vanilla odds (1 in 6) with the vanilla RNG seed so
                -- seeded runs match vanilla outcomes.
                if SMODS.pseudorandom_probability(
                    card,
                    'gros_michel',
                    1,
                    card.ability.extra.odds
                ) then
                    -- `SMODS.destroy_cards` emits `joker_type_destroyed`,
                    -- the single path that notifies Food Jokers. Do not
                    -- call `trigger_food_joker_event` here as well.
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

            -- No blueprint guard here: Blueprint and Brainstorm must still
            -- copy the +Mult. The vanilla joker_main branch that this
            -- replaces is skipped because `calculate` returns truthy.
            if context.joker_main then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end

    SMODS.Joker:take_ownership("gros_michel", gros_michel)
end