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
            if not (context.individual and context.cardarea == G.hand) then return end

            -- Carta que elegiría Raised Fist vanilla (para suprimir su rama).
            local vanilla_card, vanilla_id = nil, 15
            for _, held_card in ipairs(G.hand.cards) do
                local id = held_card.base.id
                if id and vanilla_id >= id and held_card.ability.effect ~= "Stone Card" then
                    vanilla_id = id
                    vanilla_card = held_card
                end
            end

            -- Carta elegible de YARM (menor rango 2-10).
            local yarm_card, yarm_id = nil, 11
            for _, held_card in ipairs(G.hand.cards) do
                local id = held_card.base.id
                if id and id >= 2 and id <= 10 and id < yarm_id and not SMODS.has_no_rank(held_card) then
                    yarm_id = id
                    yarm_card = held_card
                end
            end

            if not context.end_of_round and context.other_card == yarm_card then
                if context.other_card.debuff then
                    return { message = localize("k_debuffed"), colour = G.C.RED }
                end
                return { mult = card.ability.extra.mult * yarm_card.base.nominal }
            end

            -- Vanilla dispararía aquí pero YARM no concede nada: preempta la rama vanilla.
            if context.other_card == vanilla_card then
                return { no_retrigger = true }
            end
        end,
    })
end