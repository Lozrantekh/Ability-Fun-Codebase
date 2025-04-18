modifier_ability_value_upgrades_sb_2023 = class({})

--------------------------------------------------------------------------------

function modifier_ability_value_upgrades_sb_2023:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_value_upgrades_sb_2023:IsPurgable()
	return false
end

function modifier_ability_value_upgrades_sb_2023:IsPermanent()
	return true
end

function modifier_ability_value_upgrades_sb_2023:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 1
end
--------------------------------------------------------------------------------

function modifier_ability_value_upgrades_sb_2023:OnCreated( kv )
	if IsServer() then
		--contains all upgrades picked by player (only values)
		self.playerPickedUpgradesValues = {}

		--used to return total values
		--should be exponed to client
		self.abilityPropertyValues = {}
	
		self.aghanimUpgradesFix = {
			omniknight_guardian_angel = {
				duration_scepter = {
					name = "duration",
				}
			},
			nevermore_necromastery = {
				necromastery_max_souls_scepter = {
					name = "necromastery_max_souls",
				}
			},
			riki_tricks_of_the_trade = {
				scepter_attacks = {
					name = "attack_count",
				}
			},
			abaddon_borrowed_time = {
				duration_scepter = {
					name = "duration",
				}
			},
			warlock_rain_of_chaos = {
				golem_dmg_scepter = {
					name = "golem_dmg"
				},
				
			}
		}

		self.copiedAbilities = {
			phoenix_launch_fire_spirit = "phoenix_fire_spirits",
			nevermore_shadowraze2 = "nevermore_shadowraze1",
			nevermore_shadowraze3 = "nevermore_shadowraze1",
			keeper_of_the_light_spirit_form_illuminate = "keeper_of_the_light_illuminate"
		}

		self.copiedAbilityValues = {
			tidehunter_anchor_smash = {
				AbilityCastRange = "radius"
			},

			windrunner_windrun = {
				AbilityDuration = "duration"
			},

			monkey_king_wukongs_command = {
				AbilityDuration = "duration"
			},

			keeper_of_the_light_illuminate = {
				AbilityChannelTime = "max_channel_time"
			},

			lion_mana_drain = {
				AbilityChannelTime = "duration"
			},

			--extra fields added to ability KV file 
			gyrocopter_flak_cannon = {
				fire_rate_tooltip = "fire_rate"
			}
		}

		-- copy bonus from special value to other
		-- for example item_apex copy bonus from primary_stat to primary_stat_universal
		self.copiedAbilityBonusValues = {
			item_apex = {
				primary_stat_universal = "primary_stat"
			}
		}

		--fix for icoming/outgoing damage that have no tooltips
		--currently ability tooltips always show positive values
		--for example antimage blink fragment outgoing dmg orignal: -25 (toooltip show 25) but upgrade +30 will make value 5 (and tooltip will show 5, instead of 105)
		self.fixDamageIncomingOutgoing = {
			antimage_mana_overload = {
				outgoing_damage = true
			}
		}

		self:UpdateAbilityUpgrades()
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_ability_value_upgrades_sb_2023:AddCustomTransmitterData()
    return {
        abilityPropertyValues = self.abilityPropertyValues,
		aghanimUpgradesFix = self.aghanimUpgradesFix,
		copiedAbilities = self.copiedAbilities,
		copiedAbilityValues = self.copiedAbilityValues,
		copiedAbilityBonusValues = self.copiedAbilityBonusValues,
		fixDamageIncomingOutgoing = self.fixDamageIncomingOutgoing,
    }
end

function modifier_ability_value_upgrades_sb_2023:HandleCustomTransmitterData( data )
    self.abilityPropertyValues = data.abilityPropertyValues
	self.aghanimUpgradesFix = data.aghanimUpgradesFix
	self.copiedAbilities = data.copiedAbilities
	self.copiedAbilityValues = data.copiedAbilityValues
	self.copiedAbilityBonusValues = data.copiedAbilityBonusValues
	self.fixDamageIncomingOutgoing = data.fixDamageIncomingOutgoing
end

function modifier_ability_value_upgrades_sb_2023:UpdateAbilityUpgrades()
	local playerID = self:GetParent():GetPlayerOwnerID() or -1

	if GameRules.AbilityDraftRanked and GameRules.AbilityDraftRanked.spellsUpgrade then
		self.playerPickedUpgradesValues = deepcopy(GameRules.AbilityDraftRanked.spellsUpgrade:GetPlayerPickedBaseAbilityUpgrades(playerID))
	end

	for abilityName, info in pairs(self.playerPickedUpgradesValues) do
		for propertyName, values in pairs(info) do
			if not self.abilityPropertyValues[abilityName] then
				self.abilityPropertyValues[abilityName] = {}
			end

			if not self.abilityPropertyValues[abilityName][propertyName] then
				self.abilityPropertyValues[abilityName][propertyName] = {}
			end

			--get ability property upgrade info
			if GameRules.AbilityDraftRanked and GameRules.AbilityDraftRanked.spellsUpgrade then
				self.abilityPropertyValues[abilityName][propertyName] = deepcopy(GameRules.AbilityDraftRanked.spellsUpgrade:GetAbilityPropertyUpgradesInfo(abilityName, propertyName))
			end

			--sum all chosen upgrades by player
			local sum = 0

			for _, value in pairs(values) do
				sum = sum + value
			end
			
			self.abilityPropertyValues[abilityName][propertyName]["total_sum"] = sum

			if self.abilityPropertyValues[abilityName][propertyName]["tooltip_dependency"] then
				local dependencyProperty = self.abilityPropertyValues[abilityName][propertyName]["tooltip_dependency"]

				self.abilityPropertyValues[abilityName][dependencyProperty] = deepcopy(self.abilityPropertyValues[abilityName][propertyName])
				self.abilityPropertyValues[abilityName][dependencyProperty]["tooltip_dependency"] = nil
			end
		end
	end

	self:SendBuffRefreshToClients()
end

function modifier_ability_value_upgrades_sb_2023:GetUpgradedValueForAbilityProperty(abilityName, propertyName)
	local ability = self:GetParent():FindAbilityByName(abilityName)
	if not ability then
		return 0
	end

	local originalValue = ability:GetLevelSpecialValueNoOverride(propertyName, ability:GetLevel() -1)
	return self:GetNewValueForAbilityProperty(abilityName, propertyName, originalValue, nil)
end

function modifier_ability_value_upgrades_sb_2023:GetTotalBonusForAbilityProperty(abilityName, propertyName)
	local ability = self:GetParent():FindAbilityByName(abilityName)
	if not ability then
		return 0
	end

	if self.abilityPropertyValues and self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][propertyName] and self.abilityPropertyValues[abilityName][propertyName]["total_sum"] then
		return self.abilityPropertyValues[abilityName][propertyName]["total_sum"]
	end

	return 0
end

--------------------------------------------------------------------------------

function modifier_ability_value_upgrades_sb_2023:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
	}
	return funcs
end

function modifier_ability_value_upgrades_sb_2023:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local specialValueName = params.ability_special_value
	local abilityName = params.ability:GetAbilityName()

	-- fix for abilities incoming/outgoing values (without tooltips)
	if IsClient() and self.fixDamageIncomingOutgoing and self.fixDamageIncomingOutgoing[abilityName] and
		self.fixDamageIncomingOutgoing[abilityName][specialValueName]
	then
		return 1
	end

	--normal upgrades
	if self.abilityPropertyValues and self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][specialValueName] then
		return 1
	end

	-- fixes for Aghanim Scepter that sometimes override upgrades (when there is a sepparate value for scepter)
	if self.aghanimUpgradesFix and self.aghanimUpgradesFix[abilityName] and self.aghanimUpgradesFix[abilityName][specialValueName] and 
		self.aghanimUpgradesFix[abilityName][specialValueName]["name"]

	then
		local baseSpecialValueName = self.aghanimUpgradesFix[abilityName][specialValueName]["name"]

		if baseSpecialValueName and self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName] and 
			self.abilityPropertyValues[abilityName][baseSpecialValueName]
		then
			return 1
		end
	end

	-- fixes for copied abilites (for example: Phoenix fire spirits)
	if self.copiedAbilities and self.copiedAbilities[abilityName] and self.abilityPropertyValues[self.copiedAbilities[abilityName]] and
		self.abilityPropertyValues[self.copiedAbilities[abilityName]][specialValueName]
	then
		return 1
	end
	
	-- fixes for copy ability values (for example tide anchor smash AbilityCastRange is taken from radius value)
	if self.copiedAbilityValues and self.copiedAbilityValues[abilityName] and self.copiedAbilityValues[abilityName][specialValueName] and
		self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][self.copiedAbilityValues[abilityName][specialValueName]]
	then
		return 1
	end

	-- copy bonus from special value to other
	-- for example item_apex copy bonus from primary_stat to primary_stat_universal
	if self.copiedAbilityBonusValues and self.copiedAbilityBonusValues[abilityName] and self.copiedAbilityBonusValues[abilityName][specialValueName] and
		self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][self.copiedAbilityBonusValues[abilityName][specialValueName]]
	then
		return 1
	end

	return 0
end

function modifier_ability_value_upgrades_sb_2023:GetModifierOverrideAbilitySpecialValue( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local specialValueName = params.ability_special_value
	local abilityName = params.ability:GetAbilityName()
	local nSpecialLevel = params.ability_special_level

	-- fix for abilities incoming/outgoing values (without tooltips)
	if IsClient() and self.fixDamageIncomingOutgoing and self.fixDamageIncomingOutgoing[abilityName] and 
		self.fixDamageIncomingOutgoing[abilityName][specialValueName]
	then
		local originalValue = params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)
		originalValue = math.abs(originalValue)

		return self:GetNewValueForAbilityProperty(abilityName, specialValueName, originalValue, nil)
	end

	--normal upgrades
	if self.abilityPropertyValues and self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName] and
		self.abilityPropertyValues[abilityName][specialValueName]
	then
		--force upgrade value - const value
		if self.abilityPropertyValues[abilityName][specialValueName]["force_value"] then
			return self.abilityPropertyValues[abilityName][specialValueName]["force_value"]
		end

		local originalValue = params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)
		
		return self:GetNewValueForAbilityProperty(abilityName, specialValueName, originalValue, nil)
	end

	-- fixes for Aghanim Scepter that sometimes override upgrades (when there is a sepparate value for scepter)
	if self.aghanimUpgradesFix and self.aghanimUpgradesFix[abilityName] and self.aghanimUpgradesFix[abilityName][specialValueName] and 
		self.aghanimUpgradesFix[abilityName][specialValueName]["name"]

	then
		local baseSpecialValueName = self.aghanimUpgradesFix[abilityName][specialValueName]["name"]

		if baseSpecialValueName and self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName] and 
			self.abilityPropertyValues[abilityName][baseSpecialValueName]
		then
			local originalValue = params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)
			
			return self:GetNewValueForAbilityProperty(abilityName, baseSpecialValueName, originalValue, nil)
		end
	end

	-- fixes for copied abilites (for example: Phoenix fire spirits)
	if self.copiedAbilities and self.copiedAbilities[abilityName] and self.abilityPropertyValues[self.copiedAbilities[abilityName]] and
		self.abilityPropertyValues[self.copiedAbilities[abilityName]][specialValueName]
	then

		local copiedAbility = self:GetParent():FindAbilityByName(self.copiedAbilities[abilityName])
		if copiedAbility then
			local originalValue = copiedAbility:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)

			return self:GetNewValueForAbilityProperty(self.copiedAbilities[abilityName], specialValueName, originalValue, nil)
		end
	end
	
	-- fixes for copy ability values (for example tide anchor smash AbilityCastRange is taken from radius value)
	if  self.copiedAbilityValues and self.copiedAbilityValues[abilityName] and self.copiedAbilityValues[abilityName][specialValueName] and
		self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][self.copiedAbilityValues[abilityName][specialValueName]]
	then

		local copyPropertyName = self.copiedAbilityValues[abilityName][specialValueName]
		local originalValue = params.ability:GetLevelSpecialValueNoOverride(copyPropertyName, nSpecialLevel)

		return self:GetNewValueForAbilityProperty(abilityName, copyPropertyName, originalValue, nil)
	end

	-- copy bonus from special value to other
	-- for example item_apex copy bonus from primary_stat to primary_stat_universal
	if self.copiedAbilityBonusValues and self.copiedAbilityBonusValues[abilityName] and self.copiedAbilityBonusValues[abilityName][specialValueName] and
		self.abilityPropertyValues[abilityName] and self.abilityPropertyValues[abilityName][self.copiedAbilityBonusValues[abilityName][specialValueName]]
	then
		local copyPropertyName = self.copiedAbilityBonusValues[abilityName][specialValueName]
		local originalValue = params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)

		local pctValue = nil

		if abilityName == "item_apex" and specialValueName == "primary_stat_universal" then
			pctValue = 0.3333333
		end

		return self:GetNewValueForAbilityProperty(abilityName, copyPropertyName, originalValue, pctValue)
	end

	return params.ability:GetLevelSpecialValueNoOverride(specialValueName, nSpecialLevel)
end

function modifier_ability_value_upgrades_sb_2023:GetNewValueForAbilityProperty(abilityName, specialValueName, originalValue, pctValue)
	local newValue = 0

	if not self.abilityPropertyValues[abilityName] or not self.abilityPropertyValues[abilityName][specialValueName] or 
		not self.abilityPropertyValues[abilityName][specialValueName]["total_sum"]
	then
		return originalValue
	end

	local isReduction = self.abilityPropertyValues[abilityName][specialValueName]["upgrade_reduction"] == 1 or
						self.abilityPropertyValues[abilityName][specialValueName]["upgrade_reduction"] == true

	local isNegativeCumulation = self.abilityPropertyValues[abilityName][specialValueName]["negative_cumulation"] == 1 or
								self.abilityPropertyValues[abilityName][specialValueName]["negative_cumulation"] == true

	local blockTalentOverLimit = self.abilityPropertyValues[abilityName][specialValueName]["block_talent_over_limit"] == 1 or 
								self.abilityPropertyValues[abilityName][specialValueName]["block_talent_over_limit"] == true

	local isShardUpgrade = self.abilityPropertyValues[abilityName][specialValueName]["is_shard_upgrade"] == 1 or 
								self.abilityPropertyValues[abilityName][specialValueName]["is_shard_upgrade"] == true

	local isScepterUpgrade = self.abilityPropertyValues[abilityName][specialValueName]["is_scepter_upgrade"] == 1 or 
								self.abilityPropertyValues[abilityName][specialValueName]["is_scepter_upgrade"] == true

	local minValue = self.abilityPropertyValues[abilityName][specialValueName]["min_value"]
	local maxValue = self.abilityPropertyValues[abilityName][specialValueName]["max_value"]

	if IsClient() and self.abilityPropertyValues[abilityName][specialValueName]["max_value_client"] then
		maxValue = self.abilityPropertyValues[abilityName][specialValueName]["max_value_client"]
	end

	-- Fix only for shards that values are 0 until hero get shard 
	-- on Panorama we use method to add custom panel with current Shard/Scepter upgrades (even if hero doesn't have shard).
	-- Function on Panorama takes current values from Custom Method written on Server and send to Client by Nettable.
	-- but to count total value (with upgrades) it need also all upgrades for this value, 
	-- On Client side and for these shards ignore that hero has no shard and return value (it will be 0 + sum of upgrades)
	-- on Server always return originalValue if hero doesn't have Shard (it should be then always 0)

	-- _HasHeroAghanimShard available only on server side
	if isShardUpgrade and not self:GetParent():HasModifier("modifier_item_aghanims_shard") then
		return originalValue
	end
	
	if isScepterUpgrade and not self:GetParent():HasScepter() then
		return originalValue
	end
	
	local upgrades = self.abilityPropertyValues[abilityName][specialValueName]["total_sum"]

	if pctValue and tonumber(pctValue) then
		upgrades = upgrades * pctValue
	end

	local limitValue = nil

	if isReduction or isNegativeCumulation then
		newValue = originalValue - upgrades
		
		if minValue and newValue < minValue then
			newValue = minValue
			limitValue = minValue
		end
	else
		newValue = originalValue + upgrades

		if maxValue and newValue > maxValue then
			newValue = maxValue
			limitValue = maxValue
		end
	end

	--fix for Furion Treants talent bonus
	if abilityName == "furion_force_of_nature" and (specialValueName == "treant_health" or specialValueName == "treant_damage_min" or 
		specialValueName == "treant_damage_max")
	then
		if self:HasOwnerLearnedTalent("special_bonus_unique_furion") then
			--fix me later (ugly): talent is 2.5x
			newValue = newValue + upgrades * 1.5
		end
	end

	--only for abilities with KV file using AbilityValues{}
	--for AbilityValues talent can be included in originalValue
	--when upgrades reach the max/min value we need to add talent value
	--otherwise ability value will not contain talent value (talent will be capped to the max/min value)
	--if new value didn't reach the limit it means talent was fully applied.
	if limitValue and not blockTalentOverLimit then
		local talentInfo = self:GetTalentUpgradeInfo(abilityName, specialValueName)

		if talentInfo and talentInfo.talent_name and talentInfo.talent_value then
			if type(talentInfo.talent_value) == "number" and talentInfo.talent_value ~= 0 then
				
				if self:HasOwnerLearnedTalent(talentInfo.talent_name) then
					if not talentInfo.talent_operator or talentInfo.talent_operator == "" then
						local baseValueWithoutUpgrades = originalValue - talentInfo.talent_value

						if isReduction or isNegativeCumulation then
							if baseValueWithoutUpgrades - upgrades <= limitValue then
								newValue = limitValue + talentInfo.talent_value									

							--when upgrades didn't reach the limit but talent is capped cause the limit
							else
								newValue = originalValue - upgrades
							end
						else
							if baseValueWithoutUpgrades + upgrades >= limitValue then
								newValue = limitValue + talentInfo.talent_value

							--when upgrades didn't reach the limit but talent is capped cause the limit
							else
								newValue = originalValue + upgrades
							end
						end
					elseif talentInfo.talent_operator == "x" and talentInfo.talent_value > 0 then
						local baseValueWithoutUpgrades = originalValue / talentInfo.talent_value

						if isReduction or isNegativeCumulation then
							if baseValueWithoutUpgrades - upgrades <= limitValue then
								newValue = limitValue * talentInfo.talent_value

							--when upgrades didn't reach the limit but talent is capped cause the limit
							else
								newValue = originalValue - upgrades
							end
						else
							if baseValueWithoutUpgrades + upgrades >= limitValue then
								newValue = limitValue * talentInfo.talent_value
							
								--when upgrades didn't reach the limit but talent is capped cause the limit
							else
								newValue = originalValue + upgrades
							end
						end
					end
				end
			end
		end
	end

	return newValue
end

function modifier_ability_value_upgrades_sb_2023:HasOwnerLearnedTalent(talentName)
	if self:GetParent():FindAbilityByName(talentName) and self:GetParent():FindAbilityByName(talentName):GetLevel() > 0 then
		return true
	end

	return false
end

--for abilities that use applying talents values via AbilityValues, for example slardar armor reduction:
-- "AbilityValues"
-- {
-- 	"armor_reduction"		
-- 	{ 
-- 		"value"				"-10 -15 -20"
-- 		"special_bonus_unique_slardar_5"	"-3"
-- 	}

--applying talents in this way causes that GetLevelSpecialValueNoOverride will return value after applying these values
--so if the upgrade have set some limit, for example: slardar max armor reduction -35
--then GetModifierOverrideAbilitySpecialValue will override this, so adding talent after reaching the limit will not change the final value (min -35).
--Some abilities using LinkedSpecialBonus properties in ability KV, will upgrade values only on the Client, but
--values on the Server are updated in ability LUA file.
function modifier_ability_value_upgrades_sb_2023:GetTalentUpgradeInfo(abilityName, propertyName)
	local result = {
		talent_name = "",
		talent_value = 0,
		talent_operator = ""
	}

	if not abilityName or not propertyName then
		return result
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return result
	end

	--ability values can be updated on server and client only using AbilityValues in KV file:
	local abilityValues = abilityKV["AbilityValues"]
	if not abilityValues then
		return result
	end

	if abilityValues then
		local propertyInfo = abilityValues[propertyName]
		if propertyInfo and type(propertyInfo) == "table" then
			for key, value in pairs(propertyInfo) do
				if key:find("special_bonus_") and value and type(value) == "string" then
					if tonumber(value) then
						result.talent_name = key
						result.talent_value = tonumber(value)

						return result
					end

					--% changes
					if string.sub(value, string.len(value) - 1, 1) == "%" then
						--increase by %
						local operator = string.sub( value, 1, 1)
						if operator then
							local talentOperator = nil
							
							if operator == "+" then
								talentOperator = "+"
							elseif operator == "-" then
								talentOperator = "-"
							end

							if talentOperator then
								local valueChangeStr = string.sub( value, 2, string.len(value) - 2)

								if valueChangeStr and tonumber(valueChangeStr) then
									local valueChange = nil

									if talentOperator == "+" then
										valueChange = 1 + tonumber(valueChangeStr)/100
									elseif talentOperator == "-"  then
										valueChange = 1 - tonumber(valueChangeStr)/100
									end

									if valueChange and valueChange > 0 then
										result.talent_name = key
										result.talent_value = valueChange
										result.talent_operator = "x"
		
										return result
									end
								end
							end
						end
					end
	
					for _, sign in pairs({"x"}) do
						if string.sub( value, 1, string.len( sign )) == sign then
							local stringNumber = string.gsub(value, sign, "")

							if stringNumber and tonumber(stringNumber) then
								result.talent_name = key
								result.talent_value = tonumber(stringNumber)
								result.talent_operator = "x"

								return result
							end
						end
					end
				end
			end
		end
	end
end