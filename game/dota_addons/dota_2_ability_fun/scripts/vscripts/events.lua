---------------------------------------------------------
-- dota_player_reconnected
-- * player_id
---------------------------------------------------------
function CAbilityDraftRanked:OnPlayerReconnected( event )
    if PlayerResource:IsValidPlayer( event.player_id ) then
        local playerID = event.player_id
        local player = PlayerResource:GetPlayer(playerID)
        
        if player then
            local gameState = GameRules:State_Get()

            --end hero picking
            if self.currentSelectionPhase > 0 then
                local heroName = self.playersHeroPicks[playerID] or ""

                if not heroName or heroName == "" then
                    self:MakeRandomHeroPickForPlayer(playerID)
                    heroName = self.playersHeroPicks[playerID] or ""
                end

                --end ability picking
                if self.abilityDraftPickingEnd then
                    local selectedHero = self.playersHeroSelected[playerID] or ""

                    --hero can be assigned only before game start
                    if not selectedHero or selectedHero == "" then
                        if gameState < DOTA_GAMERULES_STATE_PRE_GAME  then
                            player:SetSelectedHero(heroName)
                            self.playersHeroSelected[event.player_id] = heroName
                        end

                        Timers:CreateTimer(5, function ()
                            if gameState >= DOTA_GAMERULES_STATE_PRE_GAME then

                                local hero = player:GetAssignedHero()
                                if hero then
                                    if not self.playersAbilityModified[event.player_id] then
                                        self:SetSelectedAbilities(hero, event.player_id)
                                    end

                                    hero.realPlayerHero = true
                                else
                                    --hero assignment failed
                                    --TODO : Some logic like -> Game is save to leave, MMR will be not changed
                                end
                            end
                        end)
                    end
                end

                if gameState >= DOTA_GAMERULES_STATE_PRE_GAME then
                    local hPlayerHero = player:GetAssignedHero()
                    
                    if hPlayerHero then
                        if not self.playersAbilityModified[event.player_id] then
                            self:SetSelectedAbilities(hPlayerHero, playerID)
                        end
    
                        if self.spellsUpgrade then
                            if not self.spellsUpgrade:IsHeroAllSpellsUpgradeLocalizated(hPlayerHero) then
                                self.spellsUpgrade:VerifyHeroAbilityUpgradeList(hPlayerHero)
                            end
                            
                            --max time to wait for abilities get localize, after that try to add waiting upgrades for players from abilities that are already localized
                            Timers:CreateTimer(self.spellsUpgrade.maxTimeToLocalizeAbilitiesStartGame, function ()
                                self.spellsUpgrade:AddUpgradesFromNotLocalizedAbilities(event.player_id)
                            end)
                        end
                    end

                end
            end

        end
    end
end

function CAbilityDraftRanked:OnPlayerChat(event)
    -- DeepPrintTable(event)

    local nPlayerID = event.playerid
    if nPlayerID == -1 then
        return
    end

    local sChatMsg = event.text

    --filter commands
    local commandFilter = sChatMsg:find( '^-dummy_target$' ) or sChatMsg:find( '^-force_mmr$' ) or sChatMsg:find('^-drop_treasure [0-4] [0-1]$')

    local isCheatOnly = false

    for cheatCommand, _ in pairs(self.cheatModeRestrictedCommand) do
        if sChatMsg:find(cheatCommand) then
            isCheatOnly = true
            break
        end
    end

    if commandFilter then
        if self:IsDevPlayer(nPlayerID) then
            if sChatMsg == "-force_mmr" then
                print("force mmr")
                self.noFullLobby = false
                self.gameIsSaveToLeave = false

                self:SendChatCombatMessageTeam("#DOTA_Ability_Draft_MMR_FORCE", DOTA_TEAM_GOODGUYS, true, 0)
            end
        end

        --only in dota tools
        if not IsDedicatedServer() then
            if sChatMsg == "-dummy_target" then
                self:CreateDummyTarget(nPlayerID)
            end
        end

        --cheats only
        if isCheatOnly and GameRules:IsCheatMode() then
            local params = {}
            local strings = SplitStringBySpace(sChatMsg)
    
            for _, str in ipairs(strings) do
                if str and tonumber(str) then
                    table.insert(params, tonumber(str))
                end
            end
            
            local heroName = self.playersHeroPicks[playerID]
            
            local reservedChestID = DoUniqueString("chest_player_" .. playerID)

            --test ability upgrade treasure chest
            if sChatMsg:find("-drop_treasure") then 
                self.spellsUpgrade:CreatePlayerRandomSpellUpgrades(heroName, false, false, 0, false, 1, false, reservedChestID)
            end
        end
    end
end

function CAbilityDraftRanked:IsDevPlayer(playerID)

    return false
end

function CAbilityDraftRanked:DropTestUpgradeAbilityTreasure(nPlayerID, params)
    if not nPlayerID or not params or type(params) ~= "table" then
        return
    end

    local goldenUpradesBonus = params[1] or 0
    local showSpecialUpgrade = params[2] and params[2] == 1
    local ultimateUpgrades = params[3] and params[3] == 1

    local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if not hero then
        return
    end

    self._vPlayerStats[nPlayerID]["reroll_ability_upgrades"] = self._vPlayerStats[nPlayerID]["reroll_ability_upgrades"] + 5
    self._vPlayerStats[nPlayerID]["skip_ability_upgrades"] = self._vPlayerStats[nPlayerID]["skip_ability_upgrades"] + 5
    self._vPlayerStats[nPlayerID]["ability_golden_upgrades"] = self._vPlayerStats[nPlayerID]["ability_golden_upgrades"] + 5
    self._vPlayerStats[nPlayerID]["ability_golden_upgrades_balance"] = self._vPlayerStats[nPlayerID]["ability_golden_upgrades_balance"] + goldenUpradesBonus

    --update data on client
    CustomNetTables:SetTableValue( "players_info", string.format( "%d", nPlayerID ), self._vPlayerStats[ nPlayerID ])

    local reservedChestID = DoUniqueString("chest_player_" .. nPlayerID)

    if self.spellsUpgrade.CreatePlayerRandomSpellUpgradesWithNewAbilities then
        self.spellsUpgrade:CreatePlayerRandomSpellUpgradesWithNewAbilities(nPlayerID, showSpecialUpgrade, 3, ultimateUpgrades, 1, false, reservedChestID)
    end
end

function CAbilityDraftRanked:OnPlayerPickHero( event )
    local hPlayerHero = EntIndexToHScript( event.heroindex )
    if hPlayerHero  then
        local playerID = hPlayerHero:GetPlayerID()

        --lone druid bear (probably also meepo?) is treated as hero, levelling him trigger this event
        --so check if player with this ID has already picked hero
        if self.realPlayerHeroes[playerID] then
            return
        end

        hPlayerHero.realPlayerHero = true
        self.realPlayerHeroes[playerID] = hPlayerHero

        self:SetSelectedAbilities(hPlayerHero, playerID)

        hPlayerHero:AddNewModifier(hPlayerHero, nil, "modifier_player_ability_checker", {})

        --ability upgrades
        hPlayerHero:AddNewModifier(hPlayerHero, nil, "modifier_ability_value_upgrades_sb_2023", {})

		--ablity for opening golden treasures
		local goldenUpgrades = hPlayerHero:AddAbility("ability_open_golden_treasure")
		if goldenUpgrades then
			goldenUpgrades:SetLevel(1)
		end

		--high five
		local highFive = hPlayerHero:AddAbility("high_five_custom_sb_2023")
        if highFive then
           highFive:SetLevel(1)
			
		   --cosmetic abilities should be set in indexes 200+ to save hotkeys on server!
		   highFive:SetAbilityIndex(202)
        end

		local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

		--if(steamID == "92611038") then
		--	print("TestSpawn")
		--	FireGameEvent( "dota_combat_event_message", {message = "WEEEEEEEE YAY", teamnumber = nTeam})
		--end

        --add cosmetic items 
        --hPlayerHero:AddNewModifier(hPlayerHero, nil, "modifier_cosmetic_inventory_sb2023", {})

        --drop first treasure with upgrade for player
        Timers:CreateTimer(1.0, function ()
            if self.spellsUpgrade.CreatePlayerRandomSpellUpgrades then
                local reservedChestID = DoUniqueString("chest_player_" .. playerID)
                self.spellsUpgrade:CreatePlayerRandomSpellUpgrades(hPlayerHero, false, false, 0, false, 1, true, reservedChestID)
            end
        end)
    end
end

---------------------------------------------------------
-- npc_spawned
-- * entindex
---------------------------------------------------------
function CAbilityDraftRanked:OnNPCSpawned( event )
    local spawnedUnit = EntIndexToHScript( event.entindex )

    if spawnedUnit then
        if not IsValidEntity(spawnedUnit) then return end

        if spawnedUnit:IsRealHero() or spawnedUnit:HasModifier(modifier_vengefulspirit_command_aura_illusion) then
            if self.specialAbilityModifierUpgradesAdded[spawnedUnit:entindex()] then
                for modifierName, modifierValues in pairs(self.specialAbilityModifierUpgradesAdded[spawnedUnit:entindex()]) do
                    if not spawnedUnit:HasModifier(modifierName) then
                        spawnedUnit:AddNewModifier(spawnedUnit, nil, modifierName, modifierValues)
                    end
                end
            end
        end

        local unitName = spawnedUnit:GetUnitName()

        local openTreasureUnitsClass = {
            npc_dota_brewmaster_fire = true,
            npc_dota_brewmaster_storm = true,
            npc_dota_brewmaster_earth = true,
            npc_dota_brewmaster_void = true,
            npc_dota_lone_druid_bear = true,
        }

        --if player pick meepo then meepo clone is spawned on the map center
        if unitName == "npc_dota_hero_meepo" then
            local playerID = spawnedUnit:GetPlayerOwnerID()

            if self.realPlayerHeroes[playerID] and self.realPlayerHeroes[playerID] ~= spawnedUnit then
                spawnedUnit:SetUnitCanRespawn(false)
                spawnedUnit:ForceKill(false)
            end
        end

        if spawnedUnit:IsIllusion() and spawnedUnit:IsHero() or spawnedUnit:HasModifier("modifier_dazzle_nothl_projection_soul_clone") or spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
            local owner = spawnedUnit:GetPlayerOwner()

            if owner and not owner:IsNull() and owner:GetAssignedHero() then
                self:HandleSpawnHeroIllusion(spawnedUnit, owner)
            end
        end

        if spawnedUnit:GetClassname() == "npc_dota_lone_druid_bear" then
            self:HandleSpawnSpiritBear(spawnedUnit)
        end

        -- Fix Upgrades for units that have also bonus on hero tree talents
        -- Requires also block adding base bonus modifier (Modifier Filter, for example: modifier_plague_wards_bonus)
        if spawnedUnit:GetPlayerOwner() then
            local lycanWolves = {
                npc_dota_lycan_wolf1 = true,
                npc_dota_lycan_wolf2 = true,
                npc_dota_lycan_wolf3 = true,
                npc_dota_lycan_wolf4 = true,
                npc_dota_lycan_wolf_lane = true,
            }

            if spawnedUnit:GetClassname() == "npc_dota_venomancer_plagueward" or spawnedUnit:GetUnitName() == "npc_dota_furion_treant" or
                lycanWolves[spawnedUnit:GetUnitName()]
            then
                self:HandleSpawnSummons(spawnedUnit)
            end
        end

        if spawnedUnit:IsCreep() and not spawnedUnit.specialTowerCreep then
            local creepNeedUpgrade = string.starts(unitName, "npc_dota_creep_") and not string.find(unitName, "_flagbearer")

            if creepNeedUpgrade then
                local creepKind = "melee"

                local isRangedCreep = string.find(spawnedUnit:GetUnitName(), "_ranged")
                local isSuperCreep = string.find(spawnedUnit:GetUnitName(), "_upgraded")
                local isMegaCreep = string.find(spawnedUnit:GetUnitName(), "_mega")
    
                if isRangedCreep then
                    creepKind = "ranged"
                end
    
                if isSuperCreep then
                    if creepKind == "melee" then
                        creepKind = "super_melee"
                    else
                        creepKind = "super_ranged"
                    end
                end
    
                if isMegaCreep then
                    if creepKind == "melee" then
                        creepKind = "mega_melee"
                    else
                        creepKind = "mega_ranged"
                    end
                end
    
                local currenDotaTime =  GameRules:GetDOTATime(false, true)
                local upgradeMultiplier = math.floor((currenDotaTime + 30)/self.turboUpgradeInterval)

                if upgradeMultiplier > 0 then
                    if creepKind == "ranged" then
                        --creeps have base death xp all game (probably the real XP is counted when unit is killed)
                        local xp = spawnedUnit:GetDeathXP()
                        spawnedUnit:SetDeathXP(0)
        
                        xp = xp + 10 * upgradeMultiplier
                        spawnedUnit.newDeathXP = xp
                    end
        
                    local creepUpgrades = CREEPS_UPGRADES_INTERVAL[creepKind]
        
                    if creepUpgrades then
                        local hp = creepUpgrades["hp"] or 0
                        local attack = creepUpgrades["attack"] or 0
                        local gold = creepUpgrades["gold"] or 0
        
                        if gold and gold > 0 then
                            local minGold = spawnedUnit:GetMinimumGoldBounty()
                            local maxGold = spawnedUnit:GetMaximumGoldBounty()
        
                            spawnedUnit:SetMinimumGoldBounty(0)
                            spawnedUnit:SetMaximumGoldBounty(0)
        
                            spawnedUnit.newMinGold = minGold + gold * upgradeMultiplier
                            spawnedUnit.newMaxGold = maxGold + gold * upgradeMultiplier
    
                            -- print("base gold max: ", maxGold, " po zwiekszeniu: ",  maxGold + gold * upgradeMultiplier)
                        end
    
                        local creepStatsMultiplier = math.min(upgradeMultiplier, self.maxCreepsUpgradeMultiplier) * 2.2
    
                        -- every 7.5 minute Dota automatically upgrade creeps so need to reduce multiplier by dota multiplier
                        -- we upgrade it every 2.5 minute, so every 3th upgrade will overlap base Dota upgrades
                        -- Dota spawn lane creeps asynchronously starting around 26 sec before spawn time (so 4 sec after current wave)
                        if creepStatsMultiplier >= 3 then
                            local dotaBaseMultiplier = math.floor((currenDotaTime + 30) / 450)

                            if dotaBaseMultiplier > 0 then
                                creepStatsMultiplier = math.max(creepStatsMultiplier - dotaBaseMultiplier, 1)
                            end
                        end

                        if hp and hp > 0 then
                            spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetBaseMaxHealth() + hp * creepStatsMultiplier)
                            spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() + hp * creepStatsMultiplier)
                            spawnedUnit:SetHealth(spawnedUnit:GetHealth() + hp * creepStatsMultiplier)
                        end
        
                        if attack and attack > 0 then
                            spawnedUnit:SetBaseDamageMin(spawnedUnit:GetBaseDamageMin() + attack * creepStatsMultiplier)
                            spawnedUnit:SetBaseDamageMax(spawnedUnit:GetBaseDamageMax() + attack * creepStatsMultiplier)
                        end
                    end
                end
            end
        end

        -- death units can crash game if their modifiers stays on other units
        if spawnedUnit:IsNeutralUnitType() or spawnedUnit.specialTowerCreep then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_fix_death_units_crash_modifiers", {})
        end
    end
end

function CAbilityDraftRanked:HandleSpawnSpiritBear(hero)
    if hero:GetPlayerOwner() then
        local heroOwner = hero:GetPlayerOwner():GetAssignedHero()
        if heroOwner then
            heroOwner.spiritBearEntity = hero
            hero.spiritBearOwner = heroOwner
        end

        if heroOwner.spiritBearConsumedTomes then
            local counter = 0
            local itemToReEquip = nil

            for tomeName, tomeData in pairs(heroOwner.spiritBearConsumedTomes) do
                counter = counter + 1 
                local tomeCounter = tomeData["counter"]

                if not itemToReEquip and not hero:HasAnyAvailableInventorySpace() then
                    local item = hero:GetItemInSlot(0)

                    if item then
                        hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
                        itemToReEquip = item
                    end
                end

                for i = 1, tomeCounter, 1 do
                    local tome = hero:AddItemByName(tomeName)
                    if tome then
                        tome:OnSpellStart()

                        if tome:GetContainer() then
                            UTIL_Remove(tome:GetContainer())
                        end

                        tome:RemoveSelf()
                    end
                end
            end

            if itemToReEquip then
                for _, container in pairs(Entities:FindAllByClassnameWithin("dota_item_drop", hero:GetOrigin(), 300)) do
                    if container:GetContainedItem() and container:GetContainedItem() == itemToReEquip then
                        hero:PickupDroppedItem( container )
                        break
                    end
                end
            end
        end
    
        if not hero:HasModifier("modifier_spirit_bear_upgrades_ad_2023") then
            hero:AddNewModifier(hero, nil, "modifier_spirit_bear_upgrades_ad_2023", {})
        end
    end
end

function CAbilityDraftRanked:HandleSpawnSummons(spawnedUnit)
    if not spawnedUnit then
        return
    end

    local hero = spawnedUnit:GetPlayerOwner():GetAssignedHero()

    if hero then
        local abilityName = "venomancer_plague_ward"
        local talentMultiplyName = "special_bonus_unique_venomancer"
        local hpSpecialName = "ward_hp_tooltip"
        local dmgMinSpecialName = "ward_damage_tooltip"
        local dmgMaxSpecialName = "ward_damage_tooltip"
        local batAttackSpecialName = ""

        if spawnedUnit:GetUnitName() == "npc_dota_furion_treant" then
            abilityName = "furion_force_of_nature"
            talentMultiplyName = "special_bonus_unique_furion"
            hpSpecialName = "treant_health"
            dmgMinSpecialName = "treant_damage_min"
            dmgMaxSpecialName = "treant_damage_max"
        end

        local lycanWolves = {
            npc_dota_lycan_wolf1 = true,
            npc_dota_lycan_wolf2 = true,
            npc_dota_lycan_wolf3 = true,
            npc_dota_lycan_wolf4 = true,
            npc_dota_lycan_wolf_lane = true,
        }

        if lycanWolves[spawnedUnit:GetUnitName()] then
            abilityName = "lycan_summon_wolves"
            talentMultiplyName = ""
            hpSpecialName = "wolf_hp"
            dmgMinSpecialName = "wolf_damage"
            dmgMaxSpecialName = "wolf_damage"
            batAttackSpecialName = "wolf_bat"
        end

        local ability = hero:FindAbilityByName(abilityName)

        if ability then
            local unitHP = ability:GetSpecialValueFor(hpSpecialName)
            local unitMinDamage = ability:GetSpecialValueFor(dmgMinSpecialName)
            local unitMaxDamage = ability:GetSpecialValueFor(dmgMaxSpecialName)

            if talentMultiplyName and talentMultiplyName ~= "" and hero:HasLearnedTalent(talentMultiplyName) then
                local talent = hero:FindAbilityByName(talentMultiplyName)
                if talent then
                    local multiplier = talent:GetSpecialValueFor("value")
                    if multiplier == 0 then
                        multiplier = 2.5
                    end

                    --veno needs all bonus 2.5 x because bonus modifier is blocked
                    --talents applies modifier (blocked in filters)
                    if spawnedUnit:GetClassname() == "npc_dota_venomancer_plagueward" then
                       unitHP = math.floor(unitHP / multiplier)
                       unitMinDamage = math.floor(unitMinDamage / multiplier)
                       unitMaxDamage = math.floor(unitMaxDamage / multiplier)
                    end

                    --treants needs only missing %talent bonus from upgrade bonus (1.5x)
                    --talents does not apply modifier
                    --if spawnedUnit:GetUnitName() == "npc_dota_furion_treant" then
                    --    local ownerUpgradeModifier = hero:FindModifierByName("modifier_ability_value_upgrades_sb_2023")

                    --    if ownerUpgradeModifier and ownerUpgradeModifier.GetTotalBonusForAbilityProperty then
                    --       local hpBonus = ownerUpgradeModifier:GetTotalBonusForAbilityProperty(abilityName, hpSpecialName)
                    --        local damageBonus = ownerUpgradeModifier:GetTotalBonusForAbilityProperty(abilityName, dmgMaxSpecialName)

                    --        unitHP = unitHP + math.floor(hpBonus * (multiplier - 1) + 0.5)
                    --        unitMinDamage = unitMinDamage + math.floor(damageBonus * (multiplier - 1) + 0.5)
                    --        unitMaxDamage = unitMaxDamage + math.floor(damageBonus * (multiplier - 1) + 0.5)
                    --    end
                    --end
                end
            end

            if unitHP > 0 then
                spawnedUnit:SetBaseMaxHealth(unitHP)
                spawnedUnit:SetMaxHealth(unitHP)
                spawnedUnit:SetHealth(unitHP)
            end

            if unitMinDamage > 0 then
                spawnedUnit:SetBaseDamageMin(unitMinDamage)
            end

            if unitMaxDamage > 0 then
                spawnedUnit:SetBaseDamageMax(unitMaxDamage)
            end

            if batAttackSpecialName ~= "" then
                spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_summoned_unit_bat_upgrade_ad_2023", 
                                            {
                                                ability_name = abilityName,
                                                property_name = batAttackSpecialName
                                            }
                )
            end
        end
    end
end

---------------------------------------------------------
-- dota_match_done
-- * userid
-- * reason
-- * name
-- * networkid
-- * xuid (steam_id?)
-- * PlayerID
---------------------------------------------------------
function CAbilityDraftRanked:OnPlayerDisconnect(event)
    print("disconnect")
    -- DeepPrintTable(event)
    
    local teams = {
        [DOTA_TEAM_GOODGUYS] = true,
        [DOTA_TEAM_BADGUYS] = true
    }
    
    if event.PlayerID and teams[PlayerResource:GetTeam(event.PlayerID)] and not self.playersForceLoseMMR[event.PlayerID] then
        self.disconnectedPlayers[event.PlayerID] = {
            disconnect_time = GameRules:GetGameTime(),
            game_state = GameRules:State_Get(),
        }
    end
end

-- entindex_killed: EntityIndex, 
-- entindex_attacker: EntityIndex, 
-- entindex_inflictor: EntityIndex, 
-- damagebits: long
function CAbilityDraftRanked:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    local killer = EntIndexToHScript(event.entindex_attacker)

	if killedUnit:IsHero() then
		local playerID = killedUnit:GetPlayerOwnerID()

		local team = PlayerResource:GetTeam( playerID )
	
		if (team == DOTA_TEAM_GOODGUYS) and ((GetTeamHeroKills(DOTA_TEAM_GOODGUYS) - GetTeamHeroKills(DOTA_TEAM_BADGUYS)) > 9) and (self.teamGoodGuysAmount > self.teamBadGuysAmount) then
			GameRules:LockCustomGameSetupTeamAssignment(false)	
			PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_BADGUYS)
			killedUnit:SetTeam(DOTA_TEAM_BADGUYS)
			GameRules:LockCustomGameSetupTeamAssignment(true)

			self.teamGoodGuysAmount = self.teamGoodGuysAmount - 1
			self.teamBadGuysAmount = self.teamBadGuysAmount + 1
		elseif (team == DOTA_TEAM_BADGUYS) and ((GetTeamHeroKills(DOTA_TEAM_BADGUYS) - GetTeamHeroKills(DOTA_TEAM_GOODGUYS)) > 9) and (self.teamBadGuysAmount > self.teamGoodGuysAmount) then
			GameRules:LockCustomGameSetupTeamAssignment(false)	
			PlayerResource:SetCustomTeamAssignment(playerID, 2)
			killedUnit:SetTeam(DOTA_TEAM_GOODGUYS)
			GameRules:LockCustomGameSetupTeamAssignment(true)

			self.teamGoodGuysAmount = self.teamGoodGuysAmount + 1
			self.teamBadGuysAmount = self.teamBadGuysAmount - 1
		end

		if (abs(GetTeamHeroKills(DOTA_TEAM_BADGUYS) - GetTeamHeroKills(DOTA_TEAM_GOODGUYS)) > 30) and self.balanceShuffleCooldown == 0 then
			local players = self:GetAllPlayersConnectedFromLobby()
			
			GameRules:LockCustomGameSetupTeamAssignment(false)

			ShuffledList(players)
			local tictoc = RandomInt(0, 1)
			self.teamGoodGuysAmount = 0
			self.teamBadGuysAmount = 0

			for _, playerID in pairs(players) do
				local player = PlayerResource:GetPlayer(playerID)
				local hero = player:GetAssignedHero()
				if (tictoc) then
					PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
					hero:SetTeam(DOTA_TEAM_GOODGUYS)
					self.teamGoodGuysAmount = self.teamGoodGuysAmount + 1
					tictoc = false
				else
					PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_BADGUYS)
					hero:SetTeam(DOTA_TEAM_BADGUYS)
					self.teamBadGuysAmount = self.teamBadGuysAmount + 1
					tictoc = true
				end
			end
			
			GameRules:LockCustomGameSetupTeamAssignment(true)
			self.balanceShuffleCooldown = 15
        end
	end

    if killedUnit and killer then
        if killedUnit:IsCreep() then
            --xp
            if killedUnit.newDeathXP then
                local xp = killedUnit.newDeathXP
                if not killer:IsNeutralUnitType() and killer:GetTeamNumber() == killedUnit:GetTeamNumber() then
                    xp = xp / 2
                end
        
                local enemyHeroes = FindUnitsInRadius(killedUnit:GetTeamNumber(),
                                    killedUnit:GetAbsOrigin(),
                                    nil,
                                    1500,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_CLOSEST,
                                    false
                )

                if enemyHeroes and #enemyHeroes > 0 then
                    for _, hero in pairs(enemyHeroes) do
                        if hero and hero:IsRealHero() then
                            local xpPerPlayer = math.floor((killedUnit.newDeathXP / #enemyHeroes)  + 0.5)
    
                            --Turbo Mode:
                            --AddExperience seems not to go through filter, so neeed to be increased here
    
                            xpPerPlayer = xpPerPlayer * self.turboXPModifier * 0.75
                            hero:AddExperience(xpPerPlayer, DOTA_ModifyXP_CreepKill, false, false)
                        end
                    end
                end
            end

            --gold
            if (killer:IsRealHero() or killer:GetOwnerEntity()) and killer:GetTeamNumber() ~= killedUnit:GetTeamNumber() and killedUnit.newMinGold and killedUnit.newMaxGold then
                local gold = RandomInt(math.floor(killedUnit.newMinGold), math.floor(killedUnit.newMaxGold))

                --Turbo Mode:
                --this gold will not be increase in the filter, so need to change here
                gold = gold * self.turboGoldMultiplier * 0.5

                if killer:IsRealHero() then
                    killer:ModifyGold(gold, false, DOTA_ModifyGold_CreepKill)
                    SendOverheadEventMessage(killer:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, killedUnit, gold, killer:GetPlayerOwner())
                else
                    local owner = killer:GetPlayerOwner()
                    if owner then
                        local heroOwner = owner:GetAssignedHero()
                        heroOwner:ModifyGold(gold, false, DOTA_ModifyGold_CreepKill)
                        SendOverheadEventMessage(owner, OVERHEAD_ALERT_GOLD, killedUnit, gold, owner)
                    end
                end
            end
        end

        --if canDropSpecialTreasureUpgrades then
        --    self:DropGoldenTreasureSpecialUpgrades(killer, killedUnit)
        --end
    end
end

function CAbilityDraftRanked:DropGoldenTreasureSpecialUpgrades(killerUnit, killedUnit)
    local randomPosition = killedUnit:GetAbsOrigin()
    local modelScale = 1.35
    local addExtraParticles = true

    if killedUnit:IsTower() then

        if killerUnit:IsRealHero() then
            local direction = (killerUnit:GetAbsOrigin() - killedUnit:GetAbsOrigin()):Normalized()
            randomPosition = killerUnit:GetAbsOrigin() + direction * 150
        else
            --try to find heroes around
            local heroFound = false
            local Heroes = HeroList:GetAllHeroes()

            for _,Hero in pairs ( Heroes ) do
                if Hero and Hero:IsRealHero() and Hero:GetTeamNumber() ~= killedUnit:GetTeamNumber() and Hero:IsAlive() then
                    if (Hero:GetAbsOrigin() - killedUnit:GetAbsOrigin()):Length2D() <= 750 then
                        local direction = (Hero:GetAbsOrigin() - killedUnit:GetAbsOrigin()):Normalized()
                        randomPosition = Hero:GetAbsOrigin() + direction * 150
                        heroFound = true
                        break
                    end
                end
            end

            --use forward vectors
            if not heroFound and self.towersForwardVector[killedUnit:GetUnitName()] then
                local forwardVector = self.towersForwardVector[killedUnit:GetUnitName()]
                randomPosition = killedUnit:GetAbsOrigin() + forwardVector * 450
            end
        end
    else
        randomPosition = killedUnit:GetAbsOrigin() + RandomVector(100)
        modelScale = 0.9
        addExtraParticles = false
    end

    randomPosition = GetClearSpaceForUnit(killerUnit, randomPosition)

    local angles = Vector(0, RandomInt(45, 135), 0)
    local newItem = CreateItem( "item_golden_treasure_upgrades", nil , nil )

    if newItem then
        newItem:SetPurchaseTime( 0 )
        local treasureItemContainer = SpawnEntityFromTableSynchronous( "dota_item_drop", {} )

        if treasureItemContainer then
            treasureItemContainer:SetContainedItem( newItem )
            treasureItemContainer:SetAbsOrigin(killedUnit:GetAbsOrigin())
            treasureItemContainer:SetAngles( angles.x, angles.y, angles.z)

            treasureItemContainer:SetModel("models/props_generic/chest_treasure_02.vmdl")
            treasureItemContainer:SetModelScale(modelScale)

            treasureItemContainer:SetMaterialGroup("1")
            treasureItemContainer:SetSequence("chest_treasure_idle")

            newItem:LaunchLoot( false, 400, 0.75, randomPosition, nil)
            EmitSoundOn("Treasure.Upgrades.Drop", killedUnit)

            local goldenTreasure = CreateUnitByName("npc_treasure_chest", killerUnit:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)

            if goldenTreasure then
                goldenTreasure:SetAbsOrigin(randomPosition)
                goldenTreasure:SetAngles( angles.x, angles.y, angles.z )
                goldenTreasure:SetModelScale(modelScale)
                goldenTreasure:AddEffects(EF_NODRAW)

                --set hidden golden treasure on item container to change order (in filters) from pick up item to cast ability on target (hidden golden treasure)
                treasureItemContainer.hiddenTreasure = goldenTreasure

                --set item container on hidden golden treasure to remove item after finish channeling
                goldenTreasure.itemEntityOrdered = treasureItemContainer
                
                if killedUnit:IsTower() then
                    local towerLevel = 1
                    goldenTreasure.droppedByTower = true
                    
                    local towerKV = GetUnitKeyValuesByName(killedUnit:GetUnitName())
            

                    towerLevel = 1

                    goldenTreasure.towerLevel = towerLevel
                end

                --seems like launch loot sometimes can put item not exactly in set position
                Timers:CreateTimer(1, function ()
                    if goldenTreasure and not goldenTreasure:IsNull() and treasureItemContainer and not treasureItemContainer:IsNull() then
                        goldenTreasure:SetAbsOrigin(treasureItemContainer:GetAbsOrigin())

                        if addExtraParticles then
                            local nFXIndex = ParticleManager:CreateParticle( "particles/effects/treasure/treasure_effect_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, treasureItemContainer )
                            treasureItemContainer.fxParticleIndex = nFXIndex
                        end
                    end
                end)
            end
        end
    end
end

-- entindex: EntityIndex, 
-- player_id: int
function CAbilityDraftRanked:OnBuyBack(event)
    if not event.player_id then
        return
    end

    PlayerResource:SetCustomBuybackCooldown(event.player_id, self.turboBuybackTime)
end

---------------------------------------------------------
-- dota_match_done
-- * winningteam 
---------------------------------------------------------
function CAbilityDraftRanked:OnMatchDone(event)
    -- DeepPrintTable(event)
    
    local dataToServer = {}
    local allPlayers = self:GetAllPlayersConnectedFromLobby()

    for _, playerID in pairs(allPlayers) do
        local mmrChange = 0
        local playerTeam = PlayerResource:GetTeam(playerID)

        if event.winningteam and not self.gameIsSaveToLeave then
            if event.winningteam == playerTeam then
                mmrChange = 25
            else
                mmrChange = -25
            end
        end

        if self.playersForceLoseMMR[playerID] then
            mmrChange = -25
        end

        local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

        --uncomment for testing with bots
        if steamID == "0" then
            steamID = playerID + 100
        end

        if mmrChange ~= 0 then
            table.insert(dataToServer, {steam_id = steamID, mmr_change = mmrChange})
        end

        --Game End Screen
        if self._vPlayerStats[playerID] then
            self._vPlayerStats[playerID]["mmr_change"] = mmrChange
            self._vPlayerStats[playerID]["net_worth"] = PlayerResource:GetNetWorth(playerID) or 0
            self._vPlayerStats[playerID]["kills"] = PlayerResource:GetKills(playerID) or 0
            self._vPlayerStats[playerID]["deaths"] = PlayerResource:GetDeaths(playerID) or 0
            self._vPlayerStats[playerID]["assists"] = PlayerResource:GetAssists(playerID) or 0
            self._vPlayerStats[playerID]["last_hits"] = PlayerResource:GetLastHits(playerID) or 0
            self._vPlayerStats[playerID]["denies"] = PlayerResource:GetDenies(playerID) or 0
            self._vPlayerStats[playerID]["gold_per_m"] = PlayerResource:GetGoldPerMin(playerID) or 0
            self._vPlayerStats[playerID]["xp_per_m"] = PlayerResource:GetXPPerMin(playerID) or 0
        end

        CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), self._vPlayerStats[playerID] )
    end

    --no collect stats currently!
    -- _HTTPConnection:updateMatchTestData({match_id = tostring(GameRules:Script_GetMatchID()), crash = false}, 0)
end
---------------------------------------------------------
-- dota_player_gained_level
-- * player (player entity index)
-- * level (new level)
---------------------------------------------------------

function CAbilityDraftRanked:OnPlayerGainedLevel( event )
    if not IsServer() then
        return
    end

    if not event.hero_entindex then
        return
    end

    local hero = EntIndexToHScript(event.hero_entindex)

    if hero and hero.realPlayerHero then
        local playerID = hero:GetPlayerOwnerID() or -1
        local heroLevel = hero:GetLevel() or 1

        if heroLevel == 6 then
            local heroName = hero:GetUnitName()
		    local abilityCount = hero:GetAbilityCount()
		
		    for i = 0, abilityCount - 1 , 1 do
			    local ability = hero:GetAbilityByIndex(i)
                local notpickedability = true

                if ability then

					local aName = ability:GetAbilityName()

                    local baseAbilityCounter = 0
                    for _, abilityData in ipairs(self.playersPickedAbilities[playerID]) do
                        local abilityName = abilityData["ability_name"] or ""
                        if aName == abilityName then
                            notpickedability = false
                        elseif SWAP_ABILITIES[abilityName] == aName or BASE_SUB_ABILITIES[abilityName] == aName or REQUIRED_EXTRA_ABILITY[abilityName] == aName or ABILITIES_ACTIVATE_AUTOCAST[abilityName] == aName or ((REQUIRED_EXTRA_ABILITY[abilityName] and REQUIRED_EXTRA_ABILITY[abilityName][aName])) or SCEPTER_NEW_ABILITIES_HIDDEN[aName] then
                            notpickedability = false
	                    end
                    end

		            if ability and not ability:IsAttributeBonus() and notpickedability then
                        local currentLevel = ability:GetLevel()
                        local maxLevel = ability:GetMaxLevel()
                        if currentLevel > maxLevel then
                            currentLevel = maxLevel
                        end
			    	    ability:SetLevel(currentLevel+1);
				    end
                end
			end
		end

        if heroLevel == 12 then
            local heroName = hero:GetUnitName()
		    local abilityCount = hero:GetAbilityCount()
		
		    for i = 0, abilityCount - 1 , 1 do
			    local ability = hero:GetAbilityByIndex(i)
                local notpickedability = true

                if ability then

					local aName = ability:GetAbilityName()

                    local baseAbilityCounter = 0
                    for _, abilityData in ipairs(self.playersPickedAbilities[playerID]) do
                        local abilityName = abilityData["ability_name"] or ""
                        if aName == abilityName then
                            notpickedability = false
                        elseif SWAP_ABILITIES[abilityName] == aName or BASE_SUB_ABILITIES[abilityName] == aName or REQUIRED_EXTRA_ABILITY[abilityName] == aName or ABILITIES_ACTIVATE_AUTOCAST[abilityName] == aName or ((REQUIRED_EXTRA_ABILITY[abilityName] and REQUIRED_EXTRA_ABILITY[abilityName][aName])) or SCEPTER_NEW_ABILITIES_HIDDEN[aName] then
                            notpickedability = false
	                    end
                    end

		            if ability and not ability:IsAttributeBonus() and notpickedability then
                        local currentLevel = ability:GetLevel()
                        local maxLevel = ability:GetMaxLevel()
                        if currentLevel > maxLevel then
                            currentLevel = maxLevel
                        end
			    	    ability:SetLevel(currentLevel+1);
				    end
                end
			end
		end

        if heroLevel == 18 then
            local heroName = hero:GetUnitName()
		    local abilityCount = hero:GetAbilityCount()
		
		    for i = 0, abilityCount - 1 , 1 do
			    local ability = hero:GetAbilityByIndex(i)
                local notpickedability = true

                if ability then

					local aName = ability:GetAbilityName()

                    local baseAbilityCounter = 0
                    for _, abilityData in ipairs(self.playersPickedAbilities[playerID]) do
                        local abilityName = abilityData["ability_name"] or ""
                        if aName == abilityName then
                            notpickedability = false
                        elseif SWAP_ABILITIES[abilityName] == aName or BASE_SUB_ABILITIES[abilityName] == aName or REQUIRED_EXTRA_ABILITY[abilityName] == aName or ABILITIES_ACTIVATE_AUTOCAST[abilityName] == aName or ((REQUIRED_EXTRA_ABILITY[abilityName] and REQUIRED_EXTRA_ABILITY[abilityName][aName])) or SCEPTER_NEW_ABILITIES_HIDDEN[aName] then
                            notpickedability = false
	                    end
                    end

		            if ability and not ability:IsAttributeBonus() and notpickedability then
                        local currentLevel = ability:GetLevel()
                        local maxLevel = ability:GetMaxLevel()
                        if currentLevel > maxLevel then
                            currentLevel = maxLevel
                        end
			    	    ability:SetLevel(currentLevel+1);
				    end
                end
			end
		end

        --if heroLevel == 15 then
        --  canShowNewAbility = true
        --  abilityNumber = 3
        --end

        --if heroLevel == 20 then
        --  canShowSpecialUpgrade = true
        --  canShowNewAbility = false
        --end

        --if heroLevel == 25 then
        --  canShowSpecialUpgrade = true
        --  canShowNewAbility = true
        --  isUltimateAbility = true
        --  abilityNumber = 3


            --currently not needed utlimate ability available on level 30!
            -- if self.extraUltimateAbilitiesPicked[playerID] and self.extraUltimateAbilitiesPicked[playerID] > 0 then
            --  isUltimateAbility = false
            --  canShowNewAbility = true
            --  abilityNumber = 0
            -- end

            -- local goldenTreasureChanceIncrease = self.playerLevel30TreasureChanceIncrease

            -- if not self.extraGoldenTreasureChance[hero:GetTeamNumber()] then
            --  self.extraGoldenTreasureChance[hero:GetTeamNumber()] = self.baseGoldenTreasureChance
            -- end

            -- self.extraGoldenTreasureChance[hero:GetTeamNumber()] = math.min(self.extraGoldenTreasureChance[hero:GetTeamNumber()] + goldenTreasureChanceIncrease, 100)

            -- local sendInfo = true
            -- if self.extraGoldenTreasureChance[hero:GetTeamNumber()] > 100 then
            --  sendInfo = false
            -- end

            -- if sendInfo then
            --  local extraInfo = {
            --      ability_name = "ability_open_golden_treasure",
            --      text = "Team Player Level 30 Reached: Extra Golden Treasure Chance Drop Increased To: <font color='gold'>" .. self.extraGoldenTreasureChance[hero:GetTeamNumber()] .. "%</font>",
            --      duration = 3.5,
            --      golden_style = true,
            --  }
                
            --  CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "player_extra_info", extraInfo)

            --  local gameEvent = {}
            --  gameEvent["player_id"] = playerID
            --  gameEvent["locstring_value"] = self.extraGoldenTreasureChance[hero:GetTeamNumber()] .. "%"
            --  gameEvent["message"] = "#DOTA_Ability_Draft_Player_Level30"
            --  gameEvent["teamnumber"] = hero:GetTeamNumber()
            
            --  FireGameEvent( "dota_combat_event_message", gameEvent )
            -- end
        --end

        if heroLevel > 0 and heroLevel % 5 == 0 then

            if canShowNewAbility then
                if heroLevel < 20 then
                    self._vPlayerStats[playerID]["skip_ability_upgrades"] = self._vPlayerStats[playerID]["skip_ability_upgrades"] + 1

                elseif heroLevel > 20 then
                    self._vPlayerStats[playerID]["skip_ability_upgrades"] = self._vPlayerStats[playerID]["skip_ability_upgrades"] + 2
                end

                CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), self._vPlayerStats[ playerID ])

                local reservedChestID = DoUniqueString("chest_player_" .. playerID)

                self.spellsUpgrade:CreatePlayerRandomSpellUpgrades(hero, canShowSpecialUpgrade, false, 0, false, 1, false, reservedChestID)

            elseif self.spellsUpgrade.CreatePlayerRandomSpellUpgrades then
                self.spellsUpgrade:CreatePlayerRandomSpellUpgrades(hero, canShowSpecialUpgrade, false, 0, false, 1, false, reservedChestID)
            end
        end
    end
end

function CAbilityDraftRanked:OnCustomKeyBindSet(eventSourceIndex, event)
    if not event.key_bind or not event.new_command_name or not event.player_id or not event.ability_slot then
        return
    end

    local playerID = event.player_id

    if not self.playersCustomKeyBinds then
        self.playersCustomKeyBinds = {}
    end

    if not self.playersCustomKeyBinds[playerID] then
        self.playersCustomKeyBinds[playerID] = {
            all_registered_keybinds = {}
        }
    end

    for slot, data in pairs(self.playersCustomKeyBinds[playerID]) do
        if data and data["key_bind"] and data["key_bind"] == event.key_bind then
            self:CustomKeyBindRemove(playerID, slot)
        end
    end

    if not self.playersCustomKeyBinds[playerID][event.ability_slot] then
        self.playersCustomKeyBinds[playerID][event.ability_slot] = {}
    end
        
    self.playersCustomKeyBinds[playerID][event.ability_slot]["key_bind"] = event.key_bind
    self.playersCustomKeyBinds[playerID][event.ability_slot]["new_command_name"] = event.new_command_name
    self.playersCustomKeyBinds[playerID][event.ability_slot]["new_command_name_tooltip"] = event.new_command_name_tooltip or ""
    self.playersCustomKeyBinds[playerID][event.ability_slot]["quick_cast"] = event.quick_cast or 0

    if event.original_key_bind and event.original_key_bind ~= "" then
        self.playersCustomKeyBinds[playerID][event.ability_slot]["original_key_bind"] = event.original_key_bind
        self.playersCustomKeyBinds[playerID]["all_registered_keybinds"][event.original_key_bind] = true
    end

    if event.org_command_name and event.org_command_name ~= "" then
        self.playersCustomKeyBinds[playerID][event.ability_slot]["org_command_name"] = event.org_command_name
    end

    if event.item_slot and event.item_slot ~= "" then
        self.playersCustomKeyBinds[playerID][event.ability_slot]["item_slot"] = event.item_slot
    end

    self.playersCustomKeyBinds[playerID]["all_registered_keybinds"][event.key_bind] = true

    CustomNetTables:SetTableValue( "custom_key_binds", string.format( "%d", playerID ),  self.playersCustomKeyBinds[playerID])
end

function CAbilityDraftRanked:OnCustomKeyBindRemoved(eventSourceIndex, event)
    if not event.ability_slot or not event.player_id then
        return
    end
    
    self:CustomKeyBindRemove(event.player_id, event.ability_slot)
end

function CAbilityDraftRanked:CustomKeyBindRemove(playerID, abilitySlot)
    --keep quickcastStatus only
    if not playerID or not abilitySlot then
        return
    end

    if not self.playersCustomKeyBinds or not self.playersCustomKeyBinds[playerID] or not self.playersCustomKeyBinds[playerID][abilitySlot] then
        return
    end

    local quickCastStatus = self.playersCustomKeyBinds[playerID][abilitySlot]["quick_cast"] or 0

    self.playersCustomKeyBinds[playerID][abilitySlot] = {}
    self.playersCustomKeyBinds[playerID][abilitySlot]["quick_cast"] = quickCastStatus
    
    CustomNetTables:SetTableValue( "custom_key_binds", string.format( "%d", playerID ),  self.playersCustomKeyBinds[playerID])
end

function CAbilityDraftRanked:OnCustomKeyBindQuickCast(eventSourceIndex, event)
    if not event.player_id or not event.ability_slot or not event.quick_cast then
        return
    end

    local playerID = event.player_id

    if not self.playersCustomKeyBinds then
        self.playersCustomKeyBinds = {}
    end

    if not self.playersCustomKeyBinds[playerID] then
        self.playersCustomKeyBinds[playerID] = {
            all_registered_keybinds = {}
        }
    end

    if not self.playersCustomKeyBinds[playerID][event.ability_slot] then
        self.playersCustomKeyBinds[playerID][event.ability_slot] = {}
    end

    self.playersCustomKeyBinds[playerID][event.ability_slot]["quick_cast"] = event.quick_cast

    CustomNetTables:SetTableValue( "custom_key_binds", string.format( "%d", playerID ),  self.playersCustomKeyBinds[playerID])
end

function CAbilityDraftRanked:SetSavedCustomHotKeys(nPlayerID, hotkeysData)
	if hotkeysData then
		local hotKeys = {}
		local allRegisterdKeys = {}
		local anyHotKeySaved = false
		local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

		if hero then
			for _, data in pairs(hotkeysData) do
				local keybind = data["key_bind"]
				local abilityIndex = data["ability_index"]

				if keybind and abilityIndex then
					local ability_count = hero:GetAbilityCount()

					if ability_count then
						for abilitySlot = 0, ability_count - 1 do
							local ability = hero:GetAbilityByIndex( abilitySlot )
				
							if ability and ability:GetAbilityIndex() == abilityIndex then
								hotKeys[abilitySlot] = {
									key_bind = keybind
								}

								allRegisterdKeys[keybind] = true
								anyHotKeySaved = true
							end
						end
					end
				end
			end

			hotKeys["all_registered_keybinds"] = allRegisterdKeys

			if anyHotKeySaved then
				self.playersCustomKeyBinds[nPlayerID] = hotKeys
				CustomNetTables:SetTableValue( "custom_key_binds", string.format( "%d", nPlayerID ), self.playersCustomKeyBinds[nPlayerID])

				CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "recreate_hotkeys", {} )
			end
		end
	end
end

function CAbilityDraftRanked:GetPlayersHotKeysDataToSave()
	local hotKeysData = {}

	for playerID, data in pairs(self.playersCustomKeyBinds) do
		hotKeysData[playerID] = {}

		for slot, slotData in pairs(data) do
			if slotData["key_bind"] and slotData["key_bind"] ~= "" then
				
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if hero then
					local ability = hero:GetAbilityByIndex(slot)

					--potions and cometic abilities are in slots 100+
					if ability and ability:GetAbilityIndex() > 100 then
						local dataToSave = {
							key_bind = slotData["key_bind"],
							ability_index = ability:GetAbilityIndex(),
						}

						table.insert(hotKeysData[playerID], dataToSave)
					end
				end
			end
		end
	end

	return hotKeysData
end

function CAbilityDraftRanked:GetSinglePlayerHotKeysDataToSave(playerID)
	local hotKeysData = {}

	if not self.playersCustomKeyBinds[playerID] then
		return nil
	end

	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	if not hero then
		return nil
	end

	for slot, slotData in pairs(self.playersCustomKeyBinds[playerID]) do
		if slotData["key_bind"] and slotData["key_bind"] ~= "" then
			
			local ability = hero:GetAbilityByIndex(slot)

			--potions and cometic abilities are in slots 100+
			if ability and ability:GetAbilityIndex() > 100 then
				local dataToSave = {
					key_bind = slotData["key_bind"],
					ability_index = ability:GetAbilityIndex(),
				}

				table.insert(hotKeysData, dataToSave)
			end
		end
	end

	return hotKeysData
end