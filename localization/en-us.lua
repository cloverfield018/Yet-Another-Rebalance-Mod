return {
    descriptions = {
        -- Jokers
        Joker = {
            -- 1. Jimbo
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
            -- 2. Greedy Joker
            j_yarm_greedy_joker = {
                text = {
                    "Played cards with {C:diamonds}Diamond{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- 3. Lusty Joker
            j_yarm_lusty_joker = {
                text = {
                    "Played cards with {C:hearts}Hearts{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- 4. Wrathful Joker
            j_yarm_wrathful_joker = {
                text = {
                    "Played cards with {C:spades}Spades{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- 5. Gluttonous Joker
            j_yarm_gluttonous_joker = {
                text = {
                    "Played cards with {C:clubs}Clubs{} suit",
                    "give {C:mult}+#1#{} Mult when scored,",
                    "increases by {C:mult}+#2#{} Mult for every",
                    "other {C:attention}Sinful Joker{} owned",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            -- 7. Zany Joker
            j_yarm_zany_joker = {
            },
            -- 8. Mad Joker
            j_yarm_mad_joker = {
            },
            -- 9. Crazy Joker
            j_yarm_crazy_joker = {
            },
            -- 10. Droll Joker
            j_yarm_droll_joker = {
            },
            -- 12. Wily Joker
            j_yarm_wily_joker = {
            },
            -- 13. Clever Joker
            j_yarm_clever_joker = {
            },
            -- 14. Devious Joker
            j_yarm_devious_joker = {
            },
            -- 15. Crafty Joker
            j_yarm_crafty_joker = {
            },
            -- 18. Four Fingers
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
            },
            -- 19. Mime
            j_yarm_mime = {
            },
            -- 20. Credit Card
            j_yarm_credit_card = {
                text = {
                    "Go up to {C:red}-$#1#{} in debt",
                    "Vouchers are {C:attention}#2#%{} off",
                    "Earn {C:money}$#3#{} per unused",
                    "choice when any {C:attention}Booster{}",
                    "{C:attention}Pack{} is skipped"
                }
            },
            -- 21. Ceremonial Dagger
            j_yarm_ceremonial_dagger_01 = {
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "destroy Joker to the left",
                    "and permanently add {C:attention}double{}",
                    "its sell value to this {C:mult}Mult{}",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            j_yarm_ceremonial_dagger_10 = {
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "destroy Joker to the right,",
                    "permanently add {C:attention}#1#X{} its",
                    "sell value to this {C:mult}Mult{}",
                    "and gain {C:money}$#2#{} of sell value",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            j_yarm_ceremonial_dagger_11 = { -- Default
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "destroy Joker to the left,",
                    "permanently add {C:attention}#1#X{} its",
                    "sell value to this {C:mult}Mult{}",
                    "and gain {C:money}$#2#{} of sell value",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult){}"
                }
            },
            j_yarm_banner = {
                text = {
                    "{C:chips}+#1#{} Chips for each",
                    "remaining {C:attention}discard{}",
                    "{C:inactive}(Currently {C:chips}+#2# {C:inactive}Chips){}"
                }
            },
            j_yarm_mystic_summit = {
                text = {
                    "{C:mult}+#1#{} Mult for each",
                    "remaining {C:attention}discard{}",
                    "{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult){}"
                }
            },
            j_yarm_marble_joker = {
            }
        },
    }
}
