-------------------------------------------
-- Battle Hunger enemy modifier
-------------------------------------------

modifier_scream_of_the_dead_debuff_dot = modifier_scream_of_the_dead_debuff_dot or class({})

function modifier_scream_of_the_dead_debuff_dot:OnCreated( params )
	if IsServer() then
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.tick_rate = 1 --once per second
		self.deny_allow_modifier = "modifier_scream_of_the_dead_debuff_deny"
		
		
		self.damage_over_time = self:GetAbility():GetSpecialValueFor("damage_per_second" )
		self.agi_mult = self:GetAbility():GetSpecialValueFor("agi_multiplier")

		self.kill_count = 0
		self.last_damage_time = GameRules:GetGameTime()
		self.battle_hunger_particle = "particles/scream/axe_battle_hunger.vpcf"
		self.enemy_particle = ParticleManager:CreateParticle( self.battle_hunger_particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.enemy_particle, 2, Vector(0, 0, 0))

		self:StartIntervalThink(self.tick_rate)
	end
end

function modifier_scream_of_the_dead_debuff_dot:OnRefresh()
	self.kill_count = 0
end

function modifier_scream_of_the_dead_debuff_dot:OnIntervalThink()
	if IsServer() then
		local agi = 0
		if self.parent:IsHero() or self.parent:IsIllusion() then
			agi = self.parent:GetAgility()
		end
		local damageTable = {
			victim = self.parent,
			attacker = self.caster,
			damage = self.damage_over_time + self.agi_mult * agi,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}

		ApplyDamage(damageTable)
	end
end

function modifier_scream_of_the_dead_debuff_dot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_scream_of_the_dead_debuff_dot:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow") * 0.01
end

function modifier_scream_of_the_dead_debuff_dot:GetStatusEffectName()
	return "particles/scream/axe_battle_hunger.vpcf"
end

function modifier_scream_of_the_dead_debuff_dot:StatusEffectPriority()
	return 9
end

function modifier_scream_of_the_dead_debuff_dot:IsDebuff()
	return true
end

function modifier_scream_of_the_dead_debuff_dot:IsPurgable()
	return true
end

function modifier_scream_of_the_dead_debuff_dot:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		ParticleManager:DestroyParticle(self.enemy_particle, false)
		ParticleManager:ReleaseParticleIndex(self.enemy_particle)

		-- Both modifiers are created in OnAttackStart and removed OnAttack, this is just in case shit happens...as it always tends to
		if self.deny_modifier and not self.deny_modifier:IsNull() then
			self.deny_modifier:Destroy()
		end
	end
end

function modifier_scream_of_the_dead_debuff_dot:OnDeath(keys)
	if IsServer() then
		local units_killed = 0
		if keys.attacker == self.parent then
			self.kill_count = self.kill_count + 1
		end
		if units_killed < self.kill_count then
			self:ForceRefresh()
			self.kill_count = 0
		end
	end
end

function modifier_scream_of_the_dead_debuff_dot:OnTakeDamage(keys)
	if IsServer() then
		if keys.attacker == self.parent and keys.damage > 0 then
			self.last_damage_time = GameRules:GetGameTime()
		end
	end
end