-- Register Credit Card's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Credit Card",
    ref_table = YARM_CONFIG.jokers.credit_card,
    ref_value = "rebalance",
})

-- Refresh card costs after Credit Card is added or removed.
local function refresh_voucher_costs()
    if not G or not G.I or not G.I.CARD or not G.E_MANAGER then
        return
    end

    G.E_MANAGER:add_event(Event({
        func = function()
            for _, card in pairs(G.I.CARD) do
                if card.set_cost then
                    card:set_cost()
                end
            end
            return true
        end
    }))
end

-- Credit Card
if YARM_CONFIG.jokers.credit_card.rebalance then
    SMODS.Joker:take_ownership("credit_card", {
        blueprint_compat = true,

        config = {
            extra = 20,
            rebalance_extra = {
                voucher_discount = 20,
                booster_money = 2,
            }
        },

        loc_vars = function(self, info_queue, card)
            return {
                key = "j_yarm_credit_card",
                vars = {
                    card.ability.extra,
                    card.ability.rebalance_extra.voucher_discount,
                    card.ability.rebalance_extra.booster_money,
                }
            }
        end,

        -- Let vanilla handle the bankruptcy limit.
        add_to_deck = function(self, card, from_debuff)
            refresh_voucher_costs()
        end,

        remove_from_deck = function(self, card, from_debuff)
            refresh_voucher_costs()
        end,

        calculate = function(self, card, context)
            if context.skipping_booster then
                local choices = G.GAME and G.GAME.pack_choices or 0
                local dollars =
                    math.max(choices, 0)
                    * card.ability.rebalance_extra.booster_money

                if dollars > 0 then
                    return {
                        dollars = dollars,
                        colour = G.C.MONEY,
                    }
                end
            end
        end,
    })

    -- Apply an additive discount to Vouchers while Credit Card is active.
    local card_set_cost_ref = Card.set_cost

    function Card:set_cost(...)
        card_set_cost_ref(self, ...)

        if YARM_CONFIG.jokers.credit_card.rebalance
            and G.jokers
            and self.ability
            and self.ability.set == "Voucher" then

            local credit_cards = SMODS.find_card("j_credit_card")
            local credit_card = credit_cards[1]

            if credit_card and not credit_card.debuff then
                local credit_discount =
                    credit_card.ability.rebalance_extra.voucher_discount

                local vanilla_discount = G.GAME.discount_percent or 0
                local total_discount = math.min(
                    100,
                    vanilla_discount + credit_discount
                )

                local base_price =
                    (self.base_cost or 0) + (self.extra_cost or 0)

                self.cost = math.max(
                    1,
                    math.floor(
                        (base_price + 0.5)
                        * (100 - total_discount) / 100
                    )
                )

                self.sell_cost = math.max(
                    1,
                    math.floor(self.cost / 2)
                ) + (self.ability.extra_value or 0)

                self.sell_cost_label =
                    self.facing == "back" and "?" or self.sell_cost
            end
        end
    end
end