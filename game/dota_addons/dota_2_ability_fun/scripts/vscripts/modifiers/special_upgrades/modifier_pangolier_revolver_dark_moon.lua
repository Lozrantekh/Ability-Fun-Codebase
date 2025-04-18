modifier_pangolier_revolver_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pangolier_revolver_dark_moon:IsHidden()
	return true
end

function modifier_pangolier_revolver_dark_moon:IsPurgeException()
	return false
end

function modifier_pangolier_revolver_dark_moon:IsPurgable()
	return false
end

function modifier_pangolier_revolver_dark_moon:IsPermanent()
	return true
end

function modifier_pangolier_revolver_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE
    }
end

function modifier_pangolier_revolver_dark_moon:OnCreated(table)
    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"pangolier_swashbuckle", "revolver")
    if not values or not values.damage then
        return
    end

    self.damage = values.damage
end

function modifier_pangolier_revolver_dark_moon:OnTakeDamage(params)
    local unit = params.unit
    local attacker = params.attacker

    if attacker ~= self:GetParent() or attacker:GetTeamNumber() == unit:GetTeamNumber() then
        return
    end

    if not unit or unit:IsNull() or not unit:IsAlive() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "pangolier_swashbuckle", "revolver") then
        return
    end

    local isSwashbuckle = (params.inflictor and params.inflictor:GetAbilityName() == "pangolier_swashbuckle")

    if not isSwashbuckle then
        return
    end

    if not _G._GetSpecialUpgradeValues then
        return
    end

    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"pangolier_swashbuckle", "revolver")
    if not values or not values.damage then
        return
    end

    self.reducedAttackDmg = true
	self:GetParent():PerformAttack( unit, false, false, true, false, false, false, true )
    self.reducedAttackDmg = false
end


function modifier_pangolier_revolver_dark_moon:GetModifierOverrideAttackDamage()
    if self.reducedAttackDmg then
        return self:GetParent():GetAverageTrueAttackDamage(nil) * self.damage/100
    end
end

