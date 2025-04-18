modifier_zeus_bolt_counter_attack_ad_2023 = class({})

function modifier_zeus_bolt_counter_attack_ad_2023:IsHidden()
	return false
end

function modifier_zeus_bolt_counter_attack_ad_2023:IsPurgeException()
	return false
end

function modifier_zeus_bolt_counter_attack_ad_2023:IsPurgable()
	return false
end

function modifier_zeus_bolt_counter_attack_ad_2023:IsPermanent()
	return true
end

function modifier_zeus_bolt_counter_attack_ad_2023:DestroyOnExpire()
	return false
end

function modifier_zeus_bolt_counter_attack_ad_2023:GetTexture()
	return "zuus_lightning_bolt"
end

function modifier_zeus_bolt_counter_attack_ad_2023:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_zeus_bolt_counter_attack_ad_2023:OnCreated(kv)
    if not IsServer() then
        return
    end

    self.cooldown = kv.cooldown or 5
    self.radius = kv.radius or 350
    self.aoeRadius = kv.aoe_radius or 200

    self.ignoredUnits = {
        npc_dota_crate = true,
        npc_dota_vase = true,
    }

    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.25)
end

function modifier_zeus_bolt_counter_attack_ad_2023:AddCustomTransmitterData()
    return {
        cooldown = self.cooldown,
        radius = self.radius,
    }
end

function modifier_zeus_bolt_counter_attack_ad_2023:HandleCustomTransmitterData( data )
    self.cooldown = data.cooldown
    self.radius = data.radius
end

function modifier_zeus_bolt_counter_attack_ad_2023:OnIntervalThink()
    if self:GetRemainingTime() > 0 then
        if self.ringParticleFX then
            ParticleManager:DestroyParticle(self.ringParticleFX, false)
            self.ringParticleFX = nil
        end

        return
    else
        self:SetDuration(-1, true)
    end

    if not self.bolt then
        local bolt = self:GetParent():FindAbilityByName("zuus_lightning_bolt")

        if bolt and bolt:GetLevel() > 0 then
            self.bolt = bolt
        end
    end

    if not self.bolt then
        return
    end

    if not self.ringParticleFX then
        self.ringParticleFX = ParticleManager:CreateParticle("particles/heroes/zuus/bolt_upgrade_radius.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.ringParticleFX, 1, Vector(self.radius, 0, 0))
    end

    -- potential Elite creeps
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(), 
        self:GetParent():GetOrigin(), 
        nil, 
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
        FIND_CLOSEST, 
        false 
    )

    local enemiesToBolt = {
        elite = {},
        base = {}
    }

    for _, enemy in pairs(enemies) do
        if enemy and enemy:IsAlive() and not enemy:IsInvulnerable() and not self.ignoredUnits[enemy:GetUnitName()]then
            if enemy:IsRealHero() then
                table.insert(enemiesToBolt["elite"], enemy)
            else
                table.insert(enemiesToBolt["base"], enemy)
            end

            --1 elite creep is enough
            if #enemiesToBolt["elite"] > 0 then
                break
            end
        end
    end

    local target = nil

    --first link Elite creeps
    if #enemiesToBolt["elite"] > 0 then
        target = enemiesToBolt["elite"][1]
    elseif #enemiesToBolt["base"] > 0 then
        target = enemiesToBolt["base"][1]
    end

    if target then
        self:CastLightningBolt(target, false)

        local extraEnemies = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(), 
            target:GetAbsOrigin(), 
            nil, 
            self.aoeRadius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
            FIND_CLOSEST, 
            false 
        )

        for _, enemy in pairs(extraEnemies) do
            if enemy and not enemy:IsNull() and not enemy:IsInvulnerable() and not self.ignoredUnits[enemy:GetUnitName()] and enemy ~= target then
                self:CastLightningBolt(enemy, true)
            end
        end
    end
end

function modifier_zeus_bolt_counter_attack_ad_2023:CastLightningBolt(target, isExtraTarget)
    if not self.bolt then
        return
    end

    local damage = self.bolt:GetAbilityDamage()

    if isExtraTarget then
        damage = damage * 0.5
    end

    local damageInfo = 
    {
        victim = target,
        attacker = self:GetParent(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.bolt,
    }

    ApplyDamage( damageInfo )

    local vecStartPos = target:GetAbsOrigin()

    if not isExtraTarget then
        vecStartPos.z = vecStartPos.z + 2000
    end

	local nFXIndex  = ParticleManager:CreateParticle( "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, vecStartPos )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
    
	ParticleManager:ReleaseParticleIndex( nFXIndex )

    if not isExtraTarget then
        EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Zeus.Counter.Bolt", self:GetParent())

        self:SetDuration(self.cooldown, true)
    end
end

function modifier_zeus_bolt_counter_attack_ad_2023:OnTooltip()
    return self.cooldown
end

function modifier_zeus_bolt_counter_attack_ad_2023:OnTooltip2()
    return self.radius
end
