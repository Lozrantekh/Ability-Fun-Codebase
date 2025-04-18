modifier_bristleback_quilled_metamorph_dark_moon = class({})

function modifier_bristleback_quilled_metamorph_dark_moon:IsPurgable()
	return false
end

function modifier_bristleback_quilled_metamorph_dark_moon:IsPurgeException()
	return false
end
--------------------------------------------------------------------------------

function modifier_bristleback_quilled_metamorph_dark_moon:IsStunDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_bristleback_quilled_metamorph_dark_moon:IsHidden()
	return true
end

function modifier_bristleback_quilled_metamorph_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }
end

--------------------------------------------------------------------------------

function modifier_bristleback_quilled_metamorph_dark_moon:CheckState()
	local state = {
    [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_bristleback_quilled_metamorph_dark_moon:GetModifierModelChange()
	return "models/spikes4.vmdl"
end

function modifier_bristleback_quilled_metamorph_dark_moon:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_bristleback_quilled_metamorph_dark_moon:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_bristleback_quilled_metamorph_dark_moon:GetAbsoluteNoDamagePure()
	return 1
end