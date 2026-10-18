-- Register Loyalty Card's configuration toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Loyalty Card",
    ref_table = YARM_CONFIG.jokers.loyalty_card,
    ref_value = "rebalance",
})

-- Loyalty Card
if YARM_CONFIG.jokers.loyalty_card.rebalance then
    SMODS.Joker:take_ownership("loyalty_card", {
        config = {
            extra = {
                Xmult = 4,
                every = 4,
            }
        },

        loc_vars = function(self, info_queue, card)
            return {
                key = "j_yarm_loyalty_card",
                vars = {
                    card.ability.extra.Xmult,
                    card.ability.extra.every + 1,

                    -- Display Active! when the countdown reaches zero.
                    -- In Lua, 0 is truthy, so the fallback only applies to nil or false.
                    localize {
                        type = "variable",
                        key = (
                            (card.ability.loyalty_countdown
                                or card.ability.extra.every) == 0
                            and "loyalty_active"
                            or "loyalty_inactive"
                        ),
                        vars = {
                            card.ability.loyalty_countdown
                                or card.ability.extra.every
                        }
                    }
                }
            }
        end,

        calculate = function(self, card, context)

            -- Prevent the vanilla Card:calculate_joker Loyalty Card special
            -- case from interfering with this custom countdown implementation.
            if card.ability.name == "Loyalty Card" then
                card.ability.name = "YARM Loyalty Card"
            end

            -- Register Food Joker purchases.
            -- Blueprint copies must not register purchase events.
            if context.buying_card
                and context.card
                and not context.blueprint then

                trigger_food_joker_event(context.card, "bought")
            end

            local extra = card.ability.extra
            local cycle = extra.every + 1

            -- Initialize the persistent countdown for this card.
            if card.ability.loyalty_countdown == nil then
                card.ability.loyalty_countdown = extra.every
            end

            -- Track extra Food Joker steps that must be accounted for
            -- when starting the next countdown cycle.
            if card.ability.food_steps_pending == nil then
                card.ability.food_steps_pending = 0
            end

            if context.joker_main then
                local remaining = card.ability.loyalty_countdown

                -- If Loyalty Card was already Active! before this evaluation,
                -- grant X4 and start the next cycle.
                --
                -- Food Joker steps accumulated while Active! are applied
                -- to the next cycle before the pending counter is cleared.
                if remaining == 0 then
                    local pending = card.ability.food_steps_pending or 0

                    card.ability.loyalty_countdown =
                        (extra.every - pending) % cycle

                    card.ability.food_steps_pending = 0

                    card.ability.loyalty_remaining =
                        card.ability.loyalty_countdown

                    return {
                        x_mult = extra.Xmult
                    }
                end

                -- Advance the countdown by one normal hand.
                -- Reaching zero activates Loyalty Card but does not grant X4
                -- or reset the countdown until the next Joker evaluation.
                remaining = remaining - 1
                card.ability.loyalty_countdown = remaining
                card.ability.loyalty_remaining = remaining

                -- Start the activation animation when the countdown reaches zero.
                if remaining == 0 then
                    local eval = function(c)
                        return c.ability.loyalty_countdown == 0
                    end

                    juice_card_until(card, eval, true)
                end
            end
        end,
    })
end