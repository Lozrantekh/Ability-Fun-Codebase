modifier_windrunner_attack_powershot_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_windrunner_attack_powershot_upgrade:IsHidden()
	return false
end

function modifier_windrunner_attack_powershot_upgrade:IsPurgeException()
	return false
end

function modifier_windrunner_attack_powershot_upgrade:IsPurgable()
	return false
end

function modifier_windrunner_attack_powershot_upgrade:IsPermanent()
	return true
end

function modifier_windrunner_attack_powershot_upgrade:GetTexture()
	return "windrunner_powershot"
end

function modifier_windrunner_attack_powershot_upgrade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_windrunner_attack_powershot_upgrade:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_windrunner_attack_powershot_upgrade:AddCustomTransmitterData()
    return {
        chance = self.chance,
    }
end

function modifier_windrunner_attack_powershot_upgrade:HandleCustomTransmitterData( data )
    self.chance = data.chance
end

function modifier_windrunner_attack_powershot_upgrade:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    
    local attacker = params.attacker

    if attacker ~= self:GetParent() then
        return
    end

    if attacker:IsNull() or not attacker:IsAlive() then
        return
    end

    if params.target:IsNull() or not params.target:IsAlive() or params.target:IsBuilding() or params.target:IsOther() then
        return
    end

    if params.no_attack_cooldown then
		return
	end

    local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")
    if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local powershot = self:GetParent():FindAbilityByName("windrunner_powershot")

        if powershot and powershot:GetLevel() > 0 then
            self:GetParent():SetCursorPosition(params.target:GetAbsOrigin())
            powershot:OnChannelFinish(false)
        end
    end
end

function modifier_windrunner_attack_powershot_upgrade:OnTooltip()
    return self.chance
end