-- Sinful Jokers
local sinful_jokers = {
    j_greedy_joker = true,
    j_lusty_joker = true,
    j_wrathful_joker = true,
    j_gluttenous_joker = true
}

function count_other_sinful_jokers(card)
    local count = 0

    if not G.jokers or not G.jokers.cards then
        return count
    end

    for _, joker in ipairs(G.jokers.cards) do
        if joker ~= card
            and joker.config
            and joker.config.center
            and sinful_jokers[joker.config.center.key] then

            count = count + 1
        end
    end

    return count
end

function get_sinful_mult(card)
    local base_mult = card.ability.extra.s_mult
    local increase = card.ability.extra.increase
    local other_sinful = count_other_sinful_jokers(card)

    return base_mult + (increase * other_sinful)
end