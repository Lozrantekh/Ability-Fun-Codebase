modifier_ability_open_golden_treasure = class({})

function modifier_ability_open_golden_treasure:IsHidden()
	return true
end

function modifier_ability_open_golden_treasure:IsPurgable()
	return false
end

function modifier_ability_open_golden_treasure:OnCreated(kv)
	if IsServer() then
	end
end

function modifier_ability_open_golden_treasure:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
	}
	return funcs
end

function modifier_ability_open_golden_treasure:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local specialValueName = params.ability_special_value
	local abilityName = params.ability:GetAbilityName()
	
	if self:GetAbility() and abilityName == self:GetAbility():GetAbilityName() and specialValueName == "AbilityChannelTime" and self:GetStackCount() > 0 then
		return 1
	end

	return 0
end

function modifier_ability_open_golden_treasure:GetModifierOverrideAbilitySpecialValue( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local specialValueName = params.ability_special_value
	local abilityName = params.ability:GetAbilityName()
	local nSpecialLevel = params.ability_special_level

	if self:GetAbility() and abilityName == self:GetAbility():GetAbilityName() and specialValueName == "AbilityChannelTime" and self:GetStackCount() > 0 then
		return self:GetStackCount() / 100
	end

	return params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)
end