modifier_summoned_unit_bat_upgrade_ad_2023 = class({})

function modifier_summoned_unit_bat_upgrade_ad_2023:IsPurgable()
    return false
end

function modifier_summoned_unit_bat_upgrade_ad_2023:IsPermanent()
    return true
end

function modifier_summoned_unit_bat_upgrade_ad_2023:IsHidden()
    return true
end

function modifier_summoned_unit_bat_upgrade_ad_2023:OnCreated(kv)
    if IsServer() then
        if self:GetParent():GetPlayerOwner() then
            self.heroOwner = self:GetParent():GetPlayerOwner():GetAssignedHero()

            self.bat = nil
            self.abilityName = kv.ability_name
            self.abilityPropertyName = kv.property_name

            self:SetHasCustomTransmitterData(true)
            self:UpdateBat()
        end
    end
end

function modifier_summoned_unit_bat_upgrade_ad_2023:AddCustomTransmitterData()
    return {
        bat = self.bat,
    }
end

function modifier_summoned_unit_bat_upgrade_ad_2023:HandleCustomTransmitterData( data )
    self.bat = data.bat
end

function modifier_summoned_unit_bat_upgrade_ad_2023:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_summoned_unit_bat_upgrade_ad_2023:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_UNIT_STATS_NEEDS_REFRESH 
    }
end

function modifier_summoned_unit_bat_upgrade_ad_2023:GetModifierUnitStatsNeedsRefresh()
    return 1
end

function modifier_summoned_unit_bat_upgrade_ad_2023:GetModifierBaseAttackTimeConstant()
    if self.bat then
        return self.bat
    end

    return self:GetParent():GetBaseAttackTime()
end

function modifier_summoned_unit_bat_upgrade_ad_2023:UpdateBat()
    if self.heroOwner and self.abilityName and self.abilityPropertyName then
        local ability = self.heroOwner:FindAbilityByName(self.abilityName)

        if ability then
            local bat = ability:GetSpecialValueFor(self.abilityPropertyName)

            if bat and bat > 0 then
                self.bat = bat

                self:SendBuffRefreshToClients()
            end
        end
    end
end