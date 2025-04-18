modifier_juggernaut_cd_omnislash_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_juggernaut_cd_omnislash_dark_moon:IsHidden()
	return false
end

function modifier_juggernaut_cd_omnislash_dark_moon:IsPurgeException()
	return false
end

function modifier_juggernaut_cd_omnislash_dark_moon:IsPurgable()
	return false
end

function modifier_juggernaut_cd_omnislash_dark_moon:IsPermanent()
	return true
end

function modifier_juggernaut_cd_omnislash_dark_moon:GetTexture()
	return "juggernaut_omni_slash"
end

function modifier_juggernaut_cd_omnislash_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PRE_ATTACK,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_juggernaut_cd_omnislash_dark_moon:OnCreated(kv)
    if IsServer() then
        self.cooldown_reduction = kv.cooldown_reduction or 1

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_juggernaut_cd_omnislash_dark_moon:AddCustomTransmitterData()
    return {
        cooldown_reduction = self.cooldown_reduction,
    }
end

function modifier_juggernaut_cd_omnislash_dark_moon:HandleCustomTransmitterData( data )
    self.cooldown_reduction = data.cooldown_reduction
end

function modifier_juggernaut_cd_omnislash_dark_moon:GetModifierPreAttack(params)
    if not IsServer() then
        return
    end

    if self:GetParent():HasModifier("modifier_juggernaut_omnislash") then
        local omniSlash = self:GetParent():FindAbilityByName("juggernaut_omni_slash")

        if omniSlash and omniSlash:GetLevel() > 0 then
            local currentCoolDown = omniSlash:GetCooldownTime()
            if currentCoolDown >= 1 then
                omniSlash:EndCooldown()
                omniSlash:StartCooldown(currentCoolDown - self.cooldown_reduction)
            end
        end
    end
end

function modifier_juggernaut_cd_omnislash_dark_moon:OnTooltip()
    return self.cooldown_reduction
end