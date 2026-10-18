-- Register Raised Fist's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Raised Fist",
    ref_table = YARM_CONFIG.jokers.raised_fist,
    ref_value = "rebalance",
})

-- Raised Fist
if YARM_CONFIG.jokers.raised_fist.rebalance then
    SMODS.Joker:take_ownership("raised_fist", {
        config = {
            extra = {
                mult = 3,
            }
        },

        loc_vars = function(self, info_queue, card)
            return {
                key = "j_yarm_raised_fist",
                vars = {
                    card.ability.extra.mult,
                }
            }
        end,

        calculate = function(self, card, context)
            -- Prevent the vanilla Raised Fist special case from interfering.
            if card.ability.name == "Raised Fist" then
                card.ability.name = "YARM Raised Fist"
            end

            if context.individual
                and context.cardarea == G.hand
                and not context.end_of_round then

                local lowest_card = nil
                local lowest_id = 11

                for _, held_card in ipairs(G.hand.cards) do
                    local id = held_card.base.id

                    if id >= 2
                        and id <= 10
                        and id < lowest_id
                        and not SMODS.has_no_rank(held_card) then
                        lowest_id = id
                        lowest_card = held_card
                    end
                end

                if lowest_card == context.other_card then
                    if context.other_card.debuff then
                        return {
                            message = localize("k_debuffed"),
                            colour = G.C.RED,
                        }
                    end

                    return {
                        mult = card.ability.extra.mult * lowest_card.base.nominal,
                    }
                end
            end
        end,
    })
end