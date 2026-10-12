-- Register Ceremonial Dagger's config toggles.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Ceremonial Dagger",
    ref_table = YARM_CONFIG.jokers.ceremonial,
    ref_value = "rebalance",

    subtoggles = {
        {
            label = "Destroy Left",
            ref_table = YARM_CONFIG.jokers.ceremonial,
            ref_value = "destroy_left",
        },
    },
})

-- Ceremonial Dagger
local config = YARM_CONFIG.jokers.ceremonial

-- Only take ownership when at least one option is enabled.
-- If both are disabled, keep the vanilla Joker unchanged.
if config.rebalance or config.destroy_left then
    SMODS.Joker:take_ownership("ceremonial", {
        config = {
            extra = {
                times_value = 2,
                value_gain = 1,
                mult = 0,
            }
        },

        loc_vars = function(self, info_queue, card)
            local extra = card.ability.extra
            local key

            -- Select localization based on the active toggles.
            if config.rebalance then
                if config.destroy_left then
                    key = "j_yarm_ceremonial_dagger_11"
                else
                    key = "j_yarm_ceremonial_dagger_10"
                end
            else
                -- Rebalance off, Destroy Left on.
                key = "j_yarm_ceremonial_dagger_01"
            end

            local times_value = 2

            if config.rebalance then
                if G.GAME.used_vouchers.v_liquidation then
                    times_value = 3
                elseif G.GAME.used_vouchers.v_clearance_sale then
                    times_value = 2.5
                end
            end

            return {
                key = key,
                vars = {
                    times_value,
                    extra.value_gain,
                    extra.mult,
                }
            }
        end,

        calculate = function(self, card, context)
            if context.setting_blind
                and not context.blueprint
                and not card.getting_sliced then

                local my_pos

                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then
                        my_pos = i
                        break
                    end
                end

                -- Select the target side independently of rebalance.
                local direction = config.destroy_left and -1 or 1
                local sliced_card =
                    my_pos and G.jokers.cards[my_pos + direction]

                if sliced_card
                    and not SMODS.is_eternal(sliced_card, card)
                    and not sliced_card.getting_sliced then

                    local extra = card.ability.extra
                    local multiplier = 2

                    -- Voucher multipliers only apply with rebalance enabled.
                    if config.rebalance then
                        if G.GAME.used_vouchers.v_liquidation then
                            multiplier = 3
                        elseif G.GAME.used_vouchers.v_clearance_sale then
                            multiplier = 2.5
                        end
                    end

                    local sell_cost = sliced_card.sell_cost or 0
                    local mult_gain = math.floor(sell_cost * multiplier)

                    -- Mark the target before scheduling destruction.
                    sliced_card.getting_sliced = true
                    G.GAME.joker_buffer = G.GAME.joker_buffer - 1

                    -- Permanent Mult gain.
                    extra.mult = extra.mult + mult_gain

                    -- Extra sell value is part of the rebalance only.
                    if config.rebalance then
                        card.ability.extra_value =
                            (card.ability.extra_value or 0)
                            + extra.value_gain

                        card:set_cost()
                    end

                    card:juice_up(0.8, 0.8)

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.joker_buffer = 0

                            sliced_card:start_dissolve(
                                { HEX("57ecab") },
                                nil,
                                1.6
                            )

                            play_sound(
                                "slice1",
                                0.96 + math.random() * 0.08
                            )

                            return true
                        end
                    }))

                    return {
                        message = localize({
                            type = "variable",
                            key = "a_mult",
                            vars = { mult_gain }
                        }),
                        colour = G.C.RED,
                        no_juice = true
                    }
                end

                -- Prevent fallback behavior from destroying the other side.
                return {}
            end

            if context.joker_main then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end,
    })
end