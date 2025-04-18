modifier_enchantress_impetus_no_mana = class({})

function modifier_enchantress_impetus_no_mana:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE 
    }
end

function modifier_enchantress_impetus_no_mana:GetModifierPercentageManacost()
    return 100
end
