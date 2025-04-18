---@class modifier_melting_strike_lua:CDOTA_Modifier_Lua
modifier_melting_strike_hero = class({})

function modifier_melting_strike_hero:IsHidden() return true end
function modifier_melting_strike_hero:IsPurgable() return false end
function modifier_melting_strike_hero:IsPermanent() return true end

function modifier_melting_strike_hero:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_melting_strike_hero:OnCreated()
	if not IsServer() then return end

	local ability = self:GetAbility()
	if not ability or ability:IsNull() then return end
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_melting_strike_hero:GetModifierProcAttack_Feedback(keys)
	if not IsServer() then return end

	local ability = self:GetAbility()
	if (not keys.attacker) or (not keys.target) or (not ability) or keys.attacker:IsNull() or keys.target:IsNull() or ability:IsNull() then return end

	-- Does not work on friendly targets, buildings, dead or magic immune units
	if keys.attacker:GetTeam() == keys.target:GetTeam() or keys.target:IsBuilding() or (not keys.target:IsAlive()) or keys.target:IsMagicImmune() then return end

	-- Apply the debuff
	keys.target:AddNewModifier(keys.attacker, ability, "modifier_melting_strike_debuff_hero", {duration = self.duration})
end
