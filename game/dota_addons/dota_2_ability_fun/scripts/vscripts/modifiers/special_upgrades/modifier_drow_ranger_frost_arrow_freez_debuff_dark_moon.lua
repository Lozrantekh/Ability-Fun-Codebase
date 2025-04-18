modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:IsDebuff()
	return true
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:IsStunDebuff()
	return true
end

-- function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:GetTexture()
-- 	return "drow_ranger_frost_arrows"
-- end
--------------------------------------------------------------------------------
-- Initializations
function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:OnCreated( kv )
	self.particle = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"

	self.sound_target = "Crystal.Frostbite"
	EmitSoundOn( self.sound_target, self:GetParent() )
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:OnRemoved()
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:CheckState()
	local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:GetEffectName()
	return self.particle
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon:OnTooltip()
    return self:GetDuration()
end