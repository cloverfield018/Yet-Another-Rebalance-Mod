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
            label = "F.H. Rank Restriction",
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

    local function get_special_flush_cards(hand)
        for _, suit in ipairs(SMODS.Suit.obj_buffer) do
            local suited_cards = {}

            for _, card in ipairs(hand) do
                if card:is_suit(suit, nil, true) then
                    suited_cards[#suited_cards + 1] = card
                end
            end

            if #suited_cards >= 4 then
                return suited_cards
            end
        end
    end


    -- Flush
    function get_flush(hand)
        local ret = {}

        local hand_size = #hand

        local allow_four_card_flush =
            not ff_config.remove_flush and has_four_fingers()

        -- Preserve the normal 5-card Flush.
        if hand_size == 5 then
            local suits = SMODS.Suit.obj_buffer

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
            local suits = SMODS.Suit.obj_buffer

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

            local flush_cards = parts._flush[1]

            if not flush_cards and has_four_fingers() then
                flush_cards = get_special_flush_cards(hand)
            end

            if not flush_cards then return {} end

            return { SMODS.merge_lists(parts._straight, { flush_cards }) }
        end
    }, true)


    -- Helpers for Full House rank restriction.
    -- Group ranks as Odd (including Ace), Even, or Face for the optional
    -- four-card Full House and Flush House restriction.
    local function has_non_debuffed_pareidolia()
        if type(SMODS) ~= "table"
            or type(SMODS.find_card) ~= "function" then
            return false
        end

        local pareidolias = SMODS.find_card("j_pareidolia")
        return type(pareidolias) == "table" and next(pareidolias) ~= nil
    end

    local function get_rank_group(card)
        if type(card) ~= "table" then
            return nil
        end

        if YARM.is_intrinsic_face(card) then
            return "face"
        end

        if not card.debuff and has_non_debuffed_pareidolia() then
            return "face"
        end

        if YARM.is_even(card) then
            return "even"
        end

        if YARM.is_odd(card) then
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
            if #parts._2 < 2 then return {} end

            local full_house_cards

            -- Normal Flush House: Three of a Kind + Pair.
            if #parts._3 >= 1 then
                full_house_cards = parts._all_pairs[1]
            else
                -- Four Fingers: two pairs can count as a Full House.
                if not has_four_fingers() then return {} end

                local pair_cards = parts._all_pairs[1]

                if not pair_cards or #pair_cards ~= 4 then
                    return {}
                end

                if not has_matching_rank_group(pair_cards) then
                    return {}
                end

                full_house_cards = pair_cards
            end

            local flush_cards = parts._flush[1]

            if not flush_cards and has_four_fingers() then
                flush_cards = get_special_flush_cards(hand)
            end

            if not full_house_cards or not flush_cards then
                return {}
            end

            return { SMODS.merge_lists({ full_house_cards }, { flush_cards }) }
        end
    }, true)
end