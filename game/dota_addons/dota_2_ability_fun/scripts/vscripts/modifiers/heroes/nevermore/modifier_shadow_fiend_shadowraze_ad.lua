modifier_shadow_fiend_shadowraze_ad = class({})

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad:IsHidden()
	return false
end

function modifier_shadow_fiend_shadowraze_ad:IsDebuff()
	return true
end

function modifier_shadow_fiend_shadowraze_ad:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad:OnCreated( kv )
	self:SetStackCount(1)
end

function modifier_shadow_fiend_shadowraze_ad:OnRefresh( kv )
end

function modifier_shadow_fiend_shadowraze_ad:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_shadow_fiend_shadowraze_ad:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() and self:GetStackCount() >= 1 then
		return self:GetAbility():GetSpecialValueFor("movement_speed_pct") * (self:GetStackCount() - 1)
	end

	return 0
end

function modifier_shadow_fiend_shadowraze_ad:OnTooltip()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("stack_bonus_damage") * self:GetStackCount()
	end
end

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_shadow_fiend_shadowraze_ad:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------