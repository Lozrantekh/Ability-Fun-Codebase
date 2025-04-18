modifier_disruptor_thunder_chance_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_disruptor_thunder_chance_dark_moon:IsHidden()
	return true
end

function modifier_disruptor_thunder_chance_dark_moon:IsPurgeException()
	return false
end

function modifier_disruptor_thunder_chance_dark_moon:IsPurgable()
	return false
end

function modifier_disruptor_thunder_chance_dark_moon:IsPermanent()
	return true
end

function modifier_disruptor_thunder_chance_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_disruptor_thunder_chance_dark_moon:OnCreated(table)
    self.chance = 35
end

function modifier_disruptor_thunder_chance_dark_moon:OnAttack(params)
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

    if params.target:IsNull() or not params.target:IsAlive() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(attacker:GetPlayerID(), "disruptor_thunder_strike", "thundered") then
        return
    end

    local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")
    if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local thunderStrike = self:GetParent():FindAbilityByName("disruptor_thunder_strike")
        if thunderStrike then
            self:GetParent():SetCursorCastTarget(params.target)
            thunderStrike:OnSpellStart()
        end
    end
end