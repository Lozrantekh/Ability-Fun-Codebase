modifier_player_ability_checker = class({})

--------------------------------------------------------------------------------

function modifier_player_ability_checker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_player_ability_checker:IsPurgable()
	return false
end

function modifier_player_ability_checker:IsPermanent()
	return true
end

--------------------------------------------------------------------------------

function modifier_player_ability_checker:OnCreated( kv )
	if IsServer() then
		self.abilitiesToCheck = {}
		self.isIntervalThinkWorking = false

		self.abilityToVerifyState = {}

		local abilitiesToVerifyState = SPECIAL_SWAP_ABILITIES_INFO["verify_state"]
		if abilitiesToVerifyState then
			for abilityName, info in pairs(abilitiesToVerifyState) do
				local modifierToVerify = info["modifier"] or ""
				local swapAbilityName = info["swap_ability"] or ""

				if swapAbilityName and swapAbilityName ~= "" and modifierToVerify and modifierToVerify ~= "" then
					self.abilityToVerifyState[abilityName] = {
						modifier = modifierToVerify,
						swap_ability = swapAbilityName,
					}
				end
			end
		end
	end
end
--------------------------------------------------------------------------------

function modifier_player_ability_checker:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
		MODIFIER_EVENT_ON_STATE_CHANGED,
	}
	return funcs
end

function modifier_player_ability_checker:OnStateChanged(params)
	if IsServer() then
		if self:GetParent() == params.unit and self.abilityToVerifyState then
			for abilityName, info in pairs(self.abilityToVerifyState) do
				if self:GetParent():HasAbility(abilityName) then
					local modifierToVerify = info["modifier"] or ""
					local swapAbilityName = info["swap_ability"] or ""
	
					if modifierToVerify and modifierToVerify ~= "" and swapAbilityName and swapAbilityName ~= "" then
						local hasModifier = self:GetParent():HasModifier(modifierToVerify)
	
						local swapAbility = self:GetParent():FindAbilityByName(swapAbilityName)
						local ability = self:GetParent():FindAbilityByName(abilityName)
	
						if not hasModifier and swapAbility and not ability:IsHidden() then
							self:GetParent():SwapAbilities(abilityName, swapAbilityName, false, true)
						end
					end
				end
			end

			if self:GetParent().monkeyTreeModel and not self:GetParent().monkeyTreeModel:IsNull() and 
				not self:GetParent():HasModifier("modifier_monkey_king_transform") 
			then
				UTIL_Remove(self:GetParent().monkeyTreeModel)
				self:GetParent().monkeyTreeModel = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
function modifier_player_ability_checker:OnAbilityEndChannel(params)
	if IsServer() then
		if self:GetParent() == params.unit then
			local usedAbilityName = params.ability:GetAbilityName() or ""

			if not usedAbilityName or usedAbilityName == "" then
				return
			end

			local swapAbilities = SPECIAL_SWAP_ABILITIES_INFO["after_channel"]
			if swapAbilities and swapAbilities[usedAbilityName] then
				local swapAbilityName = swapAbilities[usedAbilityName]["swap_ability"]

				if swapAbilityName and swapAbilityName ~= "" then
					local swapAbility = self:GetParent():FindAbilityByName(swapAbilityName)

					--swap ability immediately after use to this ability
					if swapAbility then
						self:GetParent():SwapAbilities(usedAbilityName, swapAbilityName, false, true)
					end
				end
			end
		end
	end
end

function modifier_player_ability_checker:OnAbilityExecuted(params)
	if IsServer() then
		if self:GetParent() == params.unit then
			if not params.ability or params.ability:IsItem() or not self.abilitiesToCheck then
				return
			end
			
			local usedAbilityName = params.ability:GetAbilityName() or ""

			if not usedAbilityName or usedAbilityName == "" then
				return
			end

			self:ApplyAbilityExecutedModifications(usedAbilityName)

			local swapAbilities = SPECIAL_SWAP_ABILITIES_INFO["after_use"]
			if swapAbilities and swapAbilities[usedAbilityName] then
				local swapAbilityName = swapAbilities[usedAbilityName]["swap_ability"]
				local onlyBackSwap = swapAbilities[usedAbilityName]["only_back_swap"] or false
				local verifyMainAbility = swapAbilities[usedAbilityName]["verify_main_ability"] or false

				if swapAbilityName and swapAbilityName ~= "" then
					local needShard = swapAbilities[usedAbilityName]["shard"]

					if needShard and not self:GetParent():_HasHeroAghanimShard() then
						return
					end

					local swapAbility = self:GetParent():FindAbilityByName(swapAbilityName)

					--swap ability immediately after use to this ability
					if swapAbility then
						if not onlyBackSwap then
							self:GetParent():SwapAbilities(usedAbilityName, swapAbilityName, false, true)

							if self:GetParent():IsStrongIllusion() then
								swapAbility:SetActivated(true)
							end
						end

						--check if ability has inactive status that requires back to main ability
						local backAfterInactive = swapAbilities[usedAbilityName]["back_after_inactive"]
						if backAfterInactive then

							local min_check_time = swapAbilities[usedAbilityName]["min_check_time"] or 0

							local checkTime = GameRules:GetGameTime() + min_check_time

							if not verifyMainAbility then
								table.insert(self.abilitiesToCheck, {
									check = "after_inactive",
									back_ability = usedAbilityName,
									swap_ability = swapAbilityName,
									check_time = checkTime,
								})
							else
								table.insert(self.abilitiesToCheck, {
									check = "after_inactive",
									back_ability = swapAbilityName,
									swap_ability = usedAbilityName,
									check_time = checkTime,
									verify_main_ability = true,
								})
							end

							if not self.isIntervalThinkWorking then
								self.isIntervalThinkWorking = true
								self:StartIntervalThink(0.1)
							end
						end
					end
				end
			end
		end
	end
end

function modifier_player_ability_checker:ApplyAbilityExecutedModifications(abilityName)
	if IsServer() then
		if abilityName == "meepo_petrify" and self:GetParent():GetUnitName() ~= "npc_dota_hero_meepo" then
			local ability = self:GetParent():FindAbilityByName("meepo_petrify")
			if ability then
				local duration = ability:GetSpecialValueFor("duration")
				local modifier = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_z_delta_visual", {duration = duration})

				local fxIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_burrow.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl( fxIndex, 0, self:GetParent():GetAbsOrigin() )

				if modifier then
					modifier.particleFX = fxIndex
				end
			end
		end

		if (abilityName == "monkey_king_mischief" or abilityName == "monkey_king_untransform") and self:GetParent().monkeyTreeModel and not self:GetParent().monkeyTreeModel:IsNull() then
			UTIL_Remove(self:GetParent().monkeyTreeModel)
			self:GetParent().monkeyTreeModel = nil
		end

		if abilityName == "dawnbreaker_fire_wreath" then
			local hAbility = self:GetParent():FindAbilityByName("dawnbreaker_fire_wreath")
			if hAbility then
				local duration = hAbility:GetSpecialValueFor("duration")
				if duration then
					self:GetParent():AddNewModifier(self:GetParent(), hAbility, "modifier_dawnbreaker_starbreaker_effect_only", {duration = duration})
				end
			end
		end

		if self:GetParent():IsStrongIllusion() then
			if abilityName == "hoodwink_sharpshooter" then
				self:GetParent():SwapAbilities("hoodwink_sharpshooter", "hoodwink_sharpshooter_release", false, true)
			elseif abilityName == "hoodwink_sharpshooter_release"  then
				self:GetParent():SwapAbilities("hoodwink_sharpshooter", "hoodwink_sharpshooter_release", true, false)
			end
		end
	end
end

function modifier_player_ability_checker:OnIntervalThink()
	if IsServer() then
		if not self.abilitiesToCheck then
			return
		end

		--interval will clear only one processed ability in every iteration and make break to don't mess index in loop
		for index, abilityToCheck in ipairs(self.abilitiesToCheck) do
			if abilityToCheck["processed"] then
				table.remove(self.abilitiesToCheck, index)
				break
			end
		end

		if #self.abilitiesToCheck == 0 then
			self:StartIntervalThink(0.5)
			return
		end

		for _, abilityToCheck in ipairs(self.abilitiesToCheck) do
			if not abilityToCheck["processed"] then
				local abilityProcessed = true
	
				local swapAbilityName = abilityToCheck["swap_ability"] or ""
				local backAbilityName = abilityToCheck["back_ability"] or ""
				local onlyBackSwap = abilityToCheck["verify_main_ability"] or false
		
				if abilityToCheck["check"] and abilityToCheck["check"] == "after_inactive" then
					local swapAbility = self:GetParent():FindAbilityByName(swapAbilityName)
					local backAbility = self:GetParent():FindAbilityByName(backAbilityName)
		
					if swapAbility and backAbility and (backAbility:IsHidden() or onlyBackSwap) then
						if not swapAbility:IsActivated() and not swapAbility:IsHidden() and GameRules:GetGameTime() >= abilityToCheck["check_time"] then
							self:GetParent():SwapAbilities(swapAbilityName, backAbilityName, false, true)
						else
							abilityProcessed = false
						end
					end

					if swapAbility and swapAbility:IsHidden() and backAbility and not backAbility:IsHidden() then
						abilityProcessed = true
					end
				end
		
				if abilityProcessed then
					abilityToCheck["processed"] = true
				end
			end
		end

		self:StartIntervalThink(0.1)
	end
end