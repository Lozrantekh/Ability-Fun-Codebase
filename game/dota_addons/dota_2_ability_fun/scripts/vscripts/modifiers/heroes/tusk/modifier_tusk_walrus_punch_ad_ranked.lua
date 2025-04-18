modifier_tusk_walrus_punch_ad_ranked = class({})

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:OnCreated( kv )
	if IsServer() then
		self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
		self.airTime = self:GetAbility():GetSpecialValueFor( "air_time" )
		self.knockback_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )

		self.abilityUsingReserved = false
		self.iProcAttackRecords = {}

		self:RerollPassiveTalentProc()
	end
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:OnRefresh( kv )
	self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
	self.knockback_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}

	return funcs
end

function modifier_tusk_walrus_punch_ad_ranked:RerollPassiveTalentProc()
	if not self.tuskTalent then
		self.tuskTalent = self:GetParent():FindAbilityByName( "special_bonus_unique_tusk_4" )
	end

	if self.tuskTalent and self.tuskTalent:GetLevel() > 0 then
		local fTalentChance = self.tuskTalent:GetSpecialValueFor( "value" )

		self.isTalentProc = RollPseudoRandomPercentage( math.floor( fTalentChance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent() )
	end
end

function modifier_tusk_walrus_punch_ad_ranked:OnAttackRecordDestroy( params )
	if IsServer() then
		local hAttacker = params.attacker
		local hTarget = params.target

        if hAttacker == nil or hAttacker ~= self:GetParent() or hTarget == nil then
			return 0
		end

		for index, attackData in ipairs(self.iProcAttackRecords) do
            if attackData["record"] and attackData["record"] == params.record then

				if attackData["ability_reserved"] then
					self.abilityUsingReserved = false
				end
				
				table.remove(self.iProcAttackRecords, index)
				break
            end
        end
	end
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:OnAttackLanded( params )
	if IsServer() then
		local hAttacker = params.attacker
		local hTarget = params.target
		local hAbility = self:GetAbility()

        if hAttacker == nil or hAttacker ~= self:GetParent() or hTarget == nil then
			return
		end

		if hTarget:IsInvulnerable() or hTarget:IsBuilding() or hTarget:IsOther() or hTarget:GetTeamNumber() == hAttacker:GetTeamNumber() then
			return
		end

		local isWalrusPunch = false
		local isTalentProc = false

        for _, attackData in ipairs(self.iProcAttackRecords) do
            if attackData["record"] and attackData["record"] == params.record then
                isWalrusPunch = true

				if attackData["is_talent_proc"] then
                    isTalentProc = true
                end

                break
            end
        end

        if not isWalrusPunch then
			return
		end

        if not isTalentProc and hAbility and hAbility:IsFullyCastable() then
			hAbility:CastAbility()
			self.abilityUsingReserved = false
        end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, hAttacker );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_attack2", hAttacker:GetAbsOrigin(), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, hAttacker, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hAttacker:GetAbsOrigin(), true );
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		local nFXIndexB = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_hand.vpcf", PATTACH_CUSTOMORIGIN, hAttacker );
		ParticleManager:SetParticleControlEnt( nFXIndexB, 1, hAttacker, PATTACH_POINT_FOLLOW, "attach_attack2", hAttacker:GetAbsOrigin(), true );
		ParticleManager:SetParticleControlEnt( nFXIndexB, 2, hAttacker, PATTACH_POINT_FOLLOW, "attach_hitloc", hAttacker:GetAbsOrigin(), true );
		ParticleManager:ReleaseParticleIndex( nFXIndexB )

		StopSoundOn( "Hero_Tusk.WalrusPunch.Cast", hAttacker )
		EmitSoundOn( "Hero_Tusk.WalrusPunch.Target", hTarget )
		self:GetAbility():SpeakAbilityConcept( 18 )

		local kv =
		{
			duration = self.knockback_duration,
			source_ent_index = self:GetCaster():entindex()
		}

		hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_tusk_walrus_punch_slow", kv )

		kv =
		{
			duration = self.airTime,
			source_ent_index = self:GetCaster():entindex()
		}

		hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_tusk_walrus_punch_air_time", kv )
	end

	return 0
end
--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		local hTarget = params.target
		local hAbility = self:GetAbility()
		local isWalrusPunch = false

		if hTarget and not hTarget:IsInvulnerable() and not hTarget:IsBuilding() and not hTarget:IsOther() 
			and hTarget:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then

			local canUseAbility = false

			if not self.abilityUsingReserved and hAbility and (self:GetParent():GetCurrentActiveAbility() == hAbility or hAbility:GetAutoCastState()) and 
				hAbility:IsFullyCastable() and not self:GetParent():IsSilenced() 
			then
				canUseAbility = true
			end
	
			if self.isTalentProc or canUseAbility then
				local isAttackReservedAbility = false

				if not self.isTalentProc and not self.abilityUsingReserved then
					self.abilityUsingReserved = true
					isAttackReservedAbility = true
				end
		
				isWalrusPunch = true
				table.insert( self.iProcAttackRecords, {record = params.record, is_talent_proc = self.isTalentProc, ability_reserved = isAttackReservedAbility} )
		
				EmitSoundOn( "Hero_Tusk.WalrusPunch.Cast", self:GetParent() )
				self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_4 )
			end		
		end

		self:RerollPassiveTalentProc()
		
		if isWalrusPunch then
			self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )

			local hTalent = self:GetCaster():FindAbilityByName( "special_bonus_unique_tusk" )

			if hTalent and hTalent:GetLevel() > 0 then
				self.crit_multiplier = self.crit_multiplier + hTalent:GetSpecialValueFor( "value" )
			end
	
			return self.crit_multiplier
		end
	end

	return 0
end

--------------------------------------------------------------------------------

function modifier_tusk_walrus_punch_ad_ranked:CheckState()
	local state = {}

	if IsServer() then

		local ability = self:GetAbility()
		local isWalrusPunch = self.isTalentProc or ((self:GetParent():GetCurrentActiveAbility() == ability or ability:GetAutoCastState()) and 
							ability:IsFullyCastable() and not self:GetParent():IsSilenced())

		state =
		{
			[MODIFIER_STATE_CANNOT_MISS] = isWalrusPunch,
		}

		self.lastState = isWalrusPunch
	end

	return state
end

--------------------------------------------------------------------------------