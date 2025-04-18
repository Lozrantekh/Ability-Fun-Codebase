-- Has Aghanim's Shard
function C_DOTA_BaseNPC:HasShard()
	 return self:HasModifier("modifier_item_aghanims_shard")
end

function C_DOTA_BaseNPC:HasTalent(talent_name)
	if not self or self:IsNull() then return end

	local talent = self:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then return true end
end

function C_DOTA_BaseNPC:FindTalentValue(talent_name, key)
	if self:HasTalent(talent_name) then
		local value_name = key or "value"
		return self:FindAbilityByName(talent_name):GetSpecialValueFor(value_name)
	end
	return 0
end

function C_DOTA_BaseNPC:IsDueling()
	return self:HasModifier("modifier_hero_dueling")
end

ENFOS_ARENA_PVP = 1
ENFOS_ARENA_RADIANT = 2
ENFOS_ARENA_DIRE = 3

function C_DOTA_BaseNPC:GetEnfosArena()
	local unit_loc = self:GetAbsOrigin()

	if unit_loc.x < -4000 then
		return ENFOS_ARENA_RADIANT
	elseif unit_loc.x > 4000 then
		return ENFOS_ARENA_DIRE
	else
		return ENFOS_ARENA_PVP
	end
end

function GetEnfosArena(location)
	if location.x < -4000 then
		return ENFOS_ARENA_RADIANT
	elseif location.x > 4000 then
		return ENFOS_ARENA_DIRE
	else
		return ENFOS_ARENA_PVP
	end
end

function GetEnfosArenaForTeam(team)
	if team == DOTA_TEAM_GOODGUYS then
		return ENFOS_ARENA_RADIANT
	elseif team == DOTA_TEAM_BADGUYS then
		return ENFOS_ARENA_DIRE
	end
end

function RegisterSpecialValuesModifier(modifier)
	local parent = modifier:GetParent()

	parent.special_values_modifiers = parent.special_values_modifiers or {}

	if not table.contains(parent.special_values_modifiers, modifier) then
		table.insert(parent.special_values_modifiers, modifier)
	end

	-- print("REGISTERED SPECIAL VALUE MODIFIER", modifier, modifier:GetName())

	-- for k,v in ipairs(parent.special_values_modifiers) do
	-- 	print(k, v, v:IsNull() and "NULL" or v:GetName())
	-- end
end

function RegisterSpellAmplifyMultModifier(modifier)
	local parent = modifier:GetParent()

	parent.spell_amp_mult_modifiers = parent.spell_amp_mult_modifiers or {}

	if not table.contains(parent.spell_amp_mult_modifiers, modifier) then
		table.insert(parent.spell_amp_mult_modifiers, modifier)
	end
end


function C_DOTABaseAbility:IsNeutralDrop()
	if self.is_neutral_drop == nil then
		local kv = GetAbilityKeyValuesByName(self:GetAbilityName())
		self.is_neutral_drop = tonumber(kv.ItemIsNeutralDrop) == 1
	end
	
	return self.is_neutral_drop
end
