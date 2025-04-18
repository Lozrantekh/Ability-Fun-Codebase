modifier_earthshaker_aftershock_chance_dark_moon = class({})

function modifier_earthshaker_aftershock_chance_dark_moon:IsHidden()
	return false
end

function modifier_earthshaker_aftershock_chance_dark_moon:IsPurgeException()
	return false
end

function modifier_earthshaker_aftershock_chance_dark_moon:IsPurgable()
	return false
end

function modifier_earthshaker_aftershock_chance_dark_moon:IsPermanent()
	return true
end

function modifier_earthshaker_aftershock_chance_dark_moon:GetTexture()
	return "earthshaker_aftershock"
end

function modifier_earthshaker_aftershock_chance_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_earthshaker_aftershock_chance_dark_moon:OnCreated(kv)
    if not IsServer() then
        return
    end

    self.needAttacks = kv.attacks or 10
    self.attacks = 0
    self.maxCast = kv.counter or 1
    self.blocked = false

    self:SetHasCustomTransmitterData(true)

    if not self:GetParent():HasAbility("fake_ability_dark_moon") then
        self.fakeAbility = self:GetParent():AddAbility("fake_ability_dark_moon")
        if self.fakeAbility then
            self.fakeAbility:SetLevel(1)
        end
    end
end

function modifier_earthshaker_aftershock_chance_dark_moon:AddCustomTransmitterData()
    return {
        needAttacks = self.needAttacks,
        maxCast = self.maxCast,
    }
end

function modifier_earthshaker_aftershock_chance_dark_moon:HandleCustomTransmitterData( data )
    self.needAttacks = data.needAttacks
    self.maxCast = data.maxCast
end

function modifier_earthshaker_aftershock_chance_dark_moon:GetModifierIncomingDamage_Percentage(params)
    if not IsServer() then return 0 end

    if params.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then
        return 0
    end

    if params.attacker == nil or params.attacker:IsNull() or not params.attacker:IsAlive() or params.attacker:IsBuilding() or params.attacker:IsOther() then
        return 0
    end

    if self:GetParent():IsNull() or not self:GetParent():IsAlive() then
        return 0
    end

    if params.attacker == self:GetParent() or params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return 0
    end

    if params.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
        return 0
    end

    if self:GetParent():PassivesDisabled() then
        return 0
    end

    if self.blocked then
        return 0
    end

    self.attacks = self.attacks + 1
    self:SetStackCount(self.attacks)
end

function modifier_earthshaker_aftershock_chance_dark_moon:OnStackCountChanged(count)
    if IsServer() then
        if self.blocked or self.stackCountReset then
            return
        end

        if self:GetStackCount() > 10 then
            self.stackCountReset = true
            self:SetStackCount(10)
        end

        if self:GetStackCount() == 10 then
            self.stackCountReset = true
            self:SetStackCount(0)

            local duration = 1.0

            if self.fakeAbility then
                if self.maxCast > 1 then
                    self.blocked = true
                end

                self.attacks = 0
                local afterShock = self:GetParent():FindAbilityByName("earthshaker_aftershock")
    
                if not afterShock or afterShock:GetLevel() == 0 then
                    self.blocked = false
                    self.stackCountReset = false
                    return
                end
    
                if afterShock:GetDuration() then
                    duration = afterShock:GetDuration()
                end
    
                local radius = afterShock:GetSpecialValueFor("aftershock_range") or 350
    
                for i = 1, self.maxCast do
                    Timers:CreateTimer(duration * (i-1), function() 
                        self.fakeAbility:CastAbility()
    
                        local nFXIndex = ParticleManager:CreateParticle( "particles/neutral_fx/ursa_thunderclap.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
                        ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, radius, radius ) )
                        ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
                        ParticleManager:ReleaseParticleIndex( nFXIndex )
                        
                        self:GetParent():EmitSound("Hellbear.Smash.Brewmaster")
                    end)
                end
            end

            if self.blocked then
                Timers:CreateTimer(duration * self.maxCast, function() 
                    self.blocked = false
                end)
            end 
        end

        self.stackCountReset = false
    end
end

function modifier_earthshaker_aftershock_chance_dark_moon:OnTooltip()
    return self.needAttacks
end

function modifier_earthshaker_aftershock_chance_dark_moon:OnTooltip2()
    return self.maxCast
end