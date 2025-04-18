modifier_golden_treasure_chest_ad_2023 = class({})

--------------------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:OnCreated( kv )
	if IsServer() then	
		self.lastSequence = "chest_treasure_idle"
		self.heroesChanneling = {}

		self:GetParent():SetMaterialGroup("1")

		self.nextIntervalTime = 0
		self:StartIntervalThink(0.5)
	end
end

function modifier_golden_treasure_chest_ad_2023:OnIntervalThink()
	if IsServer() then
		if self.treasureRemove then
			self:RemoveTreasure()
			self:StartIntervalThink(-1)
			return
		end

		if self.bWasOpened then
			self.treasureRemove = true
			self:StartIntervalThink(1.5)
			return
		end

		if self:GetParent().itemEntityOrdered and not self:GetParent().itemEntityOrdered:IsNull() then
			local container = self:GetParent().itemEntityOrdered

			if self:IsAnyoneChannelingTreasure() then
				local heroesCount = self:GetTotalChannelingHeroes()

				if self.lastSequence == "chest_treasure_idle" then
					self.lastSequence = "chest_treasure_spawn"
					container:SetSequence("chest_treasure_spawn")

					self.nextIntervalTime = GameRules:GetGameTime() + 0.5
					self:StartIntervalThink(0.5)
				else
					self.lastSequence = "chest_treasure_idle"
					container:SetSequence("chest_treasure_idle")

					if heroesCount > 0 then
						local newInterval = math.max(2/heroesCount, 0.2)
						self.nextIntervalTime = GameRules:GetGameTime() + newInterval

						self:StartIntervalThink(newInterval)
					end
				end
			else
				self.lastSequence = "chest_treasure_idle"
				container:SetSequence("chest_treasure_idle")

				self.nextIntervalTime = GameRules:GetGameTime() + 0.5

				self:StartIntervalThink(0.5)
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
	}
	return funcs
end

-----------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:OnAbilityFullyCast(params)
	if IsServer() then
		if self.bWasOpened then
			return
		end

		local hOrderedUnit = params.unit 
		local hTargetUnit = params.target
		local ability = params.ability

		if not hOrderedUnit or not hTargetUnit or hTargetUnit ~= self:GetParent() then
			return
		end

		if not ability or ability:GetAbilityName() ~= "ability_open_golden_treasure" then
			return
		end
		
		local currentChannelingHeroes = self:GetTotalChannelingHeroes()

		if currentChannelingHeroes > 0 and self:GetParent().itemEntityOrdered and not self:GetParent().itemEntityOrdered:IsNull() then
			local container = self:GetParent().itemEntityOrdered
			
			if container:GetSequence() ~= "chest_treasure_spawn" then
				container:SetSequence("chest_treasure_spawn")
				self.lastSequence = "chest_treasure_spawn"
			end
		end

		local teamNumber = hOrderedUnit:GetTeamNumber()

		if teamNumber then
			if not self.heroesChanneling[teamNumber] then
				self.heroesChanneling[teamNumber] = {}
			end

			self.heroesChanneling[teamNumber][hOrderedUnit:entindex()] = hOrderedUnit

			--update interval only if there are other channeling heores and new interval is shorter than next interval time
			if currentChannelingHeroes > 0 then
				local newInterval = math.max(2/(currentChannelingHeroes + 1), 0.2)

				local timeToNextInterval = self.nextIntervalTime - GameRules:GetGameTime()

				if newInterval < timeToNextInterval then
					self:StartIntervalThink(newInterval)
				end
			end

			local teamChannelTime = self:GetTeamRestChannelTime(teamNumber, hOrderedUnit)
			
			if currentChannelingHeroes > 0 and teamChannelTime and teamChannelTime >= 0 then
				--seems like execute ability event happen before OnSpellStart (weird?)
				-- print("wysylam do update total channel time dla: ", hOrderedUnit:GetUnitName())
				-- ability.keepPreviousValues = true
				ability:UpdateInitialChannelTime(teamChannelTime)
			end

			for _, units in pairs(self.heroesChanneling) do
				for _, unit in pairs(units) do
					local treasureOpenAbility = unit:FindAbilityByName("ability_open_golden_treasure")
					if treasureOpenAbility then
						-- print("wysylam do update channel booster dla: ", unit:GetUnitName())
						-- treasureOpenAbility.keepPreviousValues = true
						
						local channelingRate = self:GetTreasureChannelingRate(teamNumber)

						if channelingRate then
							treasureOpenAbility:UpdateChannelRateValue(channelingRate)
						end
					end
				end
			end
		end
	end
end

function modifier_golden_treasure_chest_ad_2023:GetTreasureChannelingRate(teamNumber)
	local channelingHeroes = self:GetChannelingHeroesCount(teamNumber)

	if channelingHeroes and channelingHeroes >= 1 then
		return (channelingHeroes - 1) * -0.1
	end

	return 0
end

function modifier_golden_treasure_chest_ad_2023:OnAbilityEndChannel(params)
	if IsServer() then
		if self.bWasOpened then
			return
		end

		local hOrderedUnit = params.unit 
		local ability = params.ability

		if not ability or ability:GetAbilityName() ~= "ability_open_golden_treasure" then
			return
		end

		local target = ability:GetCursorTarget()

		if target and target ~= self:GetParent() then
			return
		end

		local needUpdateHeroesChanneling = false

		for teamNumber, units in pairs(self.heroesChanneling) do
			for entindex, unit in pairs(units) do
				if unit == hOrderedUnit then
					needUpdateHeroesChanneling = true
					self.heroesChanneling[teamNumber][entindex] = nil
					break
				end
			end
		end

		if needUpdateHeroesChanneling then
			for teamNumber, units in pairs(self.heroesChanneling) do
				for _, unit in pairs(units) do
					local treasureOpenAbility = unit:FindAbilityByName("ability_open_golden_treasure")

					if treasureOpenAbility then
						local channelingRate = self:GetTreasureChannelingRate(teamNumber)

						if channelingRate then
							treasureOpenAbility:UpdateChannelRateValue(channelingRate)
						end
					end
				end
			end
		end
	end
end

function modifier_golden_treasure_chest_ad_2023:GetChannelingHeroesCount(teamNumber)
	local counter = 0

	if not self.heroesChanneling[teamNumber] then
		return 0
	end

	for _, _ in pairs(self.heroesChanneling[teamNumber]) do
		counter = counter + 1
	end

	return counter
end

function modifier_golden_treasure_chest_ad_2023:IsAnyoneChannelingTreasure()
	for teamNumber, _ in pairs(self.heroesChanneling) do
		for _, unit in pairs(self.heroesChanneling[teamNumber]) do
			if unit and not unit:IsNull() and unit:IsAlive() then
				local treasureOpenAbility = unit:FindAbilityByName("ability_open_golden_treasure")
				if treasureOpenAbility and treasureOpenAbility:IsChanneling() then
					return true
				end
			end
		end	
	end

	return false
end

function modifier_golden_treasure_chest_ad_2023:GetTotalChannelingHeroes()
	local counter = 0

	for teamNumber, _ in pairs(self.heroesChanneling) do
		for _, unit in pairs(self.heroesChanneling[teamNumber]) do
			if unit and not unit:IsNull() and unit:IsAlive() then
				local treasureOpenAbility = unit:FindAbilityByName("ability_open_golden_treasure")
				if treasureOpenAbility and treasureOpenAbility:IsChanneling() then
					counter = counter + 1
				end
			end
		end	
	end

	return counter
end

function modifier_golden_treasure_chest_ad_2023:GetTeamRestChannelTime(teamNumber, unit)
	if not self.heroesChanneling[teamNumber] then
		return nil
	end

	for _, channelingUnit in pairs(self.heroesChanneling[teamNumber]) do
		if channelingUnit and not channelingUnit:IsNull() and channelingUnit:IsAlive() and channelingUnit ~= unit then
			local treasureOpenAbility = channelingUnit:FindAbilityByName("ability_open_golden_treasure")
			if treasureOpenAbility and treasureOpenAbility:IsChanneling() then
				local channelTime = treasureOpenAbility:GetChannelTime()
				local startChannelTime = treasureOpenAbility:GetChannelStartTime()

				if channelTime and startChannelTime then
					local teamChannelTime = channelTime - (GameRules:GetGameTime() - startChannelTime)

					--add extra +0.25 to let open the treasure for the first hero who started chanelling it
					return teamChannelTime + 0.25
				end
			end
		end
	end

	return nil
end

-----------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:GetModifierIncomingDamage_Percentage( params )
	return -100
end

-----------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:RandomTreasureReward(caster)
	if self.bWasOpened then
		return
	end

	self.bWasOpened = true
	self:GetParent().treasureOpened = true

	if self:GetParent().itemEntityOrdered and not self:GetParent().itemEntityOrdered:IsNull() then
		local container = self:GetParent().itemEntityOrdered
		container:SetSequence("chest_treasure_open")

		container.treasureOpened = true
	end

	local goldenUpgradesCount = 0
	local rerollUpgradesCount = 0
	local skipUpgradesCount  = 0
	local goldenTreasuresCount = 0

	local tooltipText = "Your Team Has Got: "
	local duration = 2

	local droppedByTower = false
	local towerLevel = 1

	if self:GetParent() then
		if self:GetParent().droppedByTower then
			droppedByTower = true
		end

		if self:GetParent().towerLevel and tonumber(self:GetParent().towerLevel) and self:GetParent().towerLevel > 1 then
			towerLevel = self:GetParent().towerLevel
		end
	end

	--choose hero to make pseudo randoms on him
	local rollHero = nil
	local team = -1

	if caster then
		team = caster:GetTeamNumber()
	end

	local firstPlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, 1)
	local hero = PlayerResource:GetSelectedHeroEntity(firstPlayerID)

	if hero then
		rollHero = hero
	end

	if droppedByTower then
		goldenUpgradesCount = 1
		rerollUpgradesCount = 1
		skipUpgradesCount = 1
		goldenTreasuresCount = 1

		if towerLevel >= 3 then
			goldenTreasuresCount = 2
		end
		
		if rollHero then
			if RollPseudoRandomPercentage(10, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, rollHero) then
				goldenUpgradesCount = 3
			elseif RollPseudoRandomPercentage(30, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, rollHero) then
				goldenUpgradesCount = 2
			end
		else
			if RollPercentage(10) then
				goldenUpgradesCount = 3
			elseif RollPercentage(30) then
				goldenUpgradesCount = 2
			end
		end

	--Jungle Creeps:
	else
		goldenTreasuresCount = 1
		goldenUpgradesCount = 1

		if RollPercentage(50) then
			goldenUpgradesCount = 0
			rerollUpgradesCount = 1
		end
	end

	local addedInfo = false

	if goldenUpgradesCount > 0 then
		tooltipText = tooltipText .. "<span class='TooltipSpecialCounter'>+" .. goldenUpgradesCount .. "</span> Golden Upgrades"

		duration = duration + 1
		addedInfo = true
	end

	if rerollUpgradesCount > 0 then
		if addedInfo then
			tooltipText = tooltipText .. " | "
		end

		tooltipText = tooltipText .. "<span class='TooltipSpecialCounter'>+" .. rerollUpgradesCount .. "</span> Reroll"

		duration = duration + 1
		addedInfo = true
	end

	if skipUpgradesCount > 0 then
		if addedInfo then
			tooltipText = tooltipText .. " | "
		end

		tooltipText = tooltipText .. "<span class='TooltipSpecialCounter'>+" .. skipUpgradesCount .. "</span> Skip Upgrade"
		duration = duration + 1
	end

	if goldenTreasuresCount > 0 then
		if addedInfo then
			tooltipText = tooltipText .. " | "
		end

		tooltipText = tooltipText .. "<span class='TooltipSpecialCounter'>+" .. goldenTreasuresCount .. "</span> <font color='orange'>Golden Treasures</font>"
		duration = duration + 1
	end

	if caster then
		local teamNumber = caster:GetTeamNumber()

		GameRules.AbilityDraftRanked:SendChatCombatMessageTeam("#DOTA_Ability_Draft_Golden_Treasue_Open", teamNumber, true, caster:GetPlayerOwnerID())

		local playerStats = {}

		if GameRules.AbilityDraftRanked._vPlayerStats then
			playerStats = GameRules.AbilityDraftRanked._vPlayerStats
		end

		for playerID, data in pairs(playerStats) do
			if data["ability_golden_upgrades"] and data["ability_golden_upgrades_balance"] then
				local teamHero = PlayerResource:GetSelectedHeroEntity(playerID)

				if teamHero and teamHero:GetTeamNumber() == teamNumber then
					data["ability_golden_upgrades"] = data["ability_golden_upgrades"] + goldenUpgradesCount
					data["ability_golden_upgrades_balance"] = data["ability_golden_upgrades_balance"] + goldenUpgradesCount
					data["reroll_ability_upgrades"] = data["reroll_ability_upgrades"] + rerollUpgradesCount
					data["skip_ability_upgrades"] = data["skip_ability_upgrades"] + skipUpgradesCount

					--update data on client
					CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), GameRules.AbilityDraftRanked._vPlayerStats[ playerID ])

					EmitSoundOnClient("Treasure.Show.Rewards", PlayerResource:GetPlayer(playerID))
				end
			end
		end

		local extraInfo = {
			ability_name = "ability_open_golden_treasure",
			text = tooltipText,
			duration = 4,
			golden_style = true,
		}
		
		CustomGameEventManager:Send_ServerToTeam(teamNumber, "player_extra_info", extraInfo)

		--golden treasure:
		if goldenTreasuresCount > 0 and GameRules.AbilityDraftRanked.spellsUpgrade then
			local maxPlayers = GameRules.AbilityDraftRanked.maxPlayers or 20

			for nPlayerID = 0, maxPlayers -1 do
				if PlayerResource:IsValidPlayerID( nPlayerID ) and PlayerResource:GetTeam(nPlayerID) == caster:GetTeamNumber() then
					local teamHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

					if teamHero then
						local reservedChestID = DoUniqueString("chest_player_" .. nPlayerID)
						local canShowSpecialUpgrade = false

						if teamHero:GetLevel() >= 20 then
							canShowSpecialUpgrade = true
						end

						GameRules.AbilityDraftRanked.spellsUpgrade:CreatePlayerRandomSpellUpgrades(teamHero, canShowSpecialUpgrade, false, 0, false, goldenTreasuresCount, false, reservedChestID)
					end
				end
			end
		end
	end
	
	local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/dust_impact_small_no_flek.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( particle )

	self:GetParent():EmitSound("Treasure.Box.Unlock")

	local playerID = caster:GetPlayerOwnerID()

	if playerID and GameRules.AbilityDraftRanked._vPlayerStats[playerID] then
		if not GameRules.AbilityDraftRanked._vPlayerStats[playerID]["upgrade_treasures_opened"] then
			GameRules.AbilityDraftRanked._vPlayerStats[playerID]["upgrade_treasures_opened"] = 0
		end

		GameRules.AbilityDraftRanked._vPlayerStats[playerID]["upgrade_treasures_opened"] = GameRules.AbilityDraftRanked._vPlayerStats[playerID]["upgrade_treasures_opened"] + 1
		CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), GameRules.AbilityDraftRanked._vPlayerStats[playerID] )
	end
end

function modifier_golden_treasure_chest_ad_2023:RemoveTreasure()
	for teamNumber, units in pairs(self.heroesChanneling) do
		for index, unit in pairs(units) do
			local treasureOpenAbility = unit:FindAbilityByName("ability_open_golden_treasure")
			if treasureOpenAbility and treasureOpenAbility:IsChanneling() and 
				treasureOpenAbility:GetCursorTarget() and treasureOpenAbility:GetCursorTarget() == self:GetParent() then
				unit:InterruptChannel()
			end

			self.heroesChanneling[teamNumber][index] = unit
		end
	end

	if self:GetParent().itemEntityOrdered and not self:GetParent().itemEntityOrdered:IsNull() then
		local container = self:GetParent().itemEntityOrdered
		local containItem = container:GetContainedItem()

		local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_ABSORIGIN, container )
		ParticleManager:SetParticleControl( nFXIndex, 0, container:GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		if containItem then
			containItem:RemoveSelf()
		end

		if container.fxParticleIndex then
			ParticleManager:DestroyParticle(container.fxParticleIndex, true)
		end

		UTIL_Remove(container)
	end

	self:GetParent():ForceKill(false)
end

--------------------------------------------------------------------------------

function modifier_golden_treasure_chest_ad_2023:CheckState()
	local state = {}
	if IsServer()  then
		state[MODIFIER_STATE_FROZEN] = not self.bWasOpened
		state[MODIFIER_STATE_ROOTED] = true
		state[MODIFIER_STATE_NO_HEALTH_BAR] = true
		state[MODIFIER_STATE_BLIND] = true
		state[MODIFIER_STATE_NOT_ON_MINIMAP] = true
		state[MODIFIER_STATE_DISARMED] = true
		
		state[MODIFIER_STATE_ATTACK_IMMUNE] = true
		state[MODIFIER_STATE_INVULNERABLE] = true
		state[MODIFIER_STATE_NO_UNIT_COLLISION] = true

		if self.bWasOpened then
			state[MODIFIER_STATE_UNSELECTABLE] = true
			state[MODIFIER_STATE_OUT_OF_GAME] = true
		end
	end
	
	return state
end
--------------------------------------------------------------------------------