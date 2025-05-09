function CDOTA_BaseNPC:IsMonkeyClone()
	return (self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_wukongs_command_warrior"))
end

function CDOTA_BaseNPC:IsBoundsEnforced()
	return not (self:IsMonkeyClone() or self:HasModifier("modifier_cosmetic_pet") or self:HasModifier("modifier_hidden_caster_dummy"))
end

function CDOTA_BaseNPC:IsMainHero()
	return IsValidEntity(self) and PlayerResource:GetSelectedHeroEntity(self:GetPlayerOwnerID()) == self
end

function CDOTA_BaseNPC:IsSpiritBear()
	return self:GetUnitLabel() == "sprit_bear"
end

function CDOTA_BaseNPC:RemoveAbilityForEmpty(ability_name)
	local ability = self:FindAbilityByName(ability_name)
	if not ability then return end
	local index = ability:GetAbilityIndex()
	-- if ability is hidden, and has secondary ability that is unhidden, 
	-- then secondary is active and we should swap placeholder with it
	-- to preserve keybinds slots
	if ability:IsHidden() then
		local hero = ability:GetCaster()
		local linked_abilities = HeroBuilder.linked_abilities[ability_name]
		local linked_unhidden = false
		for _, linked_ability_name in pairs(linked_abilities or {}) do
			local linked_ability = hero:FindAbilityByName(linked_ability_name)
			if linked_ability and not linked_ability:IsHidden() then
				linked_unhidden = true
				local linked_index = linked_ability:GetAbilityIndex()
				if linked_index < index then
					index = linked_ability:GetAbilityIndex()
				end
				break
			end
		end
	end
	ability:Disable()
	if index <= 5 then -- only swap if we get assigned hotkey, otherwise pointless
		self:SwapAbilities(ability_name, "empty_"..index, false, false)
	end

	ability:SetRemovalTimer()
end

function CDOTA_BaseNPC:AddNewAbility(ability_name)
	local ability = self:AddAbility(ability_name)
	ability:ClearFalseInnateModifiers()
	return ability
end

function CDOTA_BaseNPC:AddEndChannelListener(listener)
	local endChannelListeners = self.EndChannelListeners or {}
	self.EndChannelListeners = endChannelListeners
	local index = #endChannelListeners + 1
	endChannelListeners[index] = listener
end

--restructure abilities so hotkeys preserve
function CDOTA_BaseNPC:RemoveAbilityWithRestructure(ability_name)
	local ability = self:FindAbilityByName(ability_name)
	if not ability then return end

	ability:Disable()
	
	local index = ability:GetAbilityIndex()
	local placeholder_name = "empty_"..index

	self:SwapAbilities(ability_name, placeholder_name, false, false)

	ability:SetRemovalTimer()

	if index > 5 then return end
	Timers:CreateTimer(function()
		--reindexing entire ability tree 
		for i = index, 25 do
			local next_ability = self:GetAbilityByIndex(i + 1)
			if next_ability and not next_ability.placeholder and not next_ability:IsHidden() then
				local next_ability_name = next_ability:GetAbilityName()
				if not next_ability_name:find("special_bonus") then
					self:SwapAbilities(placeholder_name, next_ability_name, false, true)
				end
			end
		end
	end)
end


function CDOTA_BaseNPC_Hero:HeroLevelUpWithMinValue(min_level, play_particles)
	local needLevels = min_level + 1 - self:GetLevel()
	local totalLevels = needLevels > 0 and needLevels or 1
	for _ = 1, totalLevels do
		self:HeroLevelUp(play_particles)
	end
end

-- Has Aghanim's Shard
function CDOTA_BaseNPC:HasShard()
	if not self or self:IsNull() then return end

	return self:HasModifier("modifier_item_aghanims_shard")
end

-- Talent handling
function CDOTA_BaseNPC:HasTalent(talent_name)
	if not self or self:IsNull() then return end

	local talent = self:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then return true end
end


function CDOTA_BaseNPC:FindTalentValue(talent_name, key)
	if self:HasTalent(talent_name) then
		local value_name = key or "value"
		return self:FindAbilityByName(talent_name):GetSpecialValueFor(value_name)
	end
	return 0
end


function CDOTA_BaseNPC:IsBossCreep()
	return self.is_boss == true
end


function CDOTA_BaseNPC:IsClashRoshan()
	return (self:GetUnitName() == "npc_dota_roshan" or self:GetUnitName() == "npc_dota_duos_roshan")
end


function CDOTA_BaseNPC:IsDueling()
	return self:HasModifier("modifier_hero_dueling")
end


function CDOTA_BaseNPC:GetCreepGoldAmplification()
	local creep_gold_amp = 0

	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetModifierCreepGoldAmplification then
			creep_gold_amp = creep_gold_amp + modifier:GetModifierCreepGoldAmplification()
		end
	end

	return creep_gold_amp
end


function CDOTA_BaseNPC:GetBetGoldAmplification()
	local bet_gold_amp = 0

	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetModifierBetGoldAmplification then
			bet_gold_amp = bet_gold_amp + modifier:GetModifierBetGoldAmplification()
		end
	end

	return bet_gold_amp
end


function CDOTA_BaseNPC:GetDuelGoldAmplification()
	local duel_gold_amp = 0

	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetModifierDuelGoldAmplification then
			duel_gold_amp = duel_gold_amp + modifier:GetModifierDuelGoldAmplification()
		end
	end

	return duel_gold_amp
end


function CDOTA_BaseNPC:GetTalentValue(talent_name)
	local talent = self:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() >= 1 then return talent:GetSpecialValueFor("value") end

	return 0
end


function CDOTA_BaseNPC:HasCooldownOnItems()
	if self:IsNull() or (not self:HasInventory()) then return true end

	for slot = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
		local item = self:GetItemInSlot(slot)
		if item and item:GetCooldownTimeRemaining() > 0 then
			return true
		end
	end

	return false
end

local auto_ready_ignored_abiliites = {
	["high_five_custom"] = true,
}

function CDOTA_BaseNPC:HasCooldownOnAbilities()

	for i = 0, self:GetAbilityCount() - 1 do
		local ability = self:GetAbilityByIndex(i)
		if ability and ability:GetCooldownTimeRemaining() > 0 and not auto_ready_ignored_abiliites[ability:GetName()]then
			return true
		end
	end
	return false
end

CDOTA_BaseNPC.GetStatusResistanceHero = CDOTA_BaseNPC.GetStatusResistanceHero or CDOTA_BaseNPC.GetStatusResistance
function CDOTA_BaseNPC:GetStatusResistance()
	if self:IsHero() then
		return self:GetStatusResistanceHero()
	end

	local status_resistance_total = 1
	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetModifierStatusResistanceStacking then
			status_resistance_total = status_resistance_total * (1 - modifier:GetModifierStatusResistanceStacking() / 100)
		end
	end
	return 1 - status_resistance_total
end

function CDOTA_BaseNPC:RegisterManuallySpentAttributePoint()
	local current = self.manually_spent_ability_points or 0
	self.manually_spent_ability_points = current + 1
end


function CDOTA_BaseNPC:GetManuallySpentAttributePoints()
	return self.manually_spent_ability_points or 0
end

function CDOTA_BaseNPC:IncrementCurseCount()
	local curse_modifier = self:FindModifierByName("modifier_loser_curse")

	-- Wait before hero alive to add modifier
	if self:IsReincarnating() then
		Timers:CreateTimer(1, function() 
			self:IncrementCurseCount()
			return
		end)
	end

	if not curse_modifier then
		curse_modifier = self:AddNewModifier(self, nil, "modifier_loser_curse", nil)
	end

	if not curse_modifier then return end

	curse_modifier:IncrementStackCount()

	local player_id = self:GetPlayerOwnerID()
	CustomGameEventManager:Send_ServerToAllClients("player_debuff_loser", {
		playerId = player_id, 
		loserCount = curse_modifier:GetStackCount()
	})

	local bear = self:GetSummonedBear()
	if bear then
		local modifier = bear:AddNewModifier(self, nil, "modifier_loser_curse", nil)
		if modifier then
			modifier:SetStackCount(curse_modifier:GetStackCount())
		end
	end
end

function CDOTA_BaseNPC:DecrementCurseCount()
	local curse_modifier = self:FindModifierByName("modifier_loser_curse")
	if not curse_modifier then return end

	curse_modifier:DecrementStackCount()
	local curse_count = curse_modifier:GetStackCount()

	local player_id = self:GetPlayerOwnerID()
	CustomGameEventManager:Send_ServerToAllClients("player_debuff_loser", {
		playerId = player_id, 
		loserCount = curse_count,
		decrement = true
	})

	if curse_count <= 0 then
		curse_modifier:Destroy()
	end

	local bear = self:GetSummonedBear()
	if bear then
		if curse_count > 0 then
			local modifier = bear:AddNewModifier(self, nil, "modifier_loser_curse", nil)
			if modifier then modifier:SetStackCount(curse_count) end
		else
			bear:RemoveModifierByName("modifier_loser_curse")
		end
	end
end

function CDOTA_BaseNPC:RemoveCurse()
	self:RemoveModifierByName("modifier_loser_curse")

	local player_id = self:GetPlayerOwnerID()
	CustomGameEventManager:Send_ServerToAllClients("player_debuff_loser", {
		playerId = player_id, 
		loserCount = 0,
		decrement = true
	})

	local bear = self:GetSummonedBear()
	if bear then
		bear:RemoveModifierByName("modifier_loser_curse")
	end
end

function CDOTA_BaseNPC:ReduceCooldowns(amount, only_items)
	local seen_shared_cd_names = {}

	if not only_items then
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local ability = self:GetAbilityByIndex(i)

			if ability then
				local shared_cd_name = ability:GetSharedCooldownName()
			
				if not seen_shared_cd_names[shared_cd_name] then
					ability:ReduceCooldown(amount)
					seen_shared_cd_names[shared_cd_name] = true
				end
			end
		end
	end

	for i = 0, DOTA_ITEM_MAX - 1 do
		local item = self:GetItemInSlot(i)
		if item then
			local shared_cd_name = item:GetSharedCooldownName()

			if not seen_shared_cd_names[shared_cd_name] then
				item:ReduceCooldown(amount)
				seen_shared_cd_names[shared_cd_name] = true
			end
		end
	end
end


function CDOTA_BaseNPC:RefreshIntrinsicModifiers()
	for i = 0, DOTA_MAX_ABILITIES - 1 do
		local ability = self:GetAbilityByIndex(i)
		if ability and not ability:IsNull() and ability:GetLevel() > 0 then
			ability:RefreshIntrinsicModifier()
		end
	end
end

function CDOTA_BaseNPC:FindItem(item_name, in_inventory, in_backpack, in_stash)
	local item_result

	if in_inventory then
		for i = 0, 5 do
			local item = self:GetItemInSlot(i)

			if item and item:GetAbilityName() == item_name then
				item_result = item
				break
			end
		end
	end

	if in_backpack then
		for i = 6, 8 do
			local item = self:GetItemInSlot(i)

			if item and item:GetAbilityName() == item_name then
				item_result = item
				break
			end
		end
	end

	if in_stash then
		for i = DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
			local item = self:GetItemInSlot(i)

			if item and item:GetAbilityName() == item_name then
				item_result = item
				break
			end
		end
	end

	return item_result
end

function CDOTA_BaseNPC:OverdueItemsInInventory()
	local current_time = GameRules:GetGameTime()

	for i = 0, 5 do
		local item = self:GetItemInSlot(i)
		if item and current_time - item:GetPurchaseTime() < 10 then
			item:SetPurchaseTime(current_time - 11)
		end
	end
end

local modifier_debuff_amp_list = {
	modifier_item_timeless_relic = -20,
}

---@param caster CDOTA_BaseNPC
function CDOTA_BaseNPC:ApplyStatusResistance(value, caster)
	local debuff_amp = 1

	if IsValidEntity(caster) then
		local modifiers = caster:FindAllModifiers()
		
		for _, modifier in pairs(modifiers) do
			if modifier.GetModifierStatusResistanceCaster then
				local amp = modifier:GetModifierStatusResistanceCaster()

				if type(amp) == "number" then
					debuff_amp = debuff_amp * (1 - amp * 0.01)
				end
			else
				local name = modifier:GetName()

				if modifier_debuff_amp_list[name] then
					debuff_amp = debuff_amp * (1 - modifier_debuff_amp_list[name] * 0.01)
				end
			end
		end
	end

	return value * (1 - self:GetStatusResistance()) * debuff_amp
end

--- Add a modifier to this unit, applies status resistance to duration.
---@param caster CDOTA_BaseNPC
---@param ability CDOTABaseAbility
---@param modifier_name string
---@param modifier_table table
function CDOTA_BaseNPC:AddNewModifierSR(caster, ability, modifier_name, modifier_table)
	if modifier_table and modifier_table.duration then
		modifier_table.original_duration = modifier_table.duration
		modifier_table.duration = self:ApplyStatusResistance(modifier_table.duration, caster)
	end

	return self:AddNewModifier(caster, ability, modifier_name, modifier_table)
end

function CDOTA_BaseNPC:IsStrongIllusion()
	return (self:HasModifier("modifier_chaos_knight_phantasm_illusion") or self:HasModifier("modifier_vengefulspirit_hybrid_special"))
end

function CDOTA_BaseNPC:SetBaseDamage(damage)
	self:SetBaseDamageMin(damage)
	self:SetBaseDamageMax(damage)
end

function CDOTA_BaseNPC:SetBaseMaxHealthUpdate(new_health)
	local current_health_pct = self:GetHealthPercent()

	self:SetBaseMaxHealth(new_health)
	
	Timers:CreateTimer(0.01, function()
		self:SetHealth(new_health * current_health_pct)
	end)
end

function CDOTA_BaseNPC:GetRealAttackPoint()
	return self:GetAttackAnimationPoint() * 100 / self:GetDisplayAttackSpeed()
end

function CDOTA_BaseNPC:GetPhysicalResistance()
	local armor = self:GetPhysicalArmorValue(false)

	return (armor * 0.06) / (1 + armor * 0.06)
end

function CDOTA_BaseNPC_Hero:GiveGold(gold, reason, gold_ticks)
	local player_id = self:GetPlayerID()
	local gold_per_tick = math.floor(gold / gold_ticks)
	local last_tick_gold = gold - gold_per_tick * gold_ticks

	Timers:CreateTimer(0.2, function()
		local coin_pfx = ParticleManager:CreateParticle("particles/custom/mammonite_medium.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(coin_pfx, 0, self:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(coin_pfx)

		gold_ticks = gold_ticks - 1

		if gold_ticks > 0 then
			RoundManager:GiveGoldToPlayer(player_id, gold_per_tick, nil, reason)
			return 0.2
		else
			RoundManager:GiveGoldToPlayer(player_id, gold_per_tick + last_tick_gold, nil, reason)
		end
	end)
end

-- Checks if the attacker's damage is classified as "hero damage".	 More `or`s may need to be added.
function CDOTA_BaseNPC:IsHeroDamage(damage)
	if self.is_hero_damage then return self.is_hero_damage end

	if damage > 0 then
		if self:IsControllableByAnyPlayer() or self:IsClashRoshan() then
			self.is_hero_damage = true

			return true
		end
	end

	return false
end

function CDOTA_BaseNPC:GetHeroArenaCenter()
	return GameMode.arena_centers[self:GetTeam()]
end

function CDOTA_BaseNPC:GetHeroCurrentArenaCenter()
	if self:IsDueling() then
		return GameMode.pvp_center
	else
		return GameMode.arena_centers[self:GetTeam()]
	end
end

function CDOTA_BaseNPC_Hero:GetBetPercent()
	local bet_percent = BET_MANAGER_BASE_BET_PERCENTAGE / 100

	for _, mod in pairs(self:FindAllModifiers()) do
		if mod.GetBetPercentIncrease then
			bet_percent = 1 - (1 - bet_percent) * (1 - mod:GetBetPercentIncrease() / 100)
		end
	end

	return bet_percent
end

function CDOTA_BaseNPC:SetSplittingAttacksNow(new_state)
	self.split_attacks = new_state
end

function CDOTA_BaseNPC:IsSplittingAttacksNow()
	return self.split_attacks
end

-- Performs an attack while preventing new splits
function CDOTA_BaseNPC:PerformSplitAttack(target, useCastAttackOrb, processProcs, ignoreInvis, neverMiss)
	self:SetSplittingAttacksNow(true)
	self:PerformAttack(target, useCastAttackOrb, processProcs, true, ignoreInvis, false, false, neverMiss)
	self:SetSplittingAttacksNow(false)
end
