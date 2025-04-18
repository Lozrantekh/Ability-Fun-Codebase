modifier_ogre_magi_multicast_proc_ad_ranked = class({})

--------------------------------------------------------------------------------

modifier_ogre_magi_multicast_proc_ad_ranked.specialRequirements = {
	enigma_demonic_conversion = {
		max_unit_level = 4,
		target_type = DOTA_UNIT_TARGET_BASIC,
		target_flags = DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	},

	alchemist_unstable_concoction_throw = {
		required_start_other_ability = "alchemist_unstable_concoction"
	},

	earth_spirit_boulder_smash = {
		required_full_cast = true
	}
}

function modifier_ogre_magi_multicast_proc_ad_ranked:IsHidden()
	return false
end

function modifier_ogre_magi_multicast_proc_ad_ranked:IsDebuff()
	return false
end

function modifier_ogre_magi_multicast_proc_ad_ranked:IsStunDebuff()
	return false
end

function modifier_ogre_magi_multicast_proc_ad_ranked:IsPurgable()
	return true
end

function modifier_ogre_magi_multicast_proc_ad_ranked:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ogre_magi_multicast_proc_ad_ranked:OnCreated( kv )
	if not IsServer() then return end

	self.caster = self:GetParent()

	self.playerID = -1
	if self:GetParent():IsRealHero() then
		self.playerID = self:GetParent():GetPlayerID() or -1
	end

    if not kv.ability then
		self:Destroy()
        return
    end
	self.ability = EntIndexToHScript( kv.ability )
	
	if kv.target then
		self.target = EntIndexToHScript( kv.target )
	end

	if not self.ability or self.ability:IsNull() then
		self:Destroy()
		return
	end

	self.abilityInfo = self.specialRequirements[self.ability:GetAbilityName()] or {}

	self.multicasts = kv.multi_casts or 0
	self.delay = kv.delay or 0
	self.singleTarget = kv.single_target == 1
	self.buffer_range = kv.buff_range or 0

	-- set stack count
	self:SetStackCount( self.multicasts )

	-- init multicast
	self.casts = 0
	if self.multicasts == 0 then
		-- no multicast if just 0
		self:Destroy()
		return
	end
	
	if kv.target then
		-- keep a table of targeted units
		self.targets = {}
		self.targets[self.target] = true


		-- get cast range
		self.radius = self.ability:GetEffectiveCastRange( self.target:GetAbsOrigin(), self.target ) + self.buffer_range
	
		-- get unit filters
		-- only target the same team as original target, even if the ability can cast on both team
		self.target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY

		if self.target:GetTeamNumber()~=self.caster:GetTeamNumber() then
			self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
		end
	else
		local hero = PlayerResource:GetSelectedHeroEntity(self.playerID) 
		self.radius = self.caster:GetAbsOrigin() - hero:GetCursorPosition() + self.buffer_range
		self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	-- if custom, findunitsinradius won't work
	self.target_type = self.ability:GetAbilityTargetType()
	if self.target_type == DOTA_UNIT_TARGET_CUSTOM or self.target_type == DOTA_UNIT_TARGET_OTHER then
		if self.abilityInfo["target_type"] then
			self.target_type = self.abilityInfo["target_type"]
		else
			self.target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
		end
	end

	-- only check for magic immunity piercing abilities
	self.target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	if bit.band( self.ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES ) ~= 0 then
		self.target_flags = self.target_flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	if self.abilityInfo["target_flags"] then
		self.target_flags = self.target_flags + self.abilityInfo["target_flags"]
	end
	
	-- Create Sound
	local sound = math.min( self.multicasts, 3 )
	local sound_cast = "Hero_OgreMagi.Fireblast.x" .. sound
	if sound > 0 then
		self.caster:EmitSound(sound_cast)
	end

	-- Start interval
	self:StartIntervalThink( self.delay )
end

--------------------------------------------------------------------------------
function modifier_ogre_magi_multicast_proc_ad_ranked:OnIntervalThink()
	-- increment count
	self.casts = self.casts + 1
	if self.casts > self.multicasts or self.ability:IsNull() then
		self:StartIntervalThink( -1 )
		self:Destroy()
		return
	end

	local multAb
	local notarget = false
	local pos
	--verify if ability is unit target
    if bit.band( self.ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_HERO ) == 0 and
		bit.band( self.ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_BASIC ) == 0 and
		bit.band( self.ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_CREEP ) == 0 and
		bit.band( self.ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_CUSTOM ) == 0 
	then
        notarget = true
    end

	local isTheSameTarget = false
	if self.target and not self.target:IsNull() and self.target:IsAlive() and 
		(self.ability:GetAbilityName() == "ogre_magi_fireblast" or self.ability:GetAbilityName() == "ogre_magi_unrefined_fireblast") 
	then
		isTheSameTarget = true
	end

	local target = nil

	if isTheSameTarget then
		target = self.target
	elseif notarget == true then
		local hero = PlayerResource:GetSelectedHeroEntity(self.playerID) 
		multAb = hero:FindAbilityByName(self.ability:GetAbilityName())
		multAb:SetLevel(self.ability:GetLevel())
		pos = hero:GetCursorPosition()
	else
		-- find valid targets
		local units = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.caster:GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			self.target_team,	-- int, team filter
			self.target_type,	-- int, type filter
			self.target_flags,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if not units or #units == 0 then
			self:Destroy()
			return
		end

		-- select valid target
		for _,unit in pairs(units) do
			-- check filter
			local filter = false
			if self.ability.CastFilterResultTarget then -- for customs
				filter = self.ability:CastFilterResultTarget( unit ) == UF_SUCCESS
			else
				filter = self:CustomAbilityCastFilter(unit)
			end

			if filter then
				target = unit
				break
			end
		end
	end

	-- if no one there or dead or linken
	if not target or target:IsNull() or not target:IsAlive() and notarget == false then
		return
	end

	-- cast spell
	if self.abilityInfo["required_start_other_ability"] then
		local ability = self.caster:FindAbilityByName(self.abilityInfo["required_start_other_ability"])

		if ability then
			ability:OnSpellStart()
		end
	end

	if notarget == true then
		if not self.abilityInfo["required_full_cast"] then
			local currentAbilityLevel = self.ability:GetLevel()
			self.caster:CastAbilityOnPosition(pos, multAb, -1)

			local currentCharges = nil

			if self.ability:IsItem() then
				currentCharges = self.ability:GetCurrentCharges()
			else
				currentCharges = self.ability:GetCurrentAbilityCharges()
			end
		
			local maxCharges = self.ability:GetMaxAbilityCharges(self.ability:GetLevel())

			if maxCharges > 0 and currentCharges and currentCharges == 0 then
				if self.ability:IsItem() then
					self.ability:SetCurrentCharges(1)
				else
					self.ability:SetCurrentAbilityCharges(1)
				end
			end

			self.ability:OnSpellStart()
		else
			local casterMana = self.caster:GetMana() or 0
			local manaCost = self.ability:GetEffectiveManaCost(self.ability:GetLevel())
	
			self.ability:EndCooldown()
	
			local refundMana = false
			if casterMana < manaCost then
				local missingMana = manaCost - casterMana
				self.caster:GiveMana(missingMana)
			else
				refundMana = true
			end
	
			self.caster:CastAbilityOnPosition(pos, multAb, -1)
	
			if refundMana then
				self.ability:RefundManaCost()
			end
		end
	else
		if not self.abilityInfo["required_full_cast"] then
			self.caster:SetCursorCastTarget( target )

			local currentCharges = nil

			if self.ability:IsItem() then
				currentCharges = self.ability:GetCurrentCharges()
			else
				currentCharges = self.ability:GetCurrentAbilityCharges()
			end
		
			local maxCharges = self.ability:GetMaxAbilityCharges(self.ability:GetLevel())

			if maxCharges > 0 and currentCharges and currentCharges == 0 then
				if self.ability:IsItem() then
					self.ability:SetCurrentCharges(1)
				else
					self.ability:SetCurrentAbilityCharges(1)
				end
			end

			self.ability:OnSpellStart()
		else
			local casterMana = self.caster:GetMana() or 0
			local manaCost = self.ability:GetEffectiveManaCost(self.ability:GetLevel())
	
			self.ability:EndCooldown()
	
			local refundMana = false
			if casterMana < manaCost then
				local missingMana = manaCost - casterMana
				self.caster:GiveMana(missingMana)
			else
				refundMana = true
			end
	
			self:GetParent():CastAbilityOnTarget(target, self.ability, self.playerID)
	
			if refundMana then
				self.ability:RefundManaCost()
			end
		end
	end

	-- play effects
	self:PlayEffects( self.casts + 1)
end

function modifier_ogre_magi_multicast_proc_ad_ranked:CustomAbilityCastFilter(unit)
	if self.abilityInfo["max_unit_level"] then
		if unit:GetLevel() > self.abilityInfo["max_unit_level"] then
			return false
		end
	end

	return true
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ogre_magi_multicast_proc_ad_ranked:PlayEffects( value )
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"

	local counter_speed = 2
	if value == self.multicasts then
		counter_speed = 0.5
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self.caster )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( value, counter_speed, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

end