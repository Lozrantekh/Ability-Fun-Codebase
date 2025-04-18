-- units: { [string]: EntityIndex }
-- entindex_target: EntityIndex
-- entindex_ability: EntityIndex
-- issuer_player_id_const: PlayerID
-- sequence_number_const: uint
-- queue: 0 | 1
-- order_type: dotaunitorder_t
-- position_x: float
-- position_y: float
-- position_z: float
-- shop_item_name: string

function CAbilityDraftRanked:ExecuteOrderFilter( filterTable )
    -- DeepPrintTable(filterTable)
	local orderType = filterTable["order_type"]
    local units = filterTable["units"]
	local target = EntIndexToHScript(filterTable["entindex_target"])
	local playerID = filterTable["issuer_player_id_const"]

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local realOrderUnit = hero

    if self:GetRealPlayerHeroOrderedUnit(filterTable) then
        realOrderUnit = self:GetRealPlayerHeroOrderedUnit(filterTable)
    end

    --player orders
	if (playerID and playerID >= 0 ) and orderType then
        if realOrderUnit then
            realOrderUnit.queueCastTargetUnit = nil
            realOrderUnit.queueCastTargetAbility = nil
            realOrderUnit.attackTarget = nil
            realOrderUnit.queueCastWardPosition = nil
            realOrderUnit.queueCastWardItem = nil

            if realOrderUnit.AfterShockDeactivated then
                local afterShockAbility = realOrderUnit:FindAbilityByName("earthshaker_aftershock")
                if afterShockAbility then
                    afterShockAbility:RefreshIntrinsicModifier()
                    realOrderUnit.AfterShockDeactivated = false
                end
            end
        end

        --golden treasure fix
        if realOrderUnit and (not realOrderUnit:IsIllusion() or realOrderUnit:IsStrongIllusion()) and orderType == DOTA_UNIT_ORDER_PICKUP_ITEM and target then
            local item = target:GetContainedItem()
            local openTreasureAbility = realOrderUnit:FindAbilityByName("ability_open_golden_treasure")

            if item and item:GetAbilityName() == "item_golden_treasure_upgrades" and target.hiddenTreasure and 
                not target.treasureOpened and openTreasureAbility and openTreasureAbility:GetLevel() > 0
            then
                local queueCastTreasure = false

                if realOrderUnit:HasModifier("modifier_mounted") then
                    local distance = (realOrderUnit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()

                    if distance > 200 then
                        queueCastTreasure = true
                    end
                end

                if queueCastTreasure then
                    local direction = (realOrderUnit:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
                    local position = target:GetAbsOrigin() + direction * 150
                    filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
                    filterTable["position_x"] = position.x
                    filterTable["position_y"] = position.y
                    filterTable["position_z"] = position.z

                    realOrderUnit.queueCastTargetUnit = target.hiddenTreasure
                    realOrderUnit.queueCastTargetAbility = openTreasureAbility
                    realOrderUnit.queueCastTargetDistance = 200
                else
                    filterTable["order_type"] = DOTA_UNIT_ORDER_CAST_TARGET 
                    filterTable["entindex_target"] = target.hiddenTreasure:entindex()
                    filterTable["entindex_ability"] = openTreasureAbility:entindex()

                    local afterShockAbility = realOrderUnit:FindAbilityByName("earthshaker_aftershock")
                    if afterShockAbility then
                        local esModifier = realOrderUnit:FindModifierByName("modifier_earthshaker_aftershock")
                        if esModifier then
                            realOrderUnit.AfterShockDeactivated = true
                            esModifier:Destroy()
                        end
                    end
                end

                return true
            end
        end

        if orderType == DOTA_UNIT_ORDER_ATTACK_TARGET and target and realOrderUnit and realOrderUnit:HasModifier("modifier_mounted") then
            realOrderUnit.attackTarget = target
        end

        if orderType == DOTA_UNIT_ORDER_CAST_TARGET and realOrderUnit and target then
            if target:IsBaseNPC() and target:GetUnitName() == "npc_treasure_chest" then
                local afterShockAbility = realOrderUnit:FindAbilityByName("earthshaker_aftershock")
                if afterShockAbility then
                    local esModifier = realOrderUnit:FindModifierByName("modifier_earthshaker_aftershock")
                    if esModifier then
                        realOrderUnit.AfterShockDeactivated = true
                        esModifier:Destroy()
                    end
                end
            end

            if realOrderUnit:HasModifier("modifier_mounted") then
                if target:IsBaseNPC() or target:IsBuilding() then
                    local specialBuildingsDistance = {
                        npc_dota_mango_tree = 400,
                        npc_dota_unit_twin_gate = 150,
                        npc_dota_lantern = 75,
                    }
    
                    if specialBuildingsDistance[target:GetUnitName()] or target:GetClassname() == "npc_dota_watch_tower" then
                        local distance = (realOrderUnit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    
                        local orderDistance = specialBuildingsDistance[target:GetUnitName()] or 200
    
                        if distance > orderDistance then
                            local direction = (realOrderUnit:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
                            local position = target:GetAbsOrigin() + direction * orderDistance
                            filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
                            filterTable["position_x"] = position.x
                            filterTable["position_y"] = position.y
                            filterTable["position_z"] = position.z
    
                            realOrderUnit.queueCastTargetUnit = target
                            realOrderUnit.queueCastTargetAbility = EntIndexToHScript(filterTable["entindex_ability"])
                            realOrderUnit.queueCastTargetDistance = orderDistance + 50
            
                            return true 
                        end
                    end
                end
            end
        end

        if orderType == DOTA_UNIT_ORDER_CAST_POSITION and realOrderUnit then
            if realOrderUnit:HasModifier("modifier_mounted") then
                local abilityIndex = filterTable["entindex_ability"]
                local ability = EntIndexToHScript(abilityIndex)

                local allowedAbilityCast = {
                    item_ward_observer = true,
                    item_ward_sentry = true,
                    item_ward_dispenser = true,
                }

                if ability and allowedAbilityCast[ability:GetAbilityName()] then
                    local posX = filterTable["position_x"]
                    local posY = filterTable["position_y"]
                    local posZ = filterTable["position_z"]

                    local pos = Vector(posX, posY, posZ)
                    
                    local range = ability:GetCastRange(pos, nil)
                    local distance = (realOrderUnit:GetAbsOrigin() - pos):Length2D()

                    if distance <= range then
                        realOrderUnit:SetCursorPosition(pos)
                        ability:OnSpellStart()
                    else
                        local mount = realOrderUnit:_GetPlayerMount_SB2023()

                        if mount then
                            realOrderUnit.queueCastWardPosition = pos
                            realOrderUnit.queueCastWardItem = ability:GetAbilityName()
                            realOrderUnit.queueCastPositionDistance = range

                            mount:MoveToPosition(pos)
                        end
                    end

                    return false
                end
            end
        end

        if orderType == DOTA_UNIT_ORDER_CAST_TOGGLE and realOrderUnit then
            if realOrderUnit:HasModifier("modifier_mounted") then
                local abilityIndex = filterTable["entindex_ability"]
                local ability = EntIndexToHScript(abilityIndex)
                
                if ability and ability:GetAbilityName() == "item_ward_dispenser" then
                    ability:ToggleAbility()

                    return false
                end
            end
        end

        if orderType == DOTA_UNIT_ORDER_CAST_NO_TARGET and realOrderUnit then
            if realOrderUnit:HasModifier("modifier_mounted") then
                local abilityIndex = filterTable["entindex_ability"]
                local ability = EntIndexToHScript(abilityIndex)
                
                if ability and ability:GetAbilityName() == "item_smoke_of_deceit" then
                    ability:OnSpellStart()

                    return false
                end
            end
        end

        --autocast + swapping items
        if orderType == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
            return self:HandleAutoCastOrder(filterTable)
        end

        if orderType and self.playerLoseItemOrders[orderType] then
            return self:HandleMoveItemOrders(filterTable)
        end

        --heroes cast spells
		if realOrderUnit and orderType and self.unitSpellOrders[orderType]  then
			return self:HandleHeroesCastSpells(filterTable, playerID, realOrderUnit)
		end
	end

    return true
end

function CAbilityDraftRanked:HandleHeroesCastSpells(filterTable, playerID, hero)

	return true
end

function CAbilityDraftRanked:GetRealPlayerHeroOrderedUnit(filterTable)
	--this is associative array with string keys, starting from 0, so first unit is under key:"0"	
	local units = filterTable["units"]

	if not units or not units["0"] then
		return nil
	end

	local unitIndex = units["0"]

	local unit = EntIndexToHScript(unitIndex)

	if unit and not unit:IsNull() and unit:GetPlayerOwnerID() > -1 then
		return unit
	end

	return nil
end

function CAbilityDraftRanked:HandleMoveItemOrders(filterTable)
    -- print("order: ", orderType)
    local units = filterTable["units"]
    if not units or type(units) ~= "table" or not units["0"] or not filterTable["entindex_ability"] then
        return true
    end

    local itemIndex = filterTable["entindex_ability"]
    local item = EntIndexToHScript(itemIndex)

    if not item or item:IsNull() or item:GetAbilityName() ~= "item_ultimate_scepter" then
        return true
    end

    local scepterModifiers = {
        modifier_item_ultimate_scepter_consumed = true,
        modifier_item_ultimate_scepter_consumed_alchemist = true,
    }

    local hero = EntIndexToHScript(units["0"])

    if hero and not hero:IsNull() and hero:IsRealHero() then
        local abilityCount = hero:GetAbilityCount()

        for i = 0, abilityCount - 1 , 1 do
            local testedAbility = hero:GetAbilityByIndex(i)
            if testedAbility and not testedAbility:IsAttributeBonus() then
                
                if testedAbility.swappedScepterAbility and not testedAbility:IsHidden() then
                    local hasHeroConsumedScepter = false

                    for scepterModifierName, _ in pairs(scepterModifiers) do
                        if hero:HasModifier(scepterModifierName) then
                            hasHeroConsumedScepter = true
                        end
                    end

                    if not hasHeroConsumedScepter then
                        hero:SwapAbilities(testedAbility:GetAbilityName(), testedAbility.swappedScepterAbility, false, true)
                        testedAbility.swappedScepterAbility = nil
                    end
                end

                if not testedAbility:IsHidden() and testedAbility.scepterManuallyHide then
                    testedAbility:SetHidden(true)
                end
            end
        end
    end

  return true
end

function CAbilityDraftRanked:HandleAutoCastOrder(filterTable)
    local units = filterTable["units"]
    if not units or type(units) ~= "table" or not units["0"] or not filterTable["entindex_ability"] then
        return true
    end
    
    local abilityIndex = filterTable["entindex_ability"]
    local ability = EntIndexToHScript(abilityIndex)
    
    if not ability or ability:IsNull() then
        return true
    end

    local abilityName = ability:GetAbilityName()
    local subAbilityName = self:GetSwapAbilityName(abilityName)

    if not subAbilityName or subAbilityName == "" then
        return true
    end

    local hero = EntIndexToHScript(units["0"])
        
    if hero and not hero:IsNull() then
        local subAbility = hero:FindAbilityByName(subAbilityName)

        if subAbility and subAbility:IsHidden() then
            if hero:IsStrongIllusion() then

                if string.find(abilityName, "_no_scepter_info") then
                    local fixedAbilityName = abilityName:gsub("_no_scepter_info","")
                    subAbilityName = self:GetSwapAbilityName(fixedAbilityName)
                    
                elseif self:IsAbilityGrantedByScepter(subAbilityName) then
                    subAbilityName = subAbilityName .. "_no_scepter_info"
                end
            end
    
            if subAbilityName and subAbilityName ~= "" then
                local isGrantedByScepter = self:IsAbilityGrantedByScepter(subAbilityName)
                local isGrantedByShard = self:IsAbilityGrantedByShard(subAbilityName)
    
                if isGrantedByScepter and not hero:HasScepter() then
                    return false
                end
    
                if isGrantedByShard and not hero:_HasHeroAghanimShard() then
                    return false
                end
    
                if SPECIAL_SWAP_ABILITIES_INFO["block_swap"] and SPECIAL_SWAP_ABILITIES_INFO["block_swap"][abilityName] then
                    local modifierName = SPECIAL_SWAP_ABILITIES_INFO["block_swap"][abilityName]["no_modifier"]
    
                    --swap blocked
                    if modifierName and not hero:HasModifier(modifierName) then
                        return false
                    end
                end
    
                if ABILITIES_ACTIVATE_AUTOCAST[abilityName] then
    
                    if ABILITIES_ACTIVATE_AUTOCAST[abilityName]["auto_cast_toggle"] then
                        local activateAbility = hero:FindAbilityByName(ABILITIES_ACTIVATE_AUTOCAST[abilityName]["auto_cast_toggle"])
                        if activateAbility then
                            activateAbility:ToggleAutoCast()
                        end 
                    end
    
                    if ABILITIES_ACTIVATE_AUTOCAST[abilityName]["cast"] then
                        local activateAbility = hero:FindAbilityByName(ABILITIES_ACTIVATE_AUTOCAST[abilityName]["cast"])
                        if activateAbility then
                            activateAbility:CastAbility()
                        end
                    end
    
                    return true
                end
        
                hero:SwapAbilities(abilityName, subAbilityName, false, true)
    
                if isGrantedByScepter or isGrantedByShard then
                    subAbility:SetLevel(subAbility:GetMaxLevel())
                    subAbility.swappedScepterAbility = abilityName

                    if hero:IsStrongIllusion() then
                        subAbility:SetActivated(true)
                    end

                elseif subAbility.baseAbilityLevelling then
                    subAbility:SetLevel(ability:GetLevel())
                end

                self:SpecialModificationForSwappedAbility(hero, subAbility, ability)
                
                return false
            end 
        end
    end

    return true
end

function CAbilityDraftRanked:SpecialModificationForSwappedAbility(hero, subAbility, ability)
    local abilityName = ability:GetAbilityName() or ""
    local subAbilityName = subAbility:GetAbilityName() or ""

    if ability:GetToggleState() and not subAbility:GetToggleState() and SUB_ABILITIES_MODIFICATIONS["toggle"] and SUB_ABILITIES_MODIFICATIONS["toggle"][subAbilityName] then
        local canToggle = true

        if not SUB_ABILITIES_MODIFICATIONS["toggle"][abilityName]["on_stun"] then
            if hero:IsStunned() then
                canToggle = false

                if SUB_ABILITIES_MODIFICATIONS["toggle"][abilityName]["shard_exception"] then
                    if hero:_HasHeroAghanimShard() then
                        canToggle = true
                    end
                end
            end
        end

        if canToggle then
            subAbility:ToggleAbility()
        end
    end
end

function CAbilityDraftRanked:IsAbilityGrantedByScepter(abilityName)
    local abilityKV = GetAbilityKeyValuesByName(abilityName)

	if abilityKV and abilityKV["IsGrantedByScepter"] and abilityKV["IsGrantedByScepter"] == "1" then
		return true
	end

    for _, scepterAbility in pairs(SCEPTER_NEW_ABILITIES) do
        if scepterAbility == abilityName then
            return true
        end
    end

	return false
end

function CAbilityDraftRanked:IsAbilityGrantedByShard(abilityName)
    local abilityKV = GetAbilityKeyValuesByName(abilityName)

	if abilityKV and abilityKV["IsGrantedByShard"] and abilityKV["IsGrantedByShard"] == "1" then
		return true
	end

    for _, shardAbility in pairs(SHARD_NEW_ABILITIES) do
        if shardAbility == abilityName then
            return true
        end
    end

	return false
end

---------------------------------------------------------------------------
--	ModifierGainedFilter
--  *entindex_parent_const
--	*entindex_ability_const
--	*entindex_caster_const
--	*name_const
--	*duration
---------------------------------------------------------------------------

function CAbilityDraftRanked:ModifierGainedFilter( filterTable )
	if filterTable["entindex_parent_const"] == nil then 
		return true
	end
    
    if filterTable["name_const"] == nil then
		return true
	end

    
	local szBuffName = filterTable["name_const"]
	local hParent = EntIndexToHScript( filterTable["entindex_parent_const"] )

    --fix Sand King Aghanim's Shard
    if hParent and szBuffName == "modifier_item_aghanims_shard" then
        local epicenter = hParent:FindAbilityByName("sandking_epicenter")

        if epicenter and not hParent:HasModifier("modifier_sand_king_shard") then
            hParent:AddNewModifier(hParent, epicenter, "modifier_sand_king_shard", {})
        end
    end

    --Fix Monkey King Mischief
    if szBuffName == "modifier_monkey_king_transform" and hParent and hParent:GetUnitName() ~= "npc_dota_hero_monkey_king" then
        Timers:CreateTimer(0.1, function ()
            if hParent:GetModelName() == "models/heroes/monkey_king/transform_invisiblebox.vmdl" then
                local hWearable = Entities:CreateByClassname( "wearable_item" )
                if hWearable then
                    local randomTreeModelData = self:GetRandomMonkeyKingTreeModel(hParent)

                    if randomTreeModelData["model"] and randomTreeModelData["scale"] then
                        hWearable:SetModel(randomTreeModelData["model"])
                        hWearable:SetModelScale(randomTreeModelData["scale"])
                        hWearable:SetTeam(hParent:GetTeamNumber())
                        hWearable:SetOwner(hParent)
                        hWearable:SetAbsOrigin(hParent:GetAbsOrigin())
                        hWearable:SetParent(hParent,nil)

                        if randomTreeModelData["color"] and #randomTreeModelData["color"] >= 3 then
                            local color = randomTreeModelData["color"]
                            hWearable:SetRenderColor(color[1], color[2], color[3])
                            hWearable:SetSkin(2)

                        end
        
                        hParent.monkeyTreeModel = hWearable
                    end
                end
            end
        end)
    end

    local scepterModifiers = {
        modifier_item_ultimate_scepter = true,
        modifier_item_ultimate_scepter_consumed = true,
        modifier_item_ultimate_scepter_consumed_alchemist= true,
    }

    --SCEPTER/SHARD hide abilities
    if hParent and (szBuffName == "modifier_item_aghanims_shard" or scepterModifiers[szBuffName]) then
        local abilitiesToHide = {}
        local hideScepterAbilities = false
        local anyAbilityToHide = false
    
        --illusion scepter/shard abilities are handled in function to adjust illusion abilities
        if not hParent:IsIllusion() then
            if (szBuffName == "modifier_item_aghanims_shard") then
                abilitiesToHide = SHARD_NEW_ABILITIES_HIDDEN
                anyAbilityToHide = true
            elseif scepterModifiers[szBuffName] then
                abilitiesToHide = SCEPTER_NEW_ABILITIES_HIDDEN
                hideScepterAbilities = true
                anyAbilityToHide = true
            end
        end

        if anyAbilityToHide then
            self:HideGrantedByScepterSwappedAbilities(hParent, abilitiesToHide, hideScepterAbilities)
        end

        --fix for aghanim shard/scepter abilities that weren't added to slots 4/5
        if hParent:IsRealHero() then
            local abilityCount = hParent:GetAbilityCount()
    
            for i = 0, abilityCount - 1 , 1 do
                local testedAbility = hParent:GetAbilityByIndex(i)
                
                if testedAbility and testedAbility:IsHidden() then
                    if scepterModifiers[szBuffName] and testedAbility.scepterManuallyHide then
                        testedAbility:SetLevel(1)
                        testedAbility:SetHidden(false)
                    end

                    if szBuffName == "modifier_item_aghanims_shard" and testedAbility.shardManuallyShow then
                        testedAbility:SetLevel(1)
                        testedAbility:SetHidden(false)
                    end
                end
            end
        end
    end

    --bonus is applied in OnNPCSpawned event
    if szBuffName == "modifier_plague_wards_bonus" then
        return false
    end

    --caster must exist
	if filterTable["entindex_caster_const"] and hParent then 
		local hCaster = EntIndexToHScript( filterTable[ "entindex_caster_const" ] )
		
		--caster was removed from game
		if (not hCaster or hCaster:IsNull()) and not hCaster:IsNeutralUnitType() then
			filterTable["duration"] = 0
			return false

		--caster exist but can be already dead (need to verify modifiers on affected units!)
		elseif hCaster ~= hParent and (hCaster.specialTowerCreep) then
			--collect info about other units affected by this unit (needed when caster dies)
			if hCaster:IsAlive() then
				if not hCaster.affectedUnits then
					hCaster.affectedUnits = {}
				end

				hCaster.affectedUnits[hParent:entindex()] = hParent

			--caster is already dead -> adjust modifiers on affected units
			else
				local currentTime = GameRules:GetGameTime()
				local maxModifierDuration = 0

				--reduce modifier time when caster is dead
				if hCaster.deathTime then
					if currentTime >= hCaster.deathTime + 2.5 then

						--don't allow to add modifier when caster is dead longer than around 3s (units are removed from game after 3-4s)
						filterTable["duration"] = 0
						return false
					else
						--limit modifier time to max time when caster will be removed from game
						maxModifierDuration = hCaster.deathTime + 2.5 - currentTime
					end
				end

				if maxModifierDuration > 0 then
					filterTable["duration"] = maxModifierDuration
				else
					filterTable["duration"] = 0
					return false
				end
			end
		end
	end
    
    return true
end

function CAbilityDraftRanked:HideGrantedByScepterSwappedAbilities(hParent, abilitiesToHide, hideScepterAbilities)
    Timers:CreateTimer(0.15, function ()
        if hParent and not hParent:IsNull() then
            for abilityName, info in pairs(abilitiesToHide) do
                local ability = hParent:FindAbilityByName(abilityName)
    
                if ability then
                    if not hideScepterAbilities then
                        ability:SetHidden(true)
                    else
                        --don't hide scepter new abilities if they are in already swapped slots
                        --scepter modifiers can be added several times (from alchem, roshan etc.)
                        if ability:GetAbilityIndex() > 2 then
                            ability:SetHidden(true)
                        end
                    end
    
                    if info["auto_cast_ability"] then
                        local abilityToAutoCast = hParent:FindAbilityByName(info["auto_cast_ability"])
                        if not abilityToAutoCast:GetAutoCastState() then
                            abilityToAutoCast:ToggleAutoCast()
                        end
                    end
                end
            end
        end
    end)
end

---------------------------------------------------------------------------
--	DamageFilter
--  *entindex_victim_const
--	*entindex_attacker_const
--	*entindex_inflictor_const
--	*damagetype_const
--	*damage
---------------------------------------------------------------------------
function CAbilityDraftRanked:DamageFilter(filterTable)
    local flDamage = filterTable["damage"] or 0

	if filterTable["entindex_attacker_const"] == nil then
		return true
	end

	local hAttackerHero = EntIndexToHScript( filterTable["entindex_attacker_const"] )

    --Pendant Spells Crit Strikes
	if flDamage > 0 and hAttackerHero and hAttackerHero.HasItemInInventory and hAttackerHero:HasItemInInventory("item_stonework_pendant") then
		if filterTable["entindex_victim_const"] ~= nil and filterTable["entindex_inflictor_const"] ~= nil then

			local victim = EntIndexToHScript(filterTable["entindex_victim_const"])
			local ability = EntIndexToHScript(filterTable["entindex_inflictor_const"])

			local isAbilityBlocked = self.stoneworkArtifactNoCritAbilities[ability:GetAbilityName()]
	
			if ability and not isAbilityBlocked and victim and victim ~= hAttackerHero then
				local item = hAttackerHero:FindItemInInventory("item_stonework_pendant")

				if item and not item:IsInBackpack() and not item:IsMuted() then				
                    local spellCriticalDamage = item:GetSpecialValueFor("spells_crit_strike")
                    local spellCriticalChance = item:GetSpecialValueFor("spells_crit_chance")

                    if not hAttackerHero:PassivesDisabled() then
                        local appliesCrit = false
                        local critBurstTime = hAttackerHero:HasModifier("modifier_item_stonework_pendant_spell_crit_burst")
                        
                        if critBurstTime then
                            appliesCrit = true
                        elseif RollPseudoRandomPercentage(spellCriticalChance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, hAttackerHero) then
                            appliesCrit = true
                        end

                        if appliesCrit then
                            local damage = filterTable["damage"] * spellCriticalDamage/100
                            filterTable["damage"] = damage
                            SendOverheadEventMessage(nil, OVERHEAD_ALERT_DEADLY_BLOW , victim, damage, nil)
                        end
                    end
				end
			end
		end
    end

    return true
end

-- player_id_const: PlayerID
-- reason_const: EDOTA_ModifyGold_Reason
-- reliable: 0 | 1
-- gold: uint
function CAbilityDraftRanked:ModifyGoldFilter(event)
	local player_id = event.player_id_const
	local reason = event.reason_const

    --will not modify gold applied to unit by ModifyGold()
    if player_id and player_id > -1 and reason and TURBO_GOLD_REASON_DOUBLED[reason] and event.gold then
        event.gold = event.gold * self.turboGoldMultiplier
    end
    
	return true
end

-- hero_entindex_const: EntityIndex
-- player_id_const: PlayerID
-- reason_const: EDOTA_ModifyXP_Reason
-- experience: int
function CAbilityDraftRanked:ModifyExperienceFilter(event)
    local player_id = event.player_id_const

    if player_id and player_id > -1 and event.experience then
        event.experience = event.experience * self.turboXPModifier
    end
    
	return true
end

-- player_id_const: PlayerID
-- xp_bounty: int
-- gold_bounty: int
function CAbilityDraftRanked:ModifyBountyRuneFilter(event)
    local player_id = event.player_id_const

    if player_id and player_id > -1 then

        if event.xp_bounty  then
            event.xp_bounty = event.xp_bounty * self.turboXPModifier * 0.6
        end

        if event.gold_bounty  then
            event.gold_bounty = event.gold_bounty * self.turboGoldMultiplier * 0.5
        end
    end
    
	return true
end

---------------------------------------------------------------------------
--	ItemAddedToInventoryFilter
--  *item_entindex_const
--	*item_parent_entindex_const
--	*inventory_parent_entindex_const
--	*suggested_slot
---------------------------------------------------------------------------

function CAbilityDraftRanked:ItemAddedToInventoryFilter( filterTable )
	if filterTable["item_entindex_const"] == nil then 
		return true
	end

 	if filterTable["inventory_parent_entindex_const"] == nil then
		return true
	end

	local hItem = EntIndexToHScript( filterTable["item_entindex_const"] )
	local hInventoryParent = EntIndexToHScript( filterTable["inventory_parent_entindex_const"] )

	if hItem then
		local itemName = hItem:GetAbilityName()

        if itemName == "item_golden_treasure_upgrades" then
            return false
        end
    end

    return true
end

-- entindex_source_const: EntityIndex
-- entindex_target_const: EntityIndex
-- entindex_ability_const: EntityIndex
-- is_attack: 0 | 1
-- dodgeable: 0 | 1
-- max_impact_time: int
-- move_speed: int
-- expire_time: int
function CAbilityDraftRanked:TrackingProjectileFilter(filterTable)
    if filterTable["entindex_ability_const"] and filterTable["entindex_source_const"] and filterTable["entindex_target_const"] then
		local ability = EntIndexToHScript(filterTable["entindex_ability_const"])
		local caster = EntIndexToHScript(filterTable["entindex_source_const"])
		local target = EntIndexToHScript(filterTable["entindex_target_const"])
		
		if caster then
			if caster.lastTimeSpecialProjectileApplied and GameRules:GetGameTime() > caster.lastTimeSpecialProjectileApplied + 0.25 then
				caster.repeatedSpecialProjectiles = 0
			end
	
			if caster.repeatedSpecialProjectiles and caster.repeatedSpecialProjectiles > 10 then
				caster.repeatedSpecialProjectiles = 0
				return true
			end
		end

		if caster and target and ability and not ability:IsNull() then
			if ability:GetAbilityName() == "phantom_assassin_stifling_dagger" then
				local cosmeticInventory = caster:FindModifierByName("modifier_cosmetic_inventory_sb2023")

				if cosmeticInventory and cosmeticInventory:HasCustomAttackModifierEffect() then
					local daggerSpeed = ability:GetSpecialValueFor("dagger_speed") or 1200
					cosmeticInventory:StartAttackEffectModifierProjectile(target, caster, daggerSpeed, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2)
	
					caster.lastTimeSpecialProjectileApplied = GameRules:GetGameTime()
	
					if not caster.repeatedSpecialProjectiles then
						caster.repeatedSpecialProjectiles = 0
					end
	
					caster.repeatedSpecialProjectiles = caster.repeatedSpecialProjectiles + 1
				end
			end

			if caster.darkClawStaff and (ability:GetAbilityName() == "dazzle_poison_touch" or ability:GetAbilityName() == "dazzle_poison_touch_upgrade_sb_2023") then
				local projectileSpeed = ability:GetSpecialValueFor("projectile_speed")

				if not projectileSpeed or projectileSpeed == 0 then
					projectileSpeed = 1300
				end
				
				-- launch projectile (only for visual purposes, so Ability is nil)
				local info = {
					Target = target,
					Source = caster,
					Ability = nil,
					
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
					EffectName = "particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_poison_touch.vpcf",
					iMoveSpeed = projectileSpeed,
					bDodgeable = true,
					bIsAttack = false,
					bProvidesVision = false,
				}
			
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
	end

	return true
end