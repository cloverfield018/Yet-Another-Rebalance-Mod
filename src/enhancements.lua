-- Wild Card
local wild_immune_blinds = {
    bl_head = true,
    bl_window = true,
    bl_club = true,
    bl_goad = true
}

-- Preserve the original debuff logic for all other cases.
local debuff_card_ref = Blind.debuff_card

function Blind:debuff_card(card, from_blind)
    local blind_key = self.config and self.config.blind and self.config.blind.key

    if SMODS.has_enhancement(card, "m_wild")
        and wild_immune_blinds[blind_key] then
        card:set_debuff(false)
        return
    end

    debuff_card_ref(self, card, from_blind)
end