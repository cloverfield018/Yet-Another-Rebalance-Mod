-- Register Chaos the Clown's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Chaos the Clown",
    ref_table = YARM_CONFIG.jokers.chaos_the_clown,
    ref_value = "rebalance",
})

-- Chaos the Clown
if YARM_CONFIG.jokers.chaos_the_clown.rebalance then
    local function get_chaos_rerolls()
        if G.GAME.used_vouchers.v_reroll_glut then
            return 3
        elseif G.GAME.used_vouchers.v_reroll_surplus then
            return 2
        end

        return 1
    end

    local function get_chaos_count()
        return #find_joker("Chaos the Clown")
    end

    SMODS.Joker:take_ownership("chaos", {
        loc_vars = function(self, info_queue, card)
            local rerolls = get_chaos_rerolls()

            return {
                key = "j_yarm_chaos_the_clown",
                vars = {
                    rerolls,
                    rerolls == 1 and "" or "s",
                }
            }
        end,

        -- Vanilla already grants one reroll.
        -- Add only the extra rerolls from vouchers.
        add_to_deck = function(self, card, from_debuff)
            local extra = get_chaos_rerolls() - 1

            if extra > 0 then
                SMODS.change_free_rerolls(extra)
            end
        end,

        -- Vanilla removes the base reroll.
        -- Remove only the extra rerolls from vouchers.
        remove_from_deck = function(self, card, from_debuff)
            local extra = get_chaos_rerolls() - 1

            if extra > 0 then
                SMODS.change_free_rerolls(-extra)
            end
        end,
    })

    -- Grant one additional reroll per Chaos when either
    -- Reroll Surplus or Reroll Glut is redeemed.
    local old_apply_to_run = Card.apply_to_run

    function Card:apply_to_run(center)
        local center_name = center and center.name
            or self and self.ability.name

        local result = old_apply_to_run(self, center)

        if center_name == "Reroll Surplus"
            or center_name == "Reroll Glut" then
            local chaos_count = get_chaos_count()

            if chaos_count > 0 then
                SMODS.change_free_rerolls(chaos_count)
            end
        end

        return result
    end

    -- Recalculate Chaos rerolls when a new round begins.
    local old_new_round = new_round

    function new_round(...)
        old_new_round(...)

        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                local total = get_chaos_count() * get_chaos_rerolls()

                G.GAME.current_round.free_rerolls = total
                calculate_reroll_cost(true)

                return true
            end
        }))
    end
end