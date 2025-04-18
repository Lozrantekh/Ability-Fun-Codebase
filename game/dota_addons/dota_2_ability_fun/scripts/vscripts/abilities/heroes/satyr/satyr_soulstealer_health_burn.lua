if satyr_soulstealer_health_burn == nil then
    satyr_soulstealer_health_burn = class({})
end

--------------------------------------------------------------------------------

function satyr_soulstealer_health_burn:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local float_multiplier = self:GetSpecialValueFor("str_multiplier")
	local burn = self:GetSpecialValueFor("burn_amount")

    if target:TriggerSpellAbsorb(self) then return end

    EmitSoundOn("Hero_NyxAssassin.ManaBurn.Cast", caster)

    EmitSoundOn("Hero_NyxAssassin.ManaBurn.Target", target)

    local fx = ParticleManager:CreateParticle("particles/healthburn/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(fx)   
	local str = 0
	if target:IsHero() or target:IsIllusion() then
		str = target:GetStrength()
	end
    local damage = burn + str * float_multiplier

    local damageTable = {
        victim = target,
        attacker = caster, 
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self
    }

    ApplyDamage(damageTable)
end

