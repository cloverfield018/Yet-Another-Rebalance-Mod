return {
    descriptions = {
        -- Jokers
        Joker = {
            -- Jimbo
            j_yarm_jimbo = {
                name = "Jimbo",
                text = {
                    "{C:mult}+#1#{} Mult",
                    "This Joker gains {C:mult}+#2#{} Mult",
                    "for every defeated",
                    "Boss Blind this run",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- Greedy Joker
            j_yarm_greedy_joker = {
                text = {
                    "Played cards with {C:diamonds}Diamond{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- Lusty Joker
            j_yarm_lusty_joker = {
                text = {
                    "Played cards with {C:hearts}Hearts{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- Wrathful Joker
            j_yarm_wrathful_joker = {
                text = {
                    "Played cards with {C:spades}Spades{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- Gluttonous Joker
            j_yarm_gluttonous_joker = {
                text = {
                    "Played cards with {C:clubs}Clubs{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- Four Fingers: localization variants for each combination of config toggles.
            j_yarm_four_fingers_00 = {
                text = {
                    "All {C:attention}Flushes{} and {C:attention}Straights{}",
                    "can be made with 4 cards",
                    "Every poker hand",
                    "containing a {C:attention}Full House{}",
                    "can be made with 2 pairs"
                }
            },
            j_yarm_four_fingers_01 = {
                text = {
                    "All {C:attention}Flushes{} and {C:attention}Straights{}",
                    "can be made with 4 cards",
                    "Every poker hand",
                    "containing a {C:attention}Full House{}",
                    "can be made with 2 pairs",
                    "of the same rank group",
                    "{C:inactive}(Odd, Even or Face){}"
                }
            },
            j_yarm_four_fingers_10 = {
                text = {
                    "Every poker hand",
                    "containing a {C:attention}Straight{} or",
                    "{C:attention}Full House{} can be made",
                    "with 4 consecutive cards",
                    "or 2 pairs respectively"
                }
            },
            j_yarm_four_fingers_11 = { -- Default
                text = {
                    "Every poker hand",
                    "containing a {C:attention}Straight{} or",
                    "{C:attention}Full House{} can be made",
                    "with 4 consecutive cards",
                    "or 2 pairs of the same",
                    "rank group respectively",
                    "{C:inactive}(Odd, Even or Face){}"
                }
            }
        },
    }
}
