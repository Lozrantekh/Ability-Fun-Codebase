modifier_snapfire_cookie_mortimer_kiss_aura = class({})


function modifier_snapfire_cookie_mortimer_kiss_aura:IsHidden()
	return false
end

function modifier_snapfire_cookie_mortimer_kiss_aura:IsPurgeException()
	return true
end

function modifier_snapfire_cookie_mortimer_kiss_aura:IsStunDebuff()
	return false
end

function modifier_snapfire_cookie_mortimer_kiss_aura:IsPurgable()
	return false
end

function modifier_snapfire_cookie_mortimer_kiss_aura:GetTexture()
	return "snapfire_mortimer_kisses"
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_cookie_mortimer_kiss_aura:OnCreated( kv )
    self.slow = 0 
    self.dps = 0
    self.interval = 0

    self.mortimer = self:GetCaster():FindAbilityByName("snapfire_mortimer_kisses")
	if self.mortimer and self.mortimer:GetLevel() > 0 then
        self.slow = -self.mortimer:GetSpecialValueFor( "move_slow_pct" )
        self.dps = self.mortimer:GetSpecialValueFor( "burn_damage" )
        self.interval = self.mortimer:GetSpecialValueFor( "burn_interval" )
    else
        return
    end

	if not IsServer() then return end

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.dps*self.interval,
		damage_type = self.mortimer:GetAbilityDamageType(),
		ability = self.mortimer, --Optional.
	}

	-- Start interval
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_snapfire_cookie_mortimer_kiss_aura:OnRefresh( kv )
	
end

function modifier_snapfire_cookie_mortimer_kiss_aura:OnRemoved()
end

function modifier_snapfire_cookie_mortimer_kiss_aura:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_cookie_mortimer_kiss_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_snapfire_cookie_mortimer_kiss_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_snapfire_cookie_mortimer_kiss_aura:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )

	-- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_snapfire_cookie_mortimer_kiss_aura:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_snapfire_cookie_mortimer_kiss_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_snapfire_cookie_mortimer_kiss_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_snapfire_cookie_mortimer_kiss_aura:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end