modifier_snapfire_cookie_mortimer_kiss_thinker = class({})

function modifier_snapfire_cookie_mortimer_kiss_thinker:OnCreated( kv )
	self.radius = 0 
	self.linger = 0
	
	self.mortimer = self:GetCaster():FindAbilityByName("snapfire_mortimer_kisses")
	if self.mortimer and self.mortimer:GetLevel() > 0 then
		self.radius = self.mortimer:GetSpecialValueFor( "impact_radius" )
		self.linger = self.mortimer:GetSpecialValueFor( "burn_linger_duration" )
	end

	if not IsServer() then
		return
	end

	self:PlayEffects(self:GetParent():GetAbsOrigin())
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:OnRemoved()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_snapfire_cookie_mortimer_kiss_thinker:IsAura()
	return true
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:GetModifierAura()
	return "modifier_snapfire_cookie_mortimer_kiss_aura"
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:GetAuraRadius()
	return self.radius
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:GetAuraDuration()
	return self.linger
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_snapfire_cookie_mortimer_kiss_thinker:PlayEffects( loc )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( loc, sound_cast, self:GetCaster() )
end