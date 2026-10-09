-- Register Four Fingers' config toggles.
-- The main toggle controls the rebalance; subtoggles configure its rules.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Four Fingers",
    ref_table = YARM_CONFIG.jokers.four_fingers,
    ref_value = "rebalance",

    subtoggles = {
        {
            label = "Remove Flush",
            ref_table = YARM_CONFIG.jokers.four_fingers,
            ref_value = "remove_flush",
        },
        {
            label = "F. House Rank Restriction",
            ref_table = YARM_CONFIG.jokers.four_fingers,
            ref_value = "rank_restriction",
        },
    },
})

-- Use vanilla localization when disabled; otherwise select the variant
-- matching Remove Flush and rank restriction (in that order).
-- Four Fingers
SMODS.Joker:take_ownership("j_four_fingers", {
    loc_vars = function(self, info_queue, card)
        local ff_config = YARM_CONFIG.jokers.four_fingers

        if not ff_config.rebalance then
            return {
                key = "j_four_fingers",
                vars = {}
            }
        end

        local key = "j_yarm_four_fingers_"
            .. (ff_config.remove_flush and "1" or "0")
            .. (ff_config.rank_restriction and "1" or "0")

        return {
            key = key,
            vars = {}
        }
    end
})


-- Configuration
local ff_config = YARM_CONFIG.jokers.four_fingers

-- Reset subtoggles when the main rebalance is disabled.
if not ff_config.rebalance then
    ff_config.remove_flush = false
    ff_config.rank_restriction = false
end

-- Apply the rebalance only when enabled.
if ff_config.rebalance then

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
        local ff_config = YARM_CONFIG.jokers.four_fingers

        local hand_size = #hand

        -- Four Fingers rebalance must be enabled.
        if not ff_config.rebalance then
            return ret
        end

        local allow_four_card_flush =
            not ff_config.remove_flush and has_four_fingers()

        -- Preserve the normal 5-card Flush.
        if hand_size == 5 then
            local suits = {
                "Spades",
                "Hearts",
                "Clubs",
                "Diamonds"
            }

            for _, suit in ipairs(suits) do
                local t = {}

                for _, card in ipairs(hand) do
                    if card:is_suit(suit, nil, true) then
                        t[#t + 1] = card
                    end
                end

                if #t == 5 then
                    return { t }
                end
            end

            -- Four Fingers: 4 cards of the same suit among 5 cards.
            if allow_four_card_flush then
                for _, suit in ipairs(suits) do
                    local t = {}

                    for _, card in ipairs(hand) do
                        if card:is_suit(suit, nil, true) then
                            t[#t + 1] = card
                        end
                    end

                    if #t >= 4 then
                        return { t }
                    end
                end
            end

            return ret
        end

        -- Four Fingers: exactly 4 cards of the same suit.
        if hand_size == 4 and allow_four_card_flush then
            local suits = {
                "Spades",
                "Hearts",
                "Clubs",
                "Diamonds"
            }

            for _, suit in ipairs(suits) do
                local t = {}

                for _, card in ipairs(hand) do
                    if card:is_suit(suit, nil, true) then
                        t[#t + 1] = card
                    end
                end

                if #t == 4 then
                    return { t }
                end
            end
        end

        return ret
    end


    -- Straight Flush
    SMODS.PokerHand:take_ownership("Straight Flush", {
        evaluate = function(parts, hand)
            if not next(parts._straight) then return {} end

            -- Preserve the normal 5-card Straight Flush.
            if next(parts._flush) then
                return { SMODS.merge_lists(parts._straight, parts._flush) }
            end

            -- Four Fingers: find 4 consecutive cards of the same suit
            -- within the detected Straight, even if it contains 5 cards.
            if has_four_fingers() then
                local straight_cards = parts._straight[1]

                if straight_cards and #straight_cards >= 4 then
                    local suits = {
                        "Spades",
                        "Hearts",
                        "Clubs",
                        "Diamonds"
                    }

                    for _, suit in ipairs(suits) do
                        local suited_cards = {}

                        for _, card in ipairs(straight_cards) do
                            if card:is_suit(suit, nil, true) then
                                suited_cards[#suited_cards + 1] = card
                            end
                        end

                        if #suited_cards >= 4 then
                            -- Return the full detected Straight so off-suit cards that complete it
                            -- still score, rather than returning only the suited subset.
                            return { straight_cards }
                        end
                    end
                end
            end

            return {}
        end
    }, true)


    -- Helpers for Full House rank restriction.
    -- Group ranks as Odd (including Ace), Even, or Face for the optional
    -- four-card Full House and Flush House restriction.
    local function get_rank_group(card)
        local rank = card:get_id()

        if card:is_face() then
            return "face"
        elseif rank == 2 or rank == 4 or rank == 6
            or rank == 8 or rank == 10 then
            return "even"
        elseif rank == 3 or rank == 5 or rank == 7 
            or rank == 9 or rank == 14 then
            return "odd"
        end

        return nil
    end

    local function has_matching_rank_group(hand)
        if not YARM_CONFIG.jokers.four_fingers.rank_restriction then
            return true
        end

        if #hand ~= 4 then
            return false
        end

        local group = get_rank_group(hand[1])

        if not group then
            return false
        end

        for i = 2, #hand do
            if get_rank_group(hand[i]) ~= group then
                return false
            end
        end

        return true
    end


    -- Full House
    SMODS.PokerHand:take_ownership("Full House", {
        evaluate = function(parts, hand)
            if #parts._2 < 2 then return {} end

            -- Preserve normal 5-card Full Houses.
            if #parts._3 >= 1 then
                return parts._all_pairs
            end

            -- Four Fingers: two pairs can count as a Full House.
            if not has_four_fingers() then return {} end

            local pair_cards = parts._all_pairs[1]

            if not pair_cards or #pair_cards ~= 4 then
                return {}
            end

            if not has_matching_rank_group(pair_cards) then
                return {}
            end

            return parts._all_pairs
        end
    }, true)


    -- Flush House
    SMODS.PokerHand:take_ownership("Flush House", {
        evaluate = function(parts, hand)
            -- Normal Flush House: Three of a Kind + Pair + 5-card Flush.
            if #parts._3 >= 1 and next(parts._flush) then
                local flush_cards = parts._flush[1]

                if flush_cards and #flush_cards == 5 then
                    return { SMODS.merge_lists(parts._all_pairs, parts._flush) }
                end
            end

            -- A special Four Fingers Flush House uses four suited cards forming
            -- two pairs; a fifth card may be present in the selected hand.
            if not has_four_fingers() then return {} end

            local pair_cards = parts._all_pairs[1]

            if not pair_cards or #pair_cards < 4 then
                return {}
            end

            -- Find four cards forming two pairs, all of the same suit.
            local suits = {
                "Spades",
                "Hearts",
                "Clubs",
                "Diamonds"
            }

            for _, suit in ipairs(suits) do
                local suited_cards = {}

                for _, card in ipairs(pair_cards) do
                    if card:is_suit(suit, nil, true) then
                        suited_cards[#suited_cards + 1] = card
                    end
                end

                if #suited_cards >= 4 then
                    local four_cards = {
                        suited_cards[1],
                        suited_cards[2],
                        suited_cards[3],
                        suited_cards[4]
                    }

                    if has_matching_rank_group(four_cards) then
                        return { four_cards }
                    end
                end
            end

            return {}
        end
    }, true)

end
