modifier_shadow_fiend_shadowraze_ad_2023 = class({})

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad_2023:IsHidden()
	return false
end

function modifier_shadow_fiend_shadowraze_ad_2023:IsDebuff()
	return true
end

function modifier_shadow_fiend_shadowraze_ad_2023:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad_2023:OnCreated( kv )
	self:SetStackCount(1)
end

function modifier_shadow_fiend_shadowraze_ad_2023:OnRefresh( kv )
end

function modifier_shadow_fiend_shadowraze_ad_2023:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_shadow_fiend_shadowraze_ad_2023:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() and self:GetStackCount() >= 1 then
		return self:GetAbility():GetSpecialValueFor("movement_speed_pct") * (self:GetStackCount() - 1)
	end

	return 0
end

function modifier_shadow_fiend_shadowraze_ad_2023:OnTooltip()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("stack_bonus_damage") * self:GetStackCount()
	end
end

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_ad_2023:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_shadow_fiend_shadowraze_ad_2023:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------