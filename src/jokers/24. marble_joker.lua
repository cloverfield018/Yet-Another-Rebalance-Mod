-- Register Marble Joker's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Marble Joker",
    ref_table = YARM_CONFIG.jokers.marble,
    ref_value = "rebalance",
})

-- Marble Joker
if YARM_CONFIG.jokers.marble.rebalance then
    SMODS.Joker:take_ownership("marble", {
        calculate = function(self, card, context)
            if context.setting_blind then
                local stone_card = SMODS.create_card {
                    set = "Base",
                    enhancement = "m_stone",
                    area = G.discard,
                    no_edition = true,
                }

                -- Roll for a playing card edition using vanilla logic.
                local edition = poll_edition(
                    "marble_edition" ..
                    tostring((G.playing_card or 0) + 1),
                    2,
                    true
                )

                if edition then
                    stone_card:set_edition(edition, true, true)
                end

                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                stone_card.playing_card = G.playing_card
                table.insert(G.playing_cards, stone_card)

                G.E_MANAGER:add_event(Event({
                    func = function()
                        stone_card:start_materialize({
                            G.C.SECONDARY_SET.Enhanced
                        })
                        G.play:emplace(stone_card)
                        return true
                    end
                }))

                return {
                    message = localize('k_plus_stone'),
                    colour = G.C.SECONDARY_SET.Enhanced,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.deck.config.card_limit =
                                    G.deck.config.card_limit + 1
                                return true
                            end
                        }))

                        draw_card(G.play, G.deck, 90, 'up')

                        SMODS.calculate_context({
                            playing_card_added = true,
                            cards = { stone_card }
                        })
                    end
                }
            end
        end,
    })
end