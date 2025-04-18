modifier_lina_laguna_debuff_dark_moon = class({})

function modifier_lina_laguna_debuff_dark_moon:IsHidden()
	return false
end

function modifier_lina_laguna_debuff_dark_moon:IsPurgeException()
	return false
end

function modifier_lina_laguna_debuff_dark_moon:IsPurgable()
	return false
end

function modifier_lina_laguna_debuff_dark_moon:IsPermanent()
	return true
end

function modifier_lina_laguna_debuff_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MISS_PERCENTAGE
    }
end

function modifier_lina_laguna_debuff_dark_moon:OnCreated(kv)
    if IsServer() then
        self.effect = kv.effect or 0
        self.duration = kv.duration or 0
        self.moreDmg = kv.dmg or 0
        self.miss = kv.miss or 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_lina_laguna_debuff_dark_moon:OnRefresh(kv)
    if IsServer() then
        self:OnCreated(kv)

        self:SendBuffRefreshToClients()
    end
end

function modifier_lina_laguna_debuff_dark_moon:GetModifierIncomingDamage_Percentage()
	return self.moreDmg
end

function modifier_lina_laguna_debuff_dark_moon:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_lina_laguna_debuff_dark_moon:AddCustomTransmitterData()
    return {
        duration = self.duration,
        moreDmg = self.moreDmg,
        miss = self.miss,
        effect = self.effect
    }
end

function modifier_lina_laguna_debuff_dark_moon:HandleCustomTransmitterData( data )
    self.duration = data.duration
    self.moreDmg = data.moreDmg
    self.miss = data.miss
    self.effect = data.effect
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_lina_laguna_debuff_dark_moon:GetEffectName()
    if self.effect and self.effect == 1 then
        return "particles/econ/events/ti10/high_five/high_five_lvl2_overhead_flames.vpcf"
    end
end

function modifier_lina_laguna_debuff_dark_moon:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
