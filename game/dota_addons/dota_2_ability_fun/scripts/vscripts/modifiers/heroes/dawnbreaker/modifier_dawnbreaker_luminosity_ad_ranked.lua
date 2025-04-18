modifier_dawnbreaker_luminosity_ad_ranked = class({})

--------------------------------------------------------------------------------

modifier_dawnbreaker_luminosity_ad_ranked.blockedAbilities = {
    dawnbreaker_fire_wreath = true,

    -- in original AD these spells are not blocked
    -- tidehunter_anchor_smash = true,
    -- monkey_king_boundless_strike = true,
    -- pangolier_swashbuckle = true,
}

function modifier_dawnbreaker_luminosity_ad_ranked:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_dawnbreaker_luminosity_ad_ranked:IsDebuff()
	return false
end

function modifier_dawnbreaker_luminosity_ad_ranked:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_dawnbreaker_luminosity_ad_ranked:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.requiresAttacks = self:GetAbility():GetSpecialValueFor( "attack_count" )
    self.heal = self:GetAbility():GetSpecialValueFor( "heal_pct" )
	self.radius = self:GetAbility():GetSpecialValueFor( "heal_radius" )
	self.crit = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.allyheal = self:GetAbility():GetSpecialValueFor( "allied_healing_pct" )
	self.creepheal = self:GetAbility():GetSpecialValueFor( "heal_from_creeps" )

    if not kv.refresh then
        self.buff = false
    end
end

function modifier_dawnbreaker_luminosity_ad_ranked:OnRefresh( kv )
	self:OnCreated( {refresh = 1} )
end

function modifier_dawnbreaker_luminosity_ad_ranked:OnRemoved()
end

function modifier_dawnbreaker_luminosity_ad_ranked:OnDestroy()
end

--------------------------------------------------------------------------------
function modifier_dawnbreaker_luminosity_ad_ranked:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}

	return funcs
end

function modifier_dawnbreaker_luminosity_ad_ranked:GetModifierProcAttack_Feedback( params )
    if not IsServer() then
        return
    end

    if self.parent:PassivesDisabled() then return end

    --Dawnbreaker Q will add stacks
    if self.parent:HasModifier("modifier_dawnbreaker_fire_wreath_caster") then
        return
    end

    if params.inflictor and self.blockedAbilities[params.inflictor:GetAbilityName()] then
        return
    end

    local hTarget = params.target

    if not hTarget or hTarget:IsBuilding() or hTarget:IsOther() or self:GetParent():GetTeamNumber() == hTarget:GetTeamNumber() then
        return
    end

    if not self.buff then
        self:IncreasePassiveStacks()
    else
        -- calculate heal
        local heal = params.damage * self.heal/100
        if params.target:IsCreep() then
            heal = heal * self.creepheal/100
        end

        -- heal self
        self.parent:Heal( heal, self.ability )

        -- find allies
        local allies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.parent:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        -- set allied heal
        local allyHeal = heal * self.allyheal/100

        for _,ally in pairs(allies) do
            if ally ~= self.parent and ally:IsAlive() then
                ally:Heal( allyHeal, self.ability )
                self:PlayEffects2( params.target, ally )

                SendOverheadEventMessage(
                    nil,
                    OVERHEAD_ALERT_HEAL,
                    ally,
                    allyHeal,
                    self.parent:GetPlayerOwner()
			    )
            end
        end

        -- play effects
        self:PlayEffects2( params.target, self.parent )

        params.target:EmitSound("Hero_Dawnbreaker.Luminosity.Strike")

        -- overhead heal info
		SendOverheadEventMessage(
			nil,
			OVERHEAD_ALERT_HEAL,
			self.parent,
			heal,
			self.parent:GetPlayerOwner()
		)

        self:RemoveBuff()
    end
end

function modifier_dawnbreaker_luminosity_ad_ranked:GetModifierPreAttack_CriticalStrike()
	if IsServer() and self.buff then
        return self.crit
    end
end

function modifier_dawnbreaker_luminosity_ad_ranked:IncreasePassiveStacks()
    if self:GetStackCount() > self.requiresAttacks then return end

    if self:GetStackCount() < self.requiresAttacks then
        self:IncrementStackCount()
    end

    if self:GetStackCount() == self.requiresAttacks then
        self.buff = true
        self:PlayEffects1()
    end
end

-- Graphics & Animations
function modifier_dawnbreaker_luminosity_ad_ranked:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity_attack_buff.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Luminosity.PowerUp"

	-- Create Particle
	self.buffParticle = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	ParticleManager:SetParticleControlEnt(
		self.buffParticle,
		1,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		self.buffParticle,
		2,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- Create Sound
    self.parent:EmitSound(sound_cast)
end

function modifier_dawnbreaker_luminosity_ad_ranked:PlayEffects2( target, ally )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf"
	local sound_target = "Hero_Dawnbreaker.Luminosity.Heal"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, ally )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		ally,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    ally:EmitSound(sound_target)
end

function modifier_dawnbreaker_luminosity_ad_ranked:RemoveBuff()
    if IsServer() then
        self.buff = false
        self:SetStackCount(0)

        if self.buffParticle then
            ParticleManager:DestroyParticle(self.buffParticle, false)
            self.buffParticle = nil
        end
    end
end