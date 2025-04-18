modifier_pudge_dismember_hooks_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_dismember_hooks_upgrade:IsHidden()
	return false
end

function modifier_pudge_dismember_hooks_upgrade:IsPurgeException()
	return false
end

function modifier_pudge_dismember_hooks_upgrade:IsPurgable()
	return false
end

function modifier_pudge_dismember_hooks_upgrade:IsPermanent()
	return true
end

function modifier_pudge_dismember_hooks_upgrade:GetTexture()
	return "pudge_dismember"
end

function modifier_pudge_dismember_hooks_upgrade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
    }
end

function modifier_pudge_dismember_hooks_upgrade:OnCreated(kv)
    if IsServer() then
    end
end

-- function modifier_pudge_dismember_hooks_upgrade:AddCustomTransmitterData()
--     return {
--         chance = self.chance,
--     }
-- end

-- function modifier_pudge_dismember_hooks_upgrade:HandleCustomTransmitterData( data )
--     self.chance = data.chance
-- end

function modifier_pudge_dismember_hooks_upgrade:OnAbilityFullyCast(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if params.ability:GetAbilityName() ~= "pudge_dismember" then
        return
    end

    local unit = self:GetParent()
    local ability = params.ability

    self.hook = unit:FindAbilityByName("pudge_meat_hook_dark_moon")
    self.maxTime = ability:GetSpecialValueFor("AbilityChannelTime") or 0
    self.startTime = GameRules:GetGameTime()

    if not self.hook or self.hook:GetLevel() == 0 then
        return
    end

    if self.blocked then
        return
    end

    self.blocked = true

    self:OnIntervalThink()
    self:StartIntervalThink(0.3)
end

function modifier_pudge_dismember_hooks_upgrade:OnIntervalThink()
    if not IsServer() then
        return
    end

    if GameRules:GetGameTime() > self.startTime + self.maxTime then
        self.blocked = false
        self:StartIntervalThink(-1)
        return
    end

    
    local randomVector = RandomVector(350)
    self:GetParent():SetCursorPosition(self:GetParent():GetAbsOrigin() + randomVector)

    self.hook:OnSpellStart(self:GetParent():GetAbsOrigin() + randomVector, true)
end

function modifier_pudge_dismember_hooks_upgrade:OnAbilityEndChannel(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if params.ability:GetAbilityName() ~= "pudge_dismember" then
        return
    end

    self:StartIntervalThink(-1)
    self.blocked = false
end