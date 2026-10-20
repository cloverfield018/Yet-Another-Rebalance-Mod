-- Register Chaos the Clown's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Chaos the Clown",
    ref_table = YARM_CONFIG.jokers.chaos_the_clown,
    ref_value = "rebalance",
})


-- Chaos the Clown
if YARM_CONFIG.jokers.chaos_the_clown.rebalance then

    -- Maximum free rerolls a Chaos copy can hold for the round.
    local function get_chaos_rerolls()
        if G.GAME and G.GAME.used_vouchers then
            if G.GAME.used_vouchers.v_reroll_glut then
                return 3
            end

            if G.GAME.used_vouchers.v_reroll_surplus then
                return 2
            end
        end

        return 1
    end

    -- Every Chaos the Clown joker currently in play.
    local function chaos_cards()
        local cards = {}

        if G.jokers and G.jokers.cards then
            for _, card in ipairs(G.jokers.cards) do
                if card
                    and card.ability
                    and card.ability.name == "Chaos the Clown"
                then
                    cards[#cards + 1] = card
                end
            end
        end

        return cards
    end

    -- Chaos copies that contribute to the shop's free rerolls.
    -- Debuffed copies do not contribute (vanilla removes them from the deck).
    local function active_chaos_cards()
        local cards = {}

        for _, card in ipairs(chaos_cards()) do
            if not card.debuff then
                cards[#cards + 1] = card
            end
        end

        return cards
    end

    -- Free rerolls held by one copy.
    local function remaining_rerolls(card)
        local remaining = card.ability.yarm_chaos_rerolls

        if remaining == nil then
            remaining = get_chaos_rerolls()
        end

        return remaining
    end

    -- Total free rerolls held by active Chaos copies.
    local function chaos_total()
        local total = 0

        for _, card in ipairs(active_chaos_cards()) do
            total = total + remaining_rerolls(card)
        end

        return total
    end

    SMODS.Joker:take_ownership("chaos", {
        loc_vars = function(self, info_queue, card)
            local rerolls = get_chaos_rerolls()
            local remaining = card and card.ability
                and remaining_rerolls(card)
                or rerolls

            return {
                key = "j_yarm_chaos_the_clown",
                vars = {
                    rerolls,
                    rerolls == 1 and "" or "s",
                    localize({
                        type = "variable",
                        key = "k_yarm_chaos_remaining",
                        vars = {
                            remaining,
                            remaining == 1 and "" or "s",
                        },
                    }),
                },
            }
        end,

        -- Vanilla grants one reroll per copy. Each copy tracks its own
        -- remaining count, so the pool is adjusted to a net change of the
        -- copy's value. The adjustment runs after the base +1 to avoid the
        -- counter clamp when a copy is added with zero rerolls left.
        add_to_deck = function(self, card, from_debuff)
            local remaining = card.ability.yarm_chaos_rerolls

            if remaining == nil then
                remaining = get_chaos_rerolls()
                card.ability.yarm_chaos_rerolls = remaining
            end

            G.E_MANAGER:add_event(Event({
                trigger = "immediate",
                func = function()
                    SMODS.change_free_rerolls(remaining - 1)
                    return true
                end,
            }))
        end,

        -- Remove only this copy's remaining rerolls. The individual value is
        -- kept so a debuffed copy restores correctly when it returns.
        remove_from_deck = function(self, card, from_debuff)
            local remaining = remaining_rerolls(card)

            -- Applied synchronously before the base -1 so the positive
            -- compensation of a spent copy (remaining == 0) is not consumed
            -- by the counter clamp.
            SMODS.change_free_rerolls(-(remaining - 1))
        end,

        -- Each active copy announces its own upgrade when a Reroll voucher is
        -- redeemed. Buying Chaos itself never triggers this.
        calculate = function(self, card, context)
            if context.buying_card
                and not context.blueprint
                and context.card
                and context.card.config
                and context.card.config.center
            then
                local key = context.card.config.center.key

                if key == "v_reroll_surplus" or key == "v_reroll_glut" then
                    return { message = localize("k_upgrade_ex") }
                end
            end
        end,
    })

    -- Grant one extra reroll to every Chaos copy when Reroll Surplus or
    -- Reroll Glut is redeemed. Only active copies feed the global pool.
    local old_apply_to_run = Card.apply_to_run

    function Card:apply_to_run(center)
        local center_name = center and center.name
            or self and self.ability.name

        local result = old_apply_to_run(self, center)

        if center_name == "Reroll Surplus"
            or center_name == "Reroll Glut"
        then
            local active = 0

            for _, chaos in ipairs(chaos_cards()) do
                local remaining = remaining_rerolls(chaos)
                chaos.ability.yarm_chaos_rerolls = remaining + 1

                if not chaos.debuff then
                    active = active + 1
                end
            end

            if active > 0 then
                SMODS.change_free_rerolls(active)
            end
        end

        return result
    end

    -- Consume exactly one reroll from the earliest active Chaos copy when a
    -- free shop reroll is used. The base reroll event is queued first, so
    -- this event observes the already decremented counter.
    if G.FUNCS and G.FUNCS.reroll_shop then
        local old_reroll_shop = G.FUNCS.reroll_shop

        G.FUNCS.reroll_shop = function(e)
            local before = G.GAME.current_round.free_rerolls
            local result = old_reroll_shop(e)

            G.E_MANAGER:add_event(Event({
                trigger = "immediate",
                func = function()
                    if G.GAME.current_round.free_rerolls < before then
                        for _, chaos in ipairs(active_chaos_cards()) do
                            local remaining = remaining_rerolls(chaos)

                            if remaining > 0 then
                                chaos.ability.yarm_chaos_rerolls = remaining - 1
                                break
                            end
                        end
                    end

                    return true
                end,
            }))

            return result
        end
    end

    -- At the start of each round refresh every Chaos copy to full capacity
    -- while preserving free rerolls granted by other sources.
    local old_new_round = new_round

    function new_round(...)
        local external = math.max(
            (G.GAME.current_round.free_rerolls or 0) - chaos_total(),
            0
        )

        old_new_round(...)

        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                local capacity = get_chaos_rerolls()
                local total = 0

                for _, chaos in ipairs(chaos_cards()) do
                    chaos.ability.yarm_chaos_rerolls = capacity

                    if not chaos.debuff then
                        total = total + capacity
                    end
                end

                local desired = math.max(total + external, 0)
                G.GAME.current_round.free_rerolls = desired
                G.GAME.round_resets.free_rerolls = desired
                calculate_reroll_cost(true)

                return true
            end,
        }))
    end
end
