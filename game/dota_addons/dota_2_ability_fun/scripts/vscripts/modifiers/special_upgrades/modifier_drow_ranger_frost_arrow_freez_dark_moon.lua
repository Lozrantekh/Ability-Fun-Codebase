LinkLuaModifier("modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon", "modifiers/special_upgrades/modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon", LUA_MODIFIER_MOTION_NONE)

modifier_drow_ranger_frost_arrow_freez_dark_moon = class({})

function modifier_drow_ranger_frost_arrow_freez_dark_moon:IsHidden()
	return true
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:IsPurgeException()
	return false
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:IsPurgable()
	return false
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:IsPermanent()
	return true
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:OnCreated()
    self.thinker = 0.1
    self.timeAccumulated = 0

    self.attackedUnits = {}

    if not _G._GetSpecialUpgradeValues then
        return
    end

    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"drow_ranger_frost_arrows", "frozen")

    self.stunDuration = values.stun or 1
    self.timeToFreeze = values.interval or 3
    self.timeToFreeze = self.timeToFreeze - 0.1

    self.frostArrows = nil
    if self:GetParent():FindAbilityByName("drow_ranger_frost_arrows") then
        self.frostArrows = self:GetParent():FindAbilityByName("drow_ranger_frost_arrows")
    end

end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:OnTakeDamage(params)
    local unit = params.unit
    local attacker = params.attacker

    if attacker ~= self:GetParent() or attacker:GetTeamNumber() == unit:GetTeamNumber() then
        return
    end

    if not unit or unit:IsNull() or not unit:IsAlive() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "drow_ranger_frost_arrows", "frozen") then
        return
    end


    local isFrostArrowAttack = unit:FindModifierByName("modifier_drow_ranger_frost_arrows_slow")

    if not isFrostArrowAttack then
        return
    end

    if not self.attackedUnits[unit:entindex()] then
        self.attackedUnits[unit:entindex()] = 0
    end

    if self:GetNumberOfFrostArrowedUnits() == 1 then
        self:StartIntervalThink(self.thinker)
    end
end

function modifier_drow_ranger_frost_arrow_freez_dark_moon:OnIntervalThink()
    self.timeAccumulated = self.timeAccumulated + self.thinker

    if self.timeAccumulated >= 0.5 then
        for unitIndex, time in pairs(self.attackedUnits) do
            local unit = EntIndexToHScript(unitIndex)
            if unit and not unit:IsNull() and unit:IsAlive() then
                if unit:FindModifierByName("modifier_drow_ranger_frost_arrows_slow") then
                    self.attackedUnits[unitIndex] = time + 0.5

                    if self.attackedUnits[unitIndex] >= self.timeToFreeze and self.stunDuration then
                        unit:AddNewModifier(self:GetParent(), self.frostArrows, "modifier_drow_ranger_frost_arrow_freez_debuff_dark_moon", 
                        {
                            duration = self.stunDuration
                        })

                        --set this to -2 to avoid next stun after first one (2s cooldown to start counting time to freeze again).
                        self.attackedUnits[unitIndex] = -2
                    end

                    --clear units with set to -2 that have no modifier applied
                elseif self.attackedUnits[unitIndex] < 0 then
                    self.attackedUnits[unitIndex] = time + 0.5
                end 
            end
        end

        self.timeAccumulated = 0
    end

    for unitIndex, time in pairs(self.attackedUnits) do
        local unit = EntIndexToHScript(unitIndex)
        if not unit or unit:IsNull() or not unit:IsAlive() then
            self.attackedUnits[unitIndex] = nil
        elseif unit and not unit:FindModifierByName("modifier_drow_ranger_frost_arrows_slow") and self.attackedUnits[unitIndex] >= 0 then
            self.attackedUnits[unitIndex] = nil
        end
    end

    if self:GetNumberOfFrostArrowedUnits() == 0 then
        self:StartIntervalThink(-1)
    end
end


function modifier_drow_ranger_frost_arrow_freez_dark_moon:GetNumberOfFrostArrowedUnits()
    local counter = 0
    for k, v in pairs(self.attackedUnits) do
        if k~= nil and v ~= nil then
            counter = counter + 1
        end
    end

    return counter
end