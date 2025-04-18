modifier_sniper_assissinate_chance_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_assissinate_chance_dark_moon:IsHidden()
	return false
end

function modifier_sniper_assissinate_chance_dark_moon:IsPurgeException()
	return false
end

function modifier_sniper_assissinate_chance_dark_moon:IsPurgable()
	return false
end

function modifier_sniper_assissinate_chance_dark_moon:IsPermanent()
	return true
end

function modifier_sniper_assissinate_chance_dark_moon:GetTexture()
    return "sniper_assassinate"
end

function modifier_sniper_assissinate_chance_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,

        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_sniper_assissinate_chance_dark_moon:OnTooltip()
    return self.chance
end

function modifier_sniper_assissinate_chance_dark_moon:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_sniper_assissinate_chance_dark_moon:AddCustomTransmitterData()
    return {
        chance = self.chance,
    }
end

function modifier_sniper_assissinate_chance_dark_moon:HandleCustomTransmitterData( data )
    self.chance = data.chance
end

function modifier_sniper_assissinate_chance_dark_moon:OnAttackLanded(params)
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

    local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")
    if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local assassinate = self:GetParent():FindAbilityByName("sniper_assassinate_ad_2023")
        if assassinate and assassinate:GetLevel() > 0 then
            self:GetParent():SetCursorCastTarget(params.target)

            assassinate:OnSpellStart(true)
        end
    end
end