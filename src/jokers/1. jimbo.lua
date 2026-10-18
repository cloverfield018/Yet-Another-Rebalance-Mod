-- Register Jimbo's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Jimbo",
    ref_table = YARM_CONFIG.jokers.jimbo,
    ref_value = "rebalance",
})


-- Track defeated Boss Blinds throughout the run.
local blind_defeat_ref = Blind.defeat

function Blind:defeat(silent)
    if self.boss and G.GAME then
        G.GAME.yarm_boss_blinds_defeated =
            (G.GAME.yarm_boss_blinds_defeated or 0) + 1
    end

    blind_defeat_ref(self, silent)
end


-- Jimbo
if YARM_CONFIG.jokers.jimbo.rebalance then
    SMODS.Joker:take_ownership("joker", {
        name = "Jimbo",

        config = {
            extra = {
                base_mult = 4,
                mult_increase = 2,
            }
        },

        loc_vars = function(self, info_queue, card)
            local boss_blinds_defeated =
                G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

            local base_mult =
                card.ability.extra.base_mult
                or self.config.extra.base_mult

            local mult_increase =
                card.ability.extra.mult_increase
                or self.config.extra.mult_increase

            local total_mult =
                base_mult
                + (boss_blinds_defeated * mult_increase)

            return {
                key = "j_yarm_jimbo",
                vars = {
                    base_mult,
                    mult_increase,
                    total_mult,
                }
            }
        end,

        calculate = function(self, card, context)
            if context.end_of_round
                and context.game_over == false
                and context.main_eval
                and context.beat_boss
                and not context.blueprint
            then
                return {
                    message = localize('k_upgrade_ex'),
                }
            end

            if context.joker_main then
                local boss_blinds_defeated =
                    G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

                local base_mult =
                    card.ability.extra.base_mult
                    or self.config.extra.base_mult

                local mult_increase =
                    card.ability.extra.mult_increase
                    or self.config.extra.mult_increase

                local total_mult =
                    base_mult
                    + (boss_blinds_defeated * mult_increase)

                return {
                    mult = total_mult
                }
            end
        end
    })
end