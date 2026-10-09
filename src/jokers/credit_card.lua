-- Register Credit Card's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Credit Card",
    ref_table = YARM_CONFIG.jokers.credit_card,
    ref_value = "rebalance",
})

-- Credit Card
if YARM_CONFIG.jokers.credit_card.rebalance then
    SMODS.Joker:take_ownership("credit_card", {
        cost = 2,
        blueprint_compat = true,

        config = {
            extra = {
                bankrupt_at = 20,
                voucher_discount = 20,
                booster_money = 2,
            }
        },

        loc_vars = function(self, info_queue, card)
            return {
                key = "j_yarm_credit_card",
                vars = {
                    card.ability.extra.bankrupt_at,
                    card.ability.extra.voucher_discount,
                    card.ability.extra.booster_money,
                }
            }
        end,

        add_to_deck = function(self, card, from_debuff)
            G.GAME.bankrupt_at =
                G.GAME.bankrupt_at - card.ability.extra.bankrupt_at
        end,

        remove_from_deck = function(self, card, from_debuff)
            G.GAME.bankrupt_at =
                G.GAME.bankrupt_at + card.ability.extra.bankrupt_at
        end,

        calculate = function(self, card, context)
            if context.skipping_booster then
                local choices = G.GAME and G.GAME.pack_choices or 0
                local dollars =
                    math.max(choices, 0) * card.ability.extra.booster_money

                if dollars > 0 then
                    return {
                        dollars = dollars,
                        colour = G.C.MONEY,
                    }
                end
            end
        end,
    })

    -- Apply a discount to Vouchers while Credit Card is active.
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
                local discount =
                    credit_card.ability.extra.voucher_discount

                self.cost = math.max(
                    1,
                    math.floor(
                        self.cost * (100 - discount) / 100 + 0.5
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

-- Refresh all card costs after Credit Card is added or removed.
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

-- Preserve the original methods for cards other than Credit Card.
local joker_add_to_deck_ref = Card.add_to_deck

function Card:add_to_deck(from_debuff)
    local is_credit_card =
        self.config
        and self.config.center
        and self.config.center.key == "j_credit_card"
        and YARM_CONFIG.jokers.credit_card.rebalance

    if not is_credit_card then
        joker_add_to_deck_ref(self, from_debuff)
    else
        self.config.center.add_to_deck(
            self.config.center,
            self,
            from_debuff
        )
    end

    if is_credit_card then
        refresh_voucher_costs()
    end
end

-- Preserve the original removal behavior for other cards.
local joker_remove_from_deck_ref = Card.remove_from_deck

function Card:remove_from_deck(from_debuff)
    local is_credit_card =
        self.config
        and self.config.center
        and self.config.center.key == "j_credit_card"
        and YARM_CONFIG.jokers.credit_card.rebalance

    if not is_credit_card then
        joker_remove_from_deck_ref(self, from_debuff)
    else
        self.config.center.remove_from_deck(
            self.config.center,
            self,
            from_debuff
        )
    end

    if is_credit_card then
        refresh_voucher_costs()
    end
end