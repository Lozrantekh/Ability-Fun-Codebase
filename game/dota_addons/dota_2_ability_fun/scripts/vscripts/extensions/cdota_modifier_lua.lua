-- Independent Stacks
function CDOTA_Modifier_Lua:AddIndependentStack(duration, limit, remove_on_expire, config)
	self.independent_stack_timers = self.independent_stack_timers or {}
	self.current_stack_count = self.current_stack_count or 0

	local stacks_increment = config and config.stacks or 1
	self.current_stack_count = self.current_stack_count + stacks_increment

	local timer_name = Timers:CreateTimer(duration or self:GetRemainingTime(), function(inner_timer_name)
		if not self or self:IsNull() then return end

		self.current_stack_count = self.current_stack_count - stacks_increment

		local new_stack_count = limit and math.min(self.current_stack_count, limit) or self.current_stack_count
		self:SetStackCount(new_stack_count)
		
		self.independent_stack_timers[inner_timer_name] = nil
		if new_stack_count == 0 and self:GetDuration() == -1 and remove_on_expire then self:Destroy() end
	end)

	self.independent_stack_timers[timer_name] = true

	local new_stack_count = limit and math.min(self.current_stack_count, limit) or self.current_stack_count
	self:SetStackCount(new_stack_count)
end


function CDOTA_Modifier_Lua:CancelIndependentStacks()
	for timer_name, _ in pairs(self.independent_stack_timers or {}) do
		Timers:RemoveTimer(timer_name)
		self.independent_stack_timers[timer_name] = nil
	end
	self.current_stack_count = 0
	self:SetStackCount(0)
end

function CDOTA_Modifier_Lua:ProcessLifesteal(keys, lifesteal_value)
	if not lifesteal_value or not keys then return 0 end
	if not keys.attacker or keys.attacker:IsNull() then return 0 end
	if not keys.target or keys.target:IsNull() then return 0 end
	if keys.damage <= 0 then return 0 end
	if keys.target:IsBuilding() then return 0 end

	-- lifesteal specific guard clauses
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL or IsBitSet(keys.damage_flags, DOTA_DAMAGE_FLAG_MAGIC_AUTO_ATTACK) then return 0 end
	if keys.attacker:GetTeamNumber() == keys.target:GetTeamNumber() then return 0 end	-- lifesteal does not work on allies, but spell lifesteal does
	if keys.target:IsOther() then return 0 end

	--print("LIFESTEAL", keys.damage_category, keys.damage_type, keys.damage_flags)

	local creep_reduction = 0.6 -- Change this to change the lifesteal percentage of all modifiers which use this function
	local heal = math.max(1, keys.damage * lifesteal_value * 0.01 * (keys.target:IsHero() and 1 or creep_reduction))
	keys.attacker:HealWithParams(heal, keys.inflictor, true, true, keys.attacker, false)

	local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
	ParticleManager:SetParticleControl(lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(lifesteal_pfx)

	return heal
end

function CDOTA_Modifier_Lua:ProcessSpellLifesteal(keys, spell_lifesteal_value)
	if not spell_lifesteal_value or not keys then return 0 end
	if not keys.attacker or keys.attacker:IsNull() then return 0 end
	if not keys.target or keys.target:IsNull() then return 0 end
	if keys.damage <= 0 then return 0 end
	if keys.target:IsBuilding() then return 0 end

	-- spell_lifesteal specific guard clauses
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and IsBitOff(keys.damage_flags, DOTA_DAMAGE_FLAG_MAGIC_AUTO_ATTACK) then return 0 end
	if not keys.inflictor or keys.inflictor:IsNull() then return 0 end
	if keys.damage_flags then
		if IsBitSet(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) then return 0 end
		if IsBitSet(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then return 0 end
		
		local reflection_exceptions = {
			viper_corrosive_skin = true,
			warlock_fatal_bonds = true,
			zuus_static_field = true,
		}
		if IsBitSet(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) and not reflection_exceptions[keys.inflictor:GetAbilityName()] then return 0 end
	end

	--print("SPELL LIFESTEAL", keys.damage_category, keys.damage_type, keys.damage_flags)

	local creep_reduction = 0.6 -- Change this to change the spell_lifesteal percentage of all modifiers which use this function
	local actual_damage = math.min(keys.target:GetHealth(), keys.damage)	-- prevent overhealing, only for spell lifesteal
	local heal = math.max(1, actual_damage * spell_lifesteal_value * 0.01 * (keys.target:IsHero() and 1 or creep_reduction))
	keys.attacker:HealWithParams(heal, keys.inflictor, false, true, keys.attacker, true)

	local lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
	ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
	
	return heal
end
