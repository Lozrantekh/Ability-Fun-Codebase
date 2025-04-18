modifier_spirit_bear_upgrades_ad_2023 = class({})

function modifier_spirit_bear_upgrades_ad_2023:IsPurgable()
    return false
end

function modifier_spirit_bear_upgrades_ad_2023:IsPermanent()
    return true
end

function modifier_spirit_bear_upgrades_ad_2023:IsHidden()
    return true
end

function modifier_spirit_bear_upgrades_ad_2023:OnCreated(kv)
    self.hpBonus = 0
    
    if IsServer() then

        if self:GetParent():GetPlayerOwner() then
            self.heroOwner = self:GetParent():GetPlayerOwner():GetAssignedHero()
        end
    end
end

function modifier_spirit_bear_upgrades_ad_2023:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_spirit_bear_upgrades_ad_2023:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_UNIT_STATS_NEEDS_REFRESH 
    }
end

function modifier_spirit_bear_upgrades_ad_2023:GetModifierUnitStatsNeedsRefresh()
    return 1
end

function modifier_spirit_bear_upgrades_ad_2023:GetModifierHealthBonus()
    if IsServer() and self.hpBonus then
        return self.hpBonus
    end

    return 0
end

function modifier_spirit_bear_upgrades_ad_2023:UpdateSpiritBearHpAndArmor()
    if self.heroOwner then
        local ability = self.heroOwner:FindAbilityByName("lone_druid_spirit_bear")

        if ability then
            local ownerUpgradeModifier = self.heroOwner:FindModifierByName("modifier_ability_value_upgrades_sb_2023")

            if ownerUpgradeModifier and ownerUpgradeModifier.GetTotalBonusForAbilityProperty then
                local hpBonus = ownerUpgradeModifier:GetTotalBonusForAbilityProperty("lone_druid_spirit_bear", "bear_hp")
                local armorBonus = ownerUpgradeModifier:GetTotalBonusForAbilityProperty("lone_druid_spirit_bear", "bear_armor")

                if hpBonus and hpBonus > 0 then
                    self.hpBonus = hpBonus
                end
    
                if armorBonus and armorBonus > 0 then
                    local baseArmor = ability:GetLevelSpecialValueNoOverride("bear_armor", ability:GetLevel() - 1)
                    baseArmor = baseArmor + armorBonus
                
                    self:GetParent():SetPhysicalArmorBaseValue(math.floor(baseArmor + 0.5))
                end	

                self:GetParent():CalculateStatBonus(true)
            end
        end
    end
end