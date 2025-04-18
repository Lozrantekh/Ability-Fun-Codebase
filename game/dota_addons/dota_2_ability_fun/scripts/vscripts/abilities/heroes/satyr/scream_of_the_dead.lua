-------------------------------------------
-- Battle Hunger
-------------------------------------------

-- Visible Modifiers:
LinkLuaModifier("modifier_scream_of_the_dead_debuff_deny", "abilities/heroes/satyr/modifier_scream_of_the_dead_debuff_dot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scream_of_the_dead_debuff_dot", "abilities/heroes/satyr/modifier_scream_of_the_dead_debuff_dot.lua", LUA_MODIFIER_MOTION_NONE)

scream_of_the_dead = scream_of_the_dead or class({})

--Do the battle hunger animation
function scream_of_the_dead:GetCastAnimation()
	return(ACT_DOTA_OVERRIDE_ABILITY_2)
end

function scream_of_the_dead:OnSpellStart()
	local caster                    =       self:GetCaster()
	local target                    =       self:GetCursorTarget()
	local ability                   =       self

	caster:EmitSound("Hero_Axe.Battle_Hunger")

	if caster ~= target then
		-- If the target possesses a ready Linken's Sphere, do nothing
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			if target:TriggerSpellAbsorb(ability) then
				return nil
			end
		end
	
	local target_modifier = "modifier_scream_of_the_dead_debuff_dot"
	local duration = self:GetSpecialValueFor("duration")


	target:AddNewModifier(caster, self, target_modifier, {duration = duration})
		-- Self-cast with the talent (the cast permission is checked in CastFilterResultTarget)
	end
end
