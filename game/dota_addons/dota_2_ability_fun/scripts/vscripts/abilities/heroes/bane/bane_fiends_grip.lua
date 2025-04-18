---@class bane_fiends_grip_lua:CDOTA_Ability_Lua
bane_fiends_grip_lua = class({})

LinkLuaModifier("modifier_bane_fiends_grip_lua", "abilities/heroes/bane/modifier_bane_fiends_grip", LUA_MODIFIER_MOTION_NONE)

function bane_fiends_grip_lua:GetCastRange(location, target)
	if self:GetCaster():IsIllusion() then return 9999 end
end

function bane_fiends_grip_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then
		caster:InterruptChannel()
		return
	end

	--local multicast_modifier = caster:FindModifierByName("modifier_multicast_lua")
	local multicast = 1
	
	if caster:IsIllusion() then
		multicast = caster.multicast or 1
	--elseif multicast_modifier then
	--	multicast = multicast_modifier:GetMulticastFactor(self)
	--	multicast_modifier:PlayMulticastFX(multicast)
	end

	target:AddNewModifierSR(caster, self, "modifier_bane_fiends_grip_lua", {duration = self:GetChannelTime(), multicast = multicast})

	if caster:IsIllusion() then
		caster:AddNewModifier(caster, nil, "modifier_bane_fiends_grip_illusion_can_only_channel", nil)
	end

	if caster:IsRealHero() and caster:HasScepter() then
		local illusion_count = self:GetSpecialValueFor("illusion_count")

		local mod_params = {
			incoming_damage = self:GetSpecialValueFor("scepter_incoming_illusion_damage"),
			duration = 20
		}

		local origin = caster:GetAbsOrigin()

		local illusions = CreateIllusions(caster, caster, mod_params, illusion_count, caster:GetHullRadius(), false, false)
		local direction = origin + (target:GetAbsOrigin() - origin):Normalized() * 400

		local offset = {-90, 90}

		for n, unit in pairs(illusions) do
			if IsValidEntity(unit) and unit:IsAlive() then
				local position = RotatePosition(origin, QAngle(0, offset[n], 0), direction)
				FindClearSpaceForUnit(unit, position, true)

				unit.multicast = multicast

				unit:AddNewModifier(unit, self, "modifier_bane_fiends_grip_illusion", { duration = 20 })
				
				local illusion_ability = unit:AddAbility("bane_fiends_grip_lua")
				illusion_ability:SetLevel(self:GetLevel())
				illusion_ability:SetOverrideCastPoint(0)

				local i = 0
				Timers:CreateTimer(0.03, function()
					i = i + 1

					if not IsValidEntity(unit) or unit:IsChanneling() then return end
					if i >= 10 then unit:ForceKill(false) return end
				
					unit:CastAbilityOnTarget(target, illusion_ability, -1)

					return 0.03
				end)

				Timers:CreateTimer(20, function()
					if IsValidEntity(unit) then unit:RemoveSelf() end
				end)
			end
		end
	end
end

