-- Register Loyalty Card's configuration toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Loyalty Card",
    ref_table = YARM_CONFIG.jokers.loyalty_card,
    ref_value = "rebalance",
})

-- Tracks, per card, the last hand already evaluated and whether it
-- activated on that hand. Kept outside `ability` so it is not persisted
-- or inherited by cards created with copy_card.
local processed_hand = setmetatable({}, {
    __mode = "k"
})
local activated_hand = setmetatable({}, {
    __mode = "k"
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
            -- Register Food Joker purchases.
            -- Blueprint copies must not register purchase events.
            if context.buying_card
                and context.card
                and not context.blueprint then

                trigger_food_joker_event(context.card, "bought")
            end

            -- Register Food Joker consumption.
            -- `destroyed` is only set by SMODS.destroy_cards, which the
            -- vanilla self-consumption path goes through. External
            -- destruction (Madness, Ceremonial Dagger, Hex, Ankh) uses
            -- start_dissolve directly and is ignored.
            if context.joker_type_destroyed
                and context.card
                and context.card.destroyed
                and not context.blueprint then

                trigger_food_joker_event(context.card, "eaten")
            end

            if not context.joker_main then
                return
            end

            local extra = card.ability.extra
            local hand = G.GAME.hands_played

            -- A hand must only be processed once per card, even when the
            -- card is evaluated more than once (Blueprint, Brainstorm or
            -- retriggers). Copies still receive the X4 on the hand the
            -- card activated.
            if processed_hand[card] == hand then
                if activated_hand[card] == hand then
                    return {
                        x_mult = extra.Xmult
                    }
                end

                return {
                    no_retrigger = true
                }
            end

            processed_hand[card] = hand

            -- Initialize the persistent countdown for this card.
            if card.ability.loyalty_countdown == nil then
                card.ability.loyalty_countdown = extra.every
            end

            -- Track extra Food Joker steps that must be accounted for
            -- when starting the next countdown cycle.
            if card.ability.food_steps_pending == nil then
                card.ability.food_steps_pending = 0
            end

            local remaining = card.ability.loyalty_countdown

            -- If Loyalty Card was already Active! before this evaluation,
            -- grant X4 and start the next cycle.
            --
            -- Pending Food Joker steps are absorbed into the next cycle.
            -- At most `every` steps can shorten it; any excess is kept as
            -- pending so no reduction is lost across cycles.
            if remaining == 0 then
                local pending = card.ability.food_steps_pending or 0
                local absorbed = math.min(pending, extra.every)

                card.ability.loyalty_countdown =
                    extra.every - absorbed
                card.ability.food_steps_pending =
                    pending - absorbed

                card.ability.loyalty_remaining =
                    card.ability.loyalty_countdown

                activated_hand[card] = hand

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

            return {
                no_retrigger = true
            }
        end,
    })
end