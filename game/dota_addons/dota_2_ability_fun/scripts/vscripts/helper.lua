-- CDOTA_BaseNPC -----------------------------------------------------------------
function CDOTA_BaseNPC:_GetIllusionParent()
	local modifier_illusion = self:FindModifierByName("modifier_illusion")
	if modifier_illusion then
		return modifier_illusion:GetCaster()
	end

    return nil
end

function CDOTA_BaseNPC:HasLearnedTalent(talentName)
	if self:FindAbilityByName(talentName) and self:FindAbilityByName(talentName):GetLevel() > 0 then
		return true
	end

	return false
end

function CDOTA_BaseNPC:HasPlayerItemInInventoryOrBackpack_SB2023(itemName)
	local LAST_BACK_PACK_ITEM_SLOT = 8

	if not self:HasInventory() then
		return false
	end

	for itemSlot = 0, LAST_BACK_PACK_ITEM_SLOT, 1 do
        local item = self:GetItemInSlot( itemSlot )
        if item and not item:IsMuted() and item:GetAbilityName() == itemName then
			return true
		end
	end

	return false
end

function CDOTA_BaseNPC:IsItemInStash_SB2023(itemToVerify)
	if not self:HasInventory() then
		return false
	end

	if not itemToVerify or itemToVerify:IsNull() then
		return false
	end

	for itemSlot = DOTA_ITEM_STASH_MIN, DOTA_ITEM_STASH_MAX, 1 do
        local item = self:GetItemInSlot( itemSlot )
        if item and item == itemToVerify then
			return true
		end
	end

	return false
end

function CDOTA_BaseNPC:_IsUnitOnTreeDance()
	local modifier = self:HasModifier("modifier_monkey_king_tree_dance_activity")
	local modifier2 = self:HasModifier("modifier_monkey_king_tree_dance_hidden")

	if modifier or modifier2 then
		return true
	end

	return false
end

function CDOTA_BaseNPC:_IsUnitJumpingOnTree()
	local modifier1 = self:HasModifier("modifier_monkey_king_bounce_perch")
	local modifier2 = self:HasModifier("modifier_monkey_king_bounce_leap")

	if modifier1 or modifier2  then
		return true
	end

	return false
end

function CDOTA_BaseNPC:_HasHeroAghanimShard()
    return self:HasModifier("modifier_item_aghanims_shard")
end

function CDOTA_BaseNPC:_HasAppliedState_SB2023(state)
	local buffs = self:FindAllModifiers()

	for _,buff in pairs( buffs ) do
		if buff ~= nil and buff then
			local states = {}
			buff:CheckStateToTable(states)

			for key, value in pairs(states) do
				if value == true then
					if tostring(key) == tostring(state) then
						return true
					end
				end
			end
		end
	end

	return false
end

function CDOTA_BaseNPC:GetAllOwnNeutralItems_SB2023()
	--this table is updated in token item
	if not self.ownNeutralItems then
		self.ownNeutralItems = {}
	end

	local result = {}

	for _, itemNames in pairs(self.ownNeutralItems) do
		for _, itemName in pairs(itemNames) do
			if itemName and itemName ~= "" then
				table.insert(result, itemName)
			end
		end
	end

	return result
end

function CDOTA_BaseNPC:GetOwnNeutralItemsByTiers_SB2023()
	--this table is updated in token item
	if not self.ownNeutralItems then
		self.ownNeutralItems = {}
	end

	return self.ownNeutralItems
end

--update table (in Siltbreaker neutral items are shareable, so player can have more than one from each tier)
function CDOTA_BaseNPC:UpdateOwnNeutralItems_SB2023()
	local item = self:GetItemInSlot( DOTA_ITEM_NEUTRAL_SLOT )
	if item and not item.isNeutralToken and item:IsNeutralDrop() and item:GetPurchaser() == self then
		self:AddOwnNeutralItem_SB2023(item)
	end
end

function CDOTA_BaseNPC:AddOwnNeutralItem_SB2023(item, tokenTier)
	if not self.ownNeutralItems then
		self.ownNeutralItems = {}
	end

	local itemName = item:GetAbilityName()
		
	if not tokenTier or not tonumber(tokenTier) or tokenTier == 0 then
		local ItemData = LoadKeyValues( "scripts/npc/neutral_items.txt" )
		if ItemData ~= nil then
			for tier, tierData in pairs( ItemData ) do
				if tierData["items"] then
	
					for neutralName, _ in pairs(tierData["items"]) do
						if neutralName == itemName then
							tokenTier = tier
							
							break
						end
					end
				end
			end
		end
	end

	if itemName == "item_recipe_trident" then
		itemName = "item_trident"
	end

	if tokenTier and tonumber(tokenTier) then
		if not self.ownNeutralItems[tonumber(tokenTier)] then
			self.ownNeutralItems[tonumber(tokenTier)] = {}
		end
		
		table.insert(self.ownNeutralItems[tonumber(tokenTier)], itemName)
	end
end

--remove this when valve fix ForceKill() will trigger entity_killed event
function CDOTA_BaseNPC:ForceKill_SB_2023(bReincarnate)
	if not self.entityKilledEventFired then
		FireGameEvent("entity_killed",
			{
				entindex_killed = self:entindex(),
				entindex_attacker = self:entindex(),
				entindex_inflictor = nil,
			}
		)
	end

	self:ForceKill(bReincarnate)
end

function CDOTA_BaseNPC:IsHeroRangedAttacker_AD_2023()
	local heroData = DOTAGameManager:GetHeroDataByName_Script(self:GetUnitName())

	if heroData and heroData["AttackCapabilities"] then
		if heroData["AttackCapabilities"] == "DOTA_UNIT_CAP_RANGED_ATTACK" then
			return true
		end
	end

	return false
end

function CDOTA_BaseNPC:_IsMount_SB2023()
	if self:GetUnitName() == "npc_dota_base_mount" then
		return true
	end

	return false
end

function CDOTA_BaseNPC:_GetPlayerMount_SB2023()
	if self.hCurrentRidingMount and not self.hCurrentRidingMount:IsNull() then
		return self.hCurrentRidingMount
	end

	return nil
end

function CDOTA_BaseNPC:_IsPlayerMounted_SB2023()
	if not self:_GetPlayerMount_SB2023() then
		return false
	end

	if self.hCurrentRidingMount:IsAlive() and self:HasModifier("modifier_mounted") then
		return true
	end

	return false
end

function CDOTA_BaseNPC:_RespawnPlayerMount_SB2023(respawnPos)
	local mount = self:_GetPlayerMount_SB2023()

	if mount then
		mount:SetRespawnPosition(respawnPos)
		mount:RespawnHero(false, false)
	end
end

function CDOTA_BaseNPC:_SetPlayerMount_SB2023(hMount)
	if hMount and not hMount:IsNull() then
		self.hCurrentRidingMount = hMount
	end
end

_G.HERO_FACETS_ORDER = {
	npc_dota_hero_dragon_knight = {
		"dragon_knight_fire_dragon",
		"dragon_knight_corrosive_dragon",
		"dragon_knight_frost_dragon",
	}
}

--can return nil if can't find hero facet name (need add info with hero facet orders to: HERO_FACETS_ORDER)
function CDOTA_BaseNPC:GetHeroFacetName_SB2023()
	if not HERO_FACETS_ORDER[self:GetUnitName()] then
		return nil
	end

	local heroPickedFacet = self:GetHeroFacetID()

	if heroPickedFacet and tonumber(heroPickedFacet) and tonumber(heroPickedFacet) > 0 then
		local pickedFacetName = HERO_FACETS_ORDER[self:GetUnitName()][tonumber(heroPickedFacet)]

		if pickedFacetName then
			--confirm with facet available to choose
			local kv = GetUnitKeyValuesByName(self:GetUnitName())

			if kv and kv["Facets"] then
				for name, _ in pairs(kv["Facets"]) do
					if name == pickedFacetName then
						return pickedFacetName
					end
				end
			end
		end
	end

	return nil
end

------------------------------------------------------------------ CDOTA_BaseNPC --

local CastRangeValueName = {
	faceless_void_time_walk = "range",
	mirana_leap = "leap_distance",
}

local AghanimShardRangeBuff = {
	faceless_void_time_walk = 150
}

local ItemsRangeBuff = {
	item_aether_lens = 225
}

-- CDOTABaseAbility -----------------------------------------------------------------

function CDOTABaseAbility:_GetAbilityRealCastRange_SB2023(pos)
	if not self or self:IsNull() then
		return 0
	end

	local abilityRange = self:GetEffectiveCastRange(pos, nil) or 0

	if CastRangeValueName[self:GetAbilityName()] then
		abilityRange = self:GetSpecialValueFor(CastRangeValueName[self:GetAbilityName()])

		if self:GetCaster() then
			if AghanimShardRangeBuff[self:GetAbilityName()] and self:GetCaster():_HasHeroAghanimShard() then
				abilityRange = abilityRange + AghanimShardRangeBuff[self:GetAbilityName()]
			end

			if  ItemsRangeBuff["item_aether_lens"] and self:GetCaster():HasItemInInventory("item_aether_lens") then
				abilityRange = abilityRange + ItemsRangeBuff["item_aether_lens"]
			end
		end
	end

	return abilityRange
end


local SecretAbilities = {
	ability_capture = true,
	abyssal_underlord_portal_warp = true,
	twin_gate_portal_warp = true,
	ability_lamp_use = true,
	ability_pluck_famango = true,
}

function CDOTABaseAbility:_IsSecretRequiredAbility()
	if not self or self:IsNull() then
		return false
	end

	if SecretAbilities[self:GetAbilityName()] then
		return true
	end

	return false
end

function CDOTABaseAbility:_IsInnate_AD2023()
	local kv = GetAbilityKeyValuesByName(self:GetAbilityName())

	if kv and kv["Innate"] and kv["Innate"] == "1" then
		return true
	end

	return false
end

----------------------------------------------------------------- CDOTABaseAbility --

--party testing
-- function CDOTA_PlayerResource:GetPartyID(playerID)
-- 	if playerID <=4 then
-- 		return 2323123123
-- 	end

-- 	if playerID <= 11 then
-- 		return 2222999442
-- 	end

-- 	if playerID <= 17 then
-- 		return 1231231237
-- 	end

-- 	-- if playerID <= 14 then
-- 	-- 	return 2323112999
-- 	-- end

-- 	return 0
-- end