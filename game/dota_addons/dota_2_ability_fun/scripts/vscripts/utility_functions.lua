--[[ Utility Functions ]]

_G.HERO_INNATES = {
            zuus_static_field = true,
            witch_doctor_gris_gris = true,
            wisp_sight_seer = true,
            winter_wyvern_eldwurm_scholar = true,
            windrunner_easy_breezy = true,
            weaver_rewoven = true,
            warlock_eldritch_summoning = true,
            void_spirit_intrinsic_edge = true,
            visage_lurker = true,
            viper_predator = true,
            venomancer_sepsis = true,
            vengefulspirit_retribution = true,
            ursa_maul = true,
            undying_ceaseless_dirge = true,
            tusk_bitter_chill = true,
            troll_warlord_switch_stance = true,
            treant_natures_guise = true,
            tiny_craggy_exterior = true,
            tinker_eureka = true,
            tidehunter_blubber = true,
            terrorblade_dark_unity = true,
            templar_assassin_third_eye = true,
            techies_minefield_sign = true,
            sven_vanquisher = true,
            storm_spirit_galvanized = true,
            spirit_breaker_herd_mentality = true,
            spectre_spectral = true,
            sniper_keen_scope = true,
            snapfire_buckshot = true,
            slark_barracuda = true,
            slardar_seaborn_sentinel = true,
            skywrath_mage_ruin_and_restoration = true,
            skeleton_king_vampiric_spirit = true,
            shredder_exposure_therapy = true,
            silencer_brain_drain = true,
            shadow_shaman_fowl_play = true,
            shadow_demon_menace = true,
           sandking_caustic_finale = true,
            rubick_might_and_magus = true,
            ringmaster_dark_carnival_souvenirs = true,
           riki_innate_backstab = true,
            razor_unstable_current = true,
            rattletrap_armor_power = true,
           queenofpain_succubus = true,
           pugna_oblivion_savant = true,
            pudge_innate_graft_flesh = true,
            puck_puckish = true,
            primal_beast_colossal = true,
            phoenix_blinding_sun = true,
            phantom_lancer_illusory_armaments = true,
            phantom_assassin_immaterial = true,
            pangolier_fortune_favors_the_bold = true,
            oracle_prognosticate = true,
            omniknight_degen_aura = true,
            ogre_magi_dumb_luck = true,
            obsidian_destroyer_ominous_discernment = true,
            nyx_assassin_nyxth_sense = true,
            night_stalker_heart_of_darkness = true,
            nevermore_necromastery = true,
            necrolyte_sadist = true,
            naga_siren_eelskin = true,
            muerta_supernatural = true,
            morphling_accumulation = true,
            monkey_king_mischief = true,
            mirana_selemenes_faithful = true,
            meepo_sticky_fingers = true,
            medusa_mana_shield = true,
            mars_dauntless = true,
            marci_special_delivery = true,
           magnataur_solid_core = true,
           lycan_apex_predator = true,
            luna_lunar_blessing = true,
            lone_druid_gift_bearer = true,
           lion_to_hell_and_back = true,
            lina_combustion = true,
            lich_death_charge = true,
            life_stealer_feast = true,
            leshrac_defilement = true,
            legion_commander_outfight_them = true,
            kunkka_admirals_rum = true,
            kez_switch_weapons = true,
            keeper_of_the_light_mana_magnifier = true,
            juggernaut_duelist = true,
            jakiro_double_trouble = true,
            invoker_invoke = true,
            huskar_blood_magic = true,
            hoodwink_mistwoods_wayfarer = true,
            gyrocopter_chop_shop = true,
            grimstroke_ink_trail = true,
            furion_spirit_of_the_forest = true,
            faceless_void_distortion_field = true,
            enigma_gravity_well = true,
            enchantress_rabblerouser = true,
            ember_spirit_immolation = true,
            elder_titan_tip_the_scales = true,
            earthshaker_spirit_cairn = true,
            earth_spirit_stone_caller = true,
            drow_ranger_trueshot = true,
            dragon_knight_inherited_vigor = true,
            doom_bringer_lvl_pain = true,
            disruptor_electromagnetic_repulsion = true,
            death_prophet_mourning_ritual = true,
            dazzle_weave = true,
            dawnbreaker_break_of_dawn = true,
            dark_willow_pixie_dust = true,
            dark_seer_mental_fortitude = true,
            crystal_maiden_blueheart_floe = true,
            clinkz_bone_and_arrow = true,
            chen_summon_convert = true,
            chaos_knight_reins_of_chaos = true,
            centaur_horsepower = true,
            broodmother_spiders_milk = true,
            bristleback_prickly = true,
            brewmaster_belligerent = true,
            bounty_hunter_cutpurse = true,
            bloodseeker_sanguivore = true,
            beastmaster_rugged = true,
            batrider_smoldering_resin = true,
            bane_ichor_of_nyctasha = true,
            axe_coat_of_blood = true,
            arc_warden_runic_infusion = true,
            antimage_persectur = true,
            ancient_apparition_death_rime = true,
            alchemist_goblins_greed = true,
            abyssal_underlord_raid_boss = true,
            abaddon_withering_mist = true,
}

---------------------------------------------------------------------------
-- Broadcast messages to screen
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
	local centerMessage = {
		message = sMessage,
		duration = fDuration
	}
	FireGameEvent( "show_center_message", centerMessage )
end

---------------------------------------------------------------------------
-- GetRandomElement
---------------------------------------------------------------------------
function GetRandomElement( table )
	local nRandomIndex = RandomInt( 1, #table )
    local randomElement = table[ nRandomIndex ]
    return randomElement
end

---------------------------------------------------------------------------
-- ShuffledList
---------------------------------------------------------------------------
function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

---------------------------------------------------------------------------
-- string.starts
---------------------------------------------------------------------------
function string.starts( string, start )
   return string.sub( string, 1, string.len( start ) ) == start
end

---------------------------------------------------------------------------
-- string.split
---------------------------------------------------------------------------
function string.split( str, sep )
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

---------------------------------------------------------------------------
-- shallowcopy
---------------------------------------------------------------------------
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---------------------------------------------------------------------------
-- deepcopy
---------------------------------------------------------------------------
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

---------------------------------------------------------------------------
-- Table functions
---------------------------------------------------------------------------
function PrintTable( t, indent )
	--print( "PrintTable( t, indent ): " )
	if type(t) ~= "table" then return end

	for k,v in pairs( t ) do
		if type( v ) == "table" then
			if ( v ~= t ) then
				print( indent .. tostring( k ) .. ":\n" .. indent .. "{" )
				PrintTable( v, indent .. "  " )
				print( indent .. "}" )
			end
		else
		print( indent .. tostring( k ) .. ":" .. tostring(v) )
		end
	end
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function TableLength( t )
	local nCount = 0
	for _ in pairs( t ) do
		nCount = nCount + 1
	end
	return nCount
end

function tablefirstkey( t )
	for k, _ in pairs( t ) do
		return k
	end
	return nil
end

function tablehaselements( t )
	return tablefirstkey( t ) ~= nil
end

---------------------------------------------------------------------------

function TableContainsValue( t, value )
	for _, v in pairs( t ) do
		if v == value then
			return true
		end
	end

	return false
end

---------------------------------------------------------------------------

function ConvertToTime( value )
  	local value = tonumber( value )

	if value <= 0 then
		return "00:00:00";
	else
	    hours = string.format( "%02.f", math.floor( value / 3600 ) );
	    mins = string.format( "%02.f", math.floor( value / 60 - ( hours * 60 ) ) );
	    secs = string.format( "%02.f", math.floor( value - hours * 3600 - mins * 60 ) );
	    if math.floor( value / 3600 ) == 0 then
	    	return mins .. ":" .. secs
	    end
	    return hours .. ":" .. mins .. ":" .. secs
	end
end

---------------------------------------------------------------------------
-- AI functions
---------------------------------------------------------------------------

function SetAggroRange( hUnit, fRange )
	--print( string.format( "Set search radius and acquisition range (%.2f) for unit %s", fRange, hUnit:GetUnitName() ) )
	hUnit.fSearchRadius = fRange
	hUnit:SetAcquisitionRange( fRange )
	hUnit.bAcqRangeModified = true
end

--------------------------------------------------------------------------------

function MathRound(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function SplitStringBySpace(line)
	local tb = {}
	for token in string.gmatch(line, "[^%s]+") do
		table.insert(tb, token)
	 end

	 return tb
end


function FindPathablePositionNearby( vSourcePos, nMinDistance, nMaxDistance )
	local vPos = vSourcePos + RandomVector( RandomInt( nMinDistance, nMaxDistance ) )

	local nAttempts = 0
	local nMaxAttempts = 15

	while ( ( not GridNav:CanFindPath( vSourcePos, vPos ) ) and ( nAttempts < nMaxAttempts ) ) do
		vPos = vSourcePos + RandomVector( RandomInt( nMinDistance, nMaxDistance ) )
		nAttempts = nAttempts + 1
	end

	if GridNav:CanFindPath( vSourcePos, vPos ) then
		return vPos
	end

	return vSourcePos
end

function IsAbilityUsingAbilityDamageProperty(abilityName)
	if not abilityName then
		return false
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return false
	end

	local abilityDamageStr = abilityKV["AbilityDamage"]
	if not abilityDamageStr then
		return false
	end

	local stringValues = SplitStringBySpace(abilityDamageStr)

	for _, str in ipairs(stringValues) do
		if str and tonumber(str) and tonumber(str) > 0 then
			return true
		end
	end

	return false
end

function GetAbilityMaxLevelByName(abilityName)
    if not abilityName then
		return 0
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return 0
	end

	local abilityMaxLevel = abilityKV["MaxLevel"]

	if abilityMaxLevel and tonumber(abilityMaxLevel) then
		return tonumber(abilityMaxLevel)
	end

	local abilityType = abilityKV["AbilityType"]

	if abilityType then
		if abilityType == "DOTA_ABILITY_TYPE_ULTIMATE" then
			return 3
		end

		if abilityType == "DOTA_ABILITY_TYPE_BASIC" then
			return 4
		end
	end

	return 0
end

function GetAbilityBasePropertyValue(abilityName, propertyName)
    if not abilityName then
		return 0
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return 0
	end

	local propertyValue = abilityKV[propertyName]

	if propertyValue and tonumber(propertyValue) then
		return tonumber(propertyValue)
	end

	return 0
end

function HasAbilityPropertyStringFlag(abilityName, propertyName, flag)
    if not abilityName or not flag then
		return false
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return false
	end

	local abilityValues = abilityKV["AbilityValues"]
    local abilitySpecial = abilityKV["AbilitySpecial"]

	if abilityValues then
		for specialName, propertyData in pairs(abilityValues) do
			if specialName == propertyName and type(propertyData) == "table" and propertyData[flag] and 
				propertyData[flag] and type(propertyData[flag]) == "number" and propertyData[flag] == 1
			then
				return true
			end
		end
	elseif abilitySpecial then
		for _, propertyData in pairs(abilitySpecial) do
			for key, value in pairs(propertyData) do
				if key == propertyName and propertyData[flag] and type(value) == "number" and value == 1 then
					return true
				end
			end
        end
	end

	return false
end

function GetAbilityKeyValues(abilityName)
	if not abilityName then
		return {}
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return {}
	end

	local result = {}

	--ability values can be updated on server and client only using AbilityValues in KV file:
	local abilityValues = abilityKV["AbilityValues"]
    local abilitySpecial = abilityKV["AbilitySpecial"]

	if not abilityValues and not abilitySpecial then
		return {}
	end

	if abilityValues then
		for key, valueData in pairs(abilityValues) do
			if type(valueData) == "string" then
				result[key] = valueData
			elseif type(valueData) == "table" then
				if valueData["value"] and type(valueData["value"]) == "string" then
					result[key] = valueData["value"]
				end
			end
		end
	elseif abilitySpecial then
		for _, values in pairs(abilitySpecial) do
			for key, value in pairs(values) do
				if key ~= "var_type" and key ~= "RequiresScepter" and key ~= "LinkedSpecialBonus" and type(value) == "string" then
					result[key] = value
				end
			end
		end
	end

	return result
end

--curently includeShard works only for AbilityValues KV
function GetAbilityValueForLevelByName(abilityName, propertyName, abilityLevel, includeShard, includeScepter)
    if not abilityName or not propertyName then
		return 0
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return 0
	end

	--ability values can be updated on server and client only using AbilityValues in KV file:
	local abilityValues = abilityKV["AbilityValues"]
    local abilitySpecial = abilityKV["AbilitySpecial"]

	if not abilityValues and not abilitySpecial then
		return 0
	end

    local values = {}
    local strValues = ""
	local shardStrValue = ""
	local scepterStrValue = ""
    
	if abilityKV[propertyName] then
		strValues = abilityKV[propertyName]
    elseif abilityValues then
		local propertyInfo = abilityValues[propertyName]
        
		if propertyInfo then
            if type(propertyInfo) == "string" then
                strValues = propertyInfo
            elseif type(propertyInfo) == "table" then
				if propertyInfo["value"] and type(propertyInfo["value"]) == "string" then
					strValues = propertyInfo["value"]
				end

				if propertyInfo["special_bonus_shard"] and type(propertyInfo["special_bonus_shard"]) == "string" then
					shardStrValue = propertyInfo["special_bonus_shard"]
				end

				if propertyInfo["special_bonus_scepter"] and type(propertyInfo["special_bonus_scepter"]) == "string" then
					scepterStrValue = propertyInfo["special_bonus_scepter"]
				end
            end
		end

	elseif abilitySpecial then
        for _, propertyNames in pairs(abilitySpecial) do
            if type(propertyNames) == "table" and propertyNames[propertyName] and type(propertyNames[propertyName]) == "string" then
              strValues = propertyNames[propertyName]
            end
        end
    end

    if strValues ~= "" then
        local stringValues = SplitStringBySpace(strValues)

        for _, str in ipairs(stringValues) do
            if str and tonumber(str) then
                table.insert(values, tonumber(str))
            end
        end
    end

    if #values > 0 then
		local length = #values
		local levelReturn = abilityLevel

		if levelReturn > length then
			levelReturn = length
		end

		if values[levelReturn] and tonumber(values[levelReturn]) then

			if not includeShard and not includeScepter then
				return tonumber(values[levelReturn])
			elseif includeShard then
				if tonumber(shardStrValue) then
					return tonumber(values[levelReturn]) + tonumber(shardStrValue)
				end

				for _, sign in pairs({"x"}) do
					if string.sub( shardStrValue, 1, string.len( sign )) == sign and shardStrValue:gsub(sign, "") then
						local stringNumber, _ = shardStrValue:gsub(sign, "")

						if tonumber(stringNumber) then
							if sign == "x" then
								return tonumber(values[levelReturn]) * tonumber(stringNumber)
							end
						end
					end
				end

				--return normal value if can't get shard value
				return tonumber(values[levelReturn])
				
			elseif includeScepter then
				if tonumber(scepterStrValue) then
					return tonumber(values[levelReturn]) + tonumber(scepterStrValue)
				end

				local scepterValues = SplitStringBySpace(scepterStrValue)

				if scepterValues and #scepterValues > 0 then
					local scepterValuesLength = #scepterValues
					local scepterLevelReturn = abilityLevel
			
					if scepterLevelReturn > scepterValuesLength then
						scepterLevelReturn = scepterValuesLength
					end

					local scepterValue = scepterValues[scepterLevelReturn]
					
					if scepterValue and tonumber(scepterValue) then
						return tonumber(values[levelReturn]) + tonumber(scepterValue)
					end

					if scepterValue and string.starts(scepterValue, "x") then
						return tonumber(values[levelReturn]) * tonumber(scepterValue)
					end
				end
	
				--return normal value if can't get scepter value
				return tonumber(values[levelReturn])
			end
		end
    end

    return 0
end

function IsInnateAbility_AD2023(abilityName)
	local kv = GetAbilityKeyValuesByName(abilityName)

	if kv and kv["Innate"] and kv["Innate"] == "1" or HERO_INNATES[abilityName] then
		return true
	end

	return false
end

function IsConsideredHeroDamageSource( hEntity )
	return hEntity:IsOwnedByAnyPlayer() or hEntity:IsConsideredHero() or hEntity:IsBoss() or hEntity:IsZombie() or hEntity:GetUnitName() == "dota_fountain"
end

function GetAbilityPropertyFacetUnlockName(abilityName, propertyName)
    if not abilityName or not propertyName then
		return nil
	end

	local abilityKV = GetAbilityKeyValuesByName(abilityName)
	if not abilityKV then
		return nil
	end

	local abilityValues = abilityKV["AbilityValues"]

	if abilityValues then
		for specialName, propertyData in pairs(abilityValues) do
			if specialName == propertyName and type(propertyData) == "table" and propertyData["RequiresFacet"] and 
				type(propertyData["RequiresFacet"]) == "string"
			then
				return propertyData["RequiresFacet"]
			end
		end
	end

	return nil
end

function FlipTeamNumber( nTeam )
	if nTeam == DOTA_TEAM_GOODGUYS then return DOTA_TEAM_BADGUYS end
	if nTeam == DOTA_TEAM_BADGUYS then return DOTA_TEAM_GOODGUYS end
	return nTeam
end

function FindUnitsInCone_Custom(vStartPos, coneDirection, coneAngle, coneLength, bFrontalCone, teamNumber, nTeamFilter, nTypeFilter, nFlagFilter, nOrderFilter )
	local result = {}

	if coneAngle <= 0 or coneAngle >= 180 or coneLength <= 0 then
		return result
	end

	local halfConeAngle = coneAngle * 0.5
	local radius = coneLength / math.cos(halfConeAngle * math.pi/180)

	local coneCenterFinalPos = vStartPos + coneDirection * radius

	local coneRightFinalPos = RotatePosition(vStartPos, QAngle(0, -halfConeAngle, 0), coneCenterFinalPos)
	local coneLeftFinalPos = RotatePosition(vStartPos, QAngle(0, halfConeAngle, 0), coneCenterFinalPos)

	-- DebugDrawCircle(coneRightFinalPos, Vector(0, 0, 255), 255, 20, false, 2)
	-- DebugDrawCircle(coneLeftFinalPos, Vector(0, 255, 0), 255, 20, false, 2)
	-- DebugDrawLine(vStartPos, coneRightFinalPos, 255, 0, 0, false, 2)
	-- DebugDrawLine(vStartPos, coneLeftFinalPos, 255, 0, 0, false, 2)
	-- DebugDrawLine(coneRightFinalPos, coneLeftFinalPos, 255, 0, 0, false, 2)

	local enemies = FindUnitsInRadius(
		teamNumber, 
		vStartPos,
		nil,
		radius,
		nTeamFilter, 
		nTypeFilter, 
		nFlagFilter,
		nOrderFilter,
		false
	)

	for _, enemy in pairs(enemies) do
		local enemyDirection = enemy:GetAbsOrigin() - vStartPos
		enemyDirection.z = 0

		local coneRightPosDirection = coneRightFinalPos - vStartPos
		coneRightPosDirection.z = 0

		local coneLeftPosDirection = coneLeftFinalPos - vStartPos
		coneLeftPosDirection.z = 0

		local enemyConeRightDirectionDot = DotProduct(coneRightPosDirection:Normalized(), enemyDirection:Normalized())
		local enemyConeLeftDirectionDot = DotProduct(coneLeftPosDirection:Normalized(), enemyDirection:Normalized())

		local enemyConeRightDirectionAngle = 180 * math.acos( enemyConeRightDirectionDot ) / math.pi
		local enemyConeLeftDirectionAngle = 180 * math.acos( enemyConeLeftDirectionDot ) / math.pi

		if enemyConeLeftDirectionAngle >= 0 and enemyConeLeftDirectionAngle <= coneAngle and enemyConeRightDirectionAngle < coneAngle then
			if bFrontalCone then
				table.insert(result, enemy)
			else
				local enemyDistance = enemyDirection:Length2D()

				if enemyDistance <= coneLength then
					table.insert(result, enemy)
				else
					local coneCenterPosDirection = coneCenterFinalPos - vStartPos
					coneCenterPosDirection.z = 0
	
					local enemyConeCenterDirectionDot = DotProduct(coneCenterPosDirection:Normalized(), enemyDirection:Normalized())
					local enemyMaxAllowedDistance = coneLength / enemyConeCenterDirectionDot
	
					if enemyDistance <= enemyMaxAllowedDistance then
						table.insert(result, enemy)
					end
				end
			end
		end
	end

	return result
end

function IsValid(h)
    return h ~= nil and not h:IsNull()
end