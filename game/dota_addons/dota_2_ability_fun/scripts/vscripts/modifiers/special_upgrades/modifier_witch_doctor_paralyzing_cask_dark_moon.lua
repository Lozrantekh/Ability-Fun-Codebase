modifier_witch_doctor_paralyzing_cask_dark_moon = class({})

function modifier_witch_doctor_paralyzing_cask_dark_moon:IsHidden()
	return false
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:IsPurgeException()
	return false
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:IsPurgable()
	return false
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:IsPermanent()
	return true
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:GetTexture()
	return "witch_doctor_paralyzing_cask"
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:OnCreated(kv)
    if IsServer() then
        self.requiredBounces = kv.bounces or 0
        self.maxAttacks = kv.maxAttacks or 0
        self.duration = kv.wardDuration or 0
        self.damage = kv.damage or 0

        self.currentBounces = 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:AddCustomTransmitterData()
    return {
        requiredBounces = self.requiredBounces,
        maxAttacks = self.maxAttacks,
        duration = self.duration,
        damage = self.damage,
    }
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:HandleCustomTransmitterData( data )
    self.requiredBounces = data.requiredBounces
    self.maxAttacks = data.maxAttacks
    self.duration = data.duration
    self.damage = data.damage
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:OnTooltip()
    return self.requiredBounces
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:OnTooltip2()
    return self.maxAttacks
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:OnAbilityFullyCast(params)
    local unit = params.unit
    local target = params.target

    if not target or target:IsNull() then
        return
    end

    if unit ~= self:GetParent() or unit:GetTeamNumber() == target:GetTeamNumber() then
        return
    end

    local isCask = (params.ability and params.ability:GetAbilityName() == "witch_doctor_paralyzing_cask")

    if not isCask then
        return
    end

    if self.currentBounces > 0 then
        self.currentBounces = 0
    end
end

function modifier_witch_doctor_paralyzing_cask_dark_moon:OnTakeDamage(params)
    local unit = params.unit
    local attacker = params.attacker
    local ability = params.inflictor

    if attacker ~= self:GetParent() or attacker:GetTeamNumber() == unit:GetTeamNumber() then
        return
    end

    if not unit or unit:IsNull() then
        return
    end

    if not ability or ability:IsNull() then
        return
    end
    
    local isCask = (params.inflictor and params.inflictor:GetAbilityName() == "witch_doctor_paralyzing_cask")

    if not isCask then
        return
    end

    self.currentBounces = self.currentBounces + 1

    if self.currentBounces >= self.requiredBounces then
        self.currentBounces = 0

        local ward = CreateUnitByName(
            "witch_doctor_death_ward_dark_moon_solo", 
            unit:GetAbsOrigin(), 
            true, 
            self:GetParent(), 
            self:GetParent(), 
            self:GetParent():GetTeamNumber()
        )

        if ward then
            ward:SetBaseDamageMin(self.damage)
            ward:SetBaseDamageMax(self.damage)
    
            local wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", PATTACH_POINT_FOLLOW, ward)
            ParticleManager:SetParticleControlEnt(wardParticle, 0, ward, PATTACH_POINT_FOLLOW, "attach_attack1", ward:GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(wardParticle, 2, ward:GetAbsOrigin())
    
            Timers:CreateTimer(self.duration, function()
                ParticleManager:DestroyParticle(wardParticle, true)
                ParticleManager:ReleaseParticleIndex(wardParticle)
                ward:ForceKill(false)
                ward:AddEffects( EF_NODRAW )
            end)
    
            ward:SetOwner(self:GetParent())
            ward:SetControllableByPlayer(self:GetParent():GetPlayerID(), true)
            ward:SetCanSellItems(false)
            ward:SetBaseAttackTime( 0.35)

            -- ward:AddNewModifier(ward, nil, "modifier_generic_unselectable", {})
            ward:AddNewModifier(ward, nil, "modifier_towers_split_attack", {maxAttacks = self.maxAttacks}) 
        end
    end
end