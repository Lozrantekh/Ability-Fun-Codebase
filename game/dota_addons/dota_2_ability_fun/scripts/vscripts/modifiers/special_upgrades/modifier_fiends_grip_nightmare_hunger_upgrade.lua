modifier_fiends_grip_nightmare_hunger_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_fiends_grip_nightmare_hunger_upgrade:IsHidden()
	return false
end

function modifier_fiends_grip_nightmare_hunger_upgrade:IsPurgeException()
	return false
end

function modifier_fiends_grip_nightmare_hunger_upgrade:IsPurgable()
	return false
end

function modifier_fiends_grip_nightmare_hunger_upgrade:IsPermanent()
	return true
end

function modifier_fiends_grip_nightmare_hunger_upgrade:GetTexture()
	return "bane_fiends_grip"
end

function modifier_fiends_grip_nightmare_hunger_upgrade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_fiends_grip_nightmare_hunger_upgrade:OnCreated(kv)
    if IsServer() then
        self.interval = kv.interval or 1

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_fiends_grip_nightmare_hunger_upgrade:AddCustomTransmitterData()
    return {
        interval = self.interval,
    }
end

function modifier_fiends_grip_nightmare_hunger_upgrade:HandleCustomTransmitterData( data )
    self.interval = data.interval
end

function modifier_fiends_grip_nightmare_hunger_upgrade:OnTooltip()
    return self.interval
end

function modifier_fiends_grip_nightmare_hunger_upgrade:OnAbilityFullyCast(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if not params.target then
        return
    end

    self.target = params.target

    if params.ability:GetAbilityName() ~= "bane_fiends_grip" then
        return
    end

    local unit = self:GetParent()
    local ability = params.ability

    self.brainsap = unit:FindAbilityByName("bane_brain_sap")
    self.maxTime = ability:GetSpecialValueFor("AbilityChannelTime") or 0
    self.startTime = GameRules:GetGameTime()

    if not self.brainsap or self.brainsap:GetLevel() == 0 then
        return
    end

    if self.blocked then
        return
    end

    self.blocked = true

    self:OnIntervalThink()
    self:StartIntervalThink(self.interval)
end

function modifier_fiends_grip_nightmare_hunger_upgrade:OnIntervalThink()
    if not IsServer() then
        return
    end

    if GameRules:GetGameTime() > self.startTime + self.maxTime then
        self.blocked = false
        self:StartIntervalThink(-1)
        return
    end

    if not self.target or self.target:IsNull() or not self.target:IsAlive() then
        self.blocked = false
        self:StartIntervalThink(-1)
        return
    end

    self:GetParent():SetCursorCastTarget(self.target)
    self.brainsap:OnSpellStart()
end

function modifier_fiends_grip_nightmare_hunger_upgrade:OnAbilityEndChannel(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if params.ability:GetAbilityName() ~= "bane_fiends_grip" then
        return
    end

    self:StartIntervalThink(-1)
    self.blocked = false
end