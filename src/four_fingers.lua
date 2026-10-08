-- Four Fingers
SMODS.Joker:take_ownership("j_four_fingers", {
    loc_vars = function(self, info_queue, card)
        return {
            key = "j_yarm_four_fingers",
            vars = {}
        }
    end
})


-- Helpers
local function has_four_fingers()
    return next(SMODS.find_card("j_four_fingers"))
end

local function is_four_card_flush(hand)
    local suits = {
        "Spades",
        "Hearts",
        "Clubs",
        "Diamonds"
    }

    for _, suit in ipairs(suits) do
        local count = 0

        for _, card in ipairs(hand) do
            if card:is_suit(suit, nil, true) then
                count = count + 1
            end
        end

        if count >= 4 then
            return true
        end
    end

    return false
end


-- Straight
local smods_four_fingers_ref = SMODS.four_fingers

function SMODS.four_fingers(hand_type, ...)
    if has_four_fingers() and hand_type == "straight" then
        return 4
    end

    return smods_four_fingers_ref(hand_type, ...)
end


-- Flush
function get_flush(hand)
    local ret = {}
    local suits = {
        "Spades",
        "Hearts",
        "Clubs",
        "Diamonds"
    }

    if #hand > 5 or #hand < 5 then return ret end

    for _, suit in ipairs(suits) do
        local t = {}
        local flush_count = 0

        for i = 1, #hand do
            if hand[i]:is_suit(suit, nil, true) then
                flush_count = flush_count + 1
                t[#t + 1] = hand[i]
            end
        end

        if flush_count >= 5 then
            table.insert(ret, t)
            return ret
        end
    end

    return {}
end


-- Straight Flush
SMODS.PokerHand:take_ownership("Straight Flush", {
    evaluate = function(parts, hand)
        if not next(parts._straight) then return {} end

        -- Preserve the normal 5-card Straight Flush.
        if next(parts._flush) then
            return { SMODS.merge_lists(parts._straight, parts._flush) }
        end

        -- Check for the special 4-card Straight Flush.
        if has_four_fingers() then
            local straight_cards = parts._straight[1]

            if #straight_cards == 4 and is_four_card_flush(straight_cards) then
                return parts._straight
            end
        end

        return {}
    end
}, true)


-- Full House
SMODS.PokerHand:take_ownership("Full House", {
    evaluate = function(parts, hand)
        if #parts._2 < 2 then return {} end
        if #parts._3 < 1 and not has_four_fingers() then return {} end

        return parts._all_pairs
    end
}, true)


-- Flush House
SMODS.PokerHand:take_ownership("Flush House", {
    evaluate = function(parts, hand)
        if #parts._2 < 2 then return {} end

        -- Preserve the normal Flush House.
        if #parts._3 >= 1 and next(parts._flush) then
            return { SMODS.merge_lists(parts._all_pairs, parts._flush) }
        end

        -- Four Fingers: two pairs + four cards of the same suit.
        local pair_cards = parts._all_pairs[1]

        if has_four_fingers() and is_four_card_flush(pair_cards) then
            return parts._all_pairs
        end

        return {}
    end
}, true)