-- Wraps the vanilla defeat function to track defeated Boss Blinds.
local blind_defeat_ref = Blind.defeat

function Blind:defeat(silent)
    if self.boss and G.GAME then
        G.GAME.yarm_boss_blinds_defeated =
            (G.GAME.yarm_boss_blinds_defeated or 0) + 1
    end

    blind_defeat_ref(self, silent)
end


-- Jimbo
SMODS.Joker:take_ownership("joker", {
    name = "Jimbo",

    config = {
        extra = 4,
        increase = 2
    },

    loc_vars = function(self, info_queue, card)
        local boss_blinds =
            G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

        local current_mult =
            card.ability.extra + (boss_blinds * card.ability.increase)

        return {
            key = "j_yarm_jimbo",
            vars = {
                card.ability.extra,
                card.ability.increase,
                current_mult
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local boss_blinds =
                G.GAME and G.GAME.yarm_boss_blinds_defeated or 0

            local current_mult =
                card.ability.extra + (boss_blinds * card.ability.increase)

            return {
                mult = current_mult
            }
        end
    end
})