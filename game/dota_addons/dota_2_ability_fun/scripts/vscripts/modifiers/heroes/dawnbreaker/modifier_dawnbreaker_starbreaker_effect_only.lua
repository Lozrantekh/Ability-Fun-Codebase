modifier_dawnbreaker_starbreaker_effect_only = class({})

function modifier_dawnbreaker_starbreaker_effect_only:OnCreated( kv )
	self.parent = self:GetParent()
	self.attacks = self:GetAbility():GetSpecialValueFor( "total_attacks" )
    self.swipe_radius = self:GetAbility():GetSpecialValueFor( "swipe_radius" )

	if not IsServer() then return end

	self.forward = Vector( kv.x, kv.y, 0 )
	self.ctr = 0
	local interval = self:GetDuration()/(self.attacks-1)

	-- Start interval
	self:OnIntervalThink()
	self:StartIntervalThink( interval )
end

function modifier_dawnbreaker_starbreaker_effect_only:OnIntervalThink()
	self.ctr = self.ctr + 1

	-- if stunned, destroy
	if self.parent:IsStunned() or self.ctr >= self.attacks then

        --smash
        if self.ctr == self.attacks then
            self:IncreaseLuminosityStacks(true)
        end

		self:Destroy()
		return
	end

    --swipe
    self:IncreaseLuminosityStacks(false)

	-- play effects
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_dawnbreaker_starbreaker_effect_only:IncreaseLuminosityStacks(isSmash)
    local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.swipe_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    if enemies and #enemies > 0 then
        local luminosityModifier = self.parent:FindModifierByName("modifier_dawnbreaker_luminosity_ad_ranked")
        if luminosityModifier then
            if not luminosityModifier.buff then
                luminosityModifier:IncreasePassiveStacks()
            elseif isSmash then
                luminosityModifier:RemoveBuff()
            end
        end
    end
end

-- Graphics & Animations
function modifier_dawnbreaker_starbreaker_effect_only:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_sweep_cast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_dawnbreaker_starbreaker_effect_only:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_sweep.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Fire_Wreath.Sweep"

	-- Get Data
	local forward = RotatePosition( Vector(0,0,0), QAngle( 0, -120, 0 ), self.forward )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 0, forward )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	self.parent:EmitSound(sound_cast)
end