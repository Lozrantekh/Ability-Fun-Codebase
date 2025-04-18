modifier_fix_death_units_crash_modifiers = class({})

--------------------------------------------------------------

function modifier_fix_death_units_crash_modifiers:IsHidden()
	return true
end

--------------------------------------------------------------

function modifier_fix_death_units_crash_modifiers:IsPurgable()
	return false
end

function modifier_fix_death_units_crash_modifiers:IsPurgeException()
	return false
end

--------------------------------------------------------------

function modifier_fix_death_units_crash_modifiers:OnCreated()
	if IsServer() then
		self.modifierThinkersExceptions = {
			modifier_boss_gold_bag_fountain_bonus_thinker = true
		}
	end
end

function modifier_fix_death_units_crash_modifiers:OnDestroy()
	if IsServer() then
		self:GetParent().deathTime = GameRules:GetGameTime()

		--destroy created thinkers
		local thinkers = Entities:FindAllByClassname( "npc_dota_thinker")
		for _, thinker in pairs(thinkers) do
			if thinker and not thinker:IsNull() and thinker:GetOwner() and thinker:GetOwner() == self:GetParent() then

				local canDestroyThinker = true

				for modifierName, _ in pairs(self.modifierThinkersExceptions) do
					if thinker:HasModifier(modifierName) then
						canDestroyThinker = false
						break
					end
				end

				if canDestroyThinker then
					UTIL_Remove(thinker)
				end
			end
		end

		--reduce modifier duration on affected units
		--modifiers that will be applied after death (for example by projectiles) are handled in filter (ModifierGainedFilter)
		if self:GetParent().affectedUnits then
			for _, unit in pairs(self:GetParent().affectedUnits) do
				if unit and not unit:IsNull() and unit:IsAlive() then
					for _, modifier in pairs(unit:FindAllModifiers()) do
						if modifier and modifier:GetCaster() and modifier:GetCaster() == self:GetParent() then
							local modifierTime = modifier:GetRemainingTime()

							if modifierTime > 2.5 then
								modifier:SetDuration(2.5, true)
							end
						end
					end
				end
			end
		end
	end
end