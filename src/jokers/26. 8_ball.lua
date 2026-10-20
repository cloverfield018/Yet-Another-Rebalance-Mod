-- Register 8 Ball's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "8 Ball",
    ref_table = YARM_CONFIG.jokers.eight_ball,
    ref_value = "rebalance",
})

-- Tracks, per 8 Ball card, whether it already created a Tag this round.
-- Kept outside `ability` so cards created with copy_card do not inherit
-- the limit. Blueprint/Brainstorm still resolve to the same real card,
-- so a single activation can never produce two Tags.
local tag_created_this_round = setmetatable({}, {
    __mode = "k"
})

-- 8 Ball
if YARM_CONFIG.jokers.eight_ball.rebalance then
    SMODS.Joker:take_ownership("8_ball", {
        config = {
            extra = {
                odds = 4,
                tag_odds = 32,
            }
        },

        loc_vars = function(self, info_queue, card)
            local tarot_num, tarot_den = SMODS.get_probability_vars(
                card, 1, card.ability.extra.odds, "8ball"
            )
            local tag_num, tag_den = SMODS.get_probability_vars(
                card, 1, card.ability.extra.tag_odds, "yarm_8_ball_tag"
            )

            return {
                key = "j_yarm_8_ball",
                vars = {
                    tarot_num,
                    tarot_den,
                    tag_num,
                    tag_den,
                }
            }
        end,

        calculate = function(self, card, context)
            -- Reset the Tag limit at the start of each round.
            if context.setting_blind and not context.blueprint then
                tag_created_this_round[card] = nil
            end

            if context.individual
                and context.cardarea == G.play
                and context.other_card:get_id() == 8 then

                local tag_effect = nil
                local tarot_effect = nil

                -- Roll for a Tag once per round per 8 Ball.
                if not tag_created_this_round[card]
                    and SMODS.pseudorandom_probability(
                        card,
                        "yarm_8_ball_tag",
                        1,
                        card.ability.extra.tag_odds
                    ) then

                    local tag_key = get_next_tag_key()

                    if tag_key then
                        tag_created_this_round[card] = true

                        tag_effect = {
                            message = localize("k_yarm_plus_tag"),
                            message_card = card,
                            blocking = false,
                            colour = G.C.GREEN,
                            func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = "before",
                                    delay = 0.7 * 1.25,
                                    func = function()
                                        add_tag(Tag(tag_key))
                                        return true
                                    end
                                }))
                            end
                        }
                    end
                end

                -- Roll for a Tarot only if consumable space is available.
                -- Uses the vanilla seed so the roll matches vanilla 8 Ball.
                if #G.consumeables.cards + G.GAME.consumeable_buffer
                    < G.consumeables.config.card_limit
                    and SMODS.pseudorandom_probability(
                        card,
                        "8ball",
                        1,
                        card.ability.extra.odds
                    ) then

                    G.GAME.consumeable_buffer =
                        G.GAME.consumeable_buffer + 1

                    tarot_effect = {
                        extra = {
                            message = localize("k_plus_tarot"),
                            message_card = card,
                            func = function()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        SMODS.add_card({
                                            set = "Tarot",
                                            key_append = "yarm_8_ball"
                                        })
                                        G.GAME.consumeable_buffer = 0
                                        return true
                                    end
                                }))
                            end
                        }
                    }
                end

                -- Return both effects if both probability rolls succeed.
                if tag_effect and tarot_effect then
                    tag_effect.extra = tarot_effect.extra
                    return tag_effect
                end

                -- Otherwise, return whichever effect succeeded.
                if tag_effect then
                    return tag_effect
                end

                if tarot_effect then
                    return tarot_effect
                end

                return nil, true
            end
        end,
    })
end