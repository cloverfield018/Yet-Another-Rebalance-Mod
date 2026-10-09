-- Register Jimbo's config toggle.
YARM_CONFIG_TOGGLES = YARM_CONFIG_TOGGLES or {}

table.insert(YARM_CONFIG_TOGGLES, {
    label = "Jimbo",
    ref_table = YARM_CONFIG.jokers.jimbo,
    ref_value = "rebalance",
})


-- Wraps the vanilla defeat function to track defeated Boss Blinds.
-- Track defeated Boss Blinds so Jimbo's Mult can scale throughout the run.
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
            extra = 4,
            increase = 2
        },

        loc_vars = function(self, info_queue, card)
            local boss_blinds =
                G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

            local extra = card.ability.extra or self.config.extra
            local increase = card.ability.increase or self.config.increase

            local current_mult =
                extra + (boss_blinds * increase)

            return {
                key = "j_yarm_jimbo",
                vars = {
                    extra,
                    increase,
                    current_mult
                }
            }
        end,

        calculate = function(self, card, context)
            if context.joker_main then
                local boss_blinds =
                    G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

                local extra = card.ability.extra or self.config.extra
                local increase = card.ability.increase or self.config.increase

                local current_mult =
                    extra + (boss_blinds * increase)

                return {
                    mult = current_mult
                }
            end
        end
    })
end