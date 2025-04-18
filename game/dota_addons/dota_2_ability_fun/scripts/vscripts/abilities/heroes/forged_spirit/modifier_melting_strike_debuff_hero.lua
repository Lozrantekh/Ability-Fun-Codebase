---@class modifier_melting_strike_debuff_lua:CDOTA_Modifier_Lua
modifier_melting_strike_debuff_hero = class({})

function modifier_melting_strike_debuff_hero:OnCreated()
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_removed")
	self.max_armor_reduction = self:GetAbility():GetSpecialValueFor("max_armor_removed")

	if IsClient() then return end

	self:SetStackCount(1)
end

function modifier_melting_strike_debuff_hero:OnRefresh()
	if IsClient() then return end

	if self:GetStackCount() < self.max_armor_reduction then
		self:IncrementStackCount()
	end
end

function modifier_melting_strike_debuff_hero:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_melting_strike_debuff_hero:GetModifierPhysicalArmorBonus()
	return -self.armor_reduction * self:GetStackCount()
end
