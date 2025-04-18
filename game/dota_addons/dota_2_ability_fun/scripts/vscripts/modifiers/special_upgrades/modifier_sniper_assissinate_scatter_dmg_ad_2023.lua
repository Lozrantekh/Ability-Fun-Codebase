modifier_sniper_assissinate_scatter_dmg_ad_2023 = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_assissinate_scatter_dmg_ad_2023:IsHidden()
	return false
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:IsPurgeException()
	return false
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:IsPurgable()
	return false
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:IsPermanent()
	return true
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:GetTexture()
    return "sniper_assassinate"
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:OnTooltip()
    return self.scatter_damage
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:OnCreated(kv)
    if IsServer() then
        self.scatter_damage = kv.scatter_damage or 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:AddCustomTransmitterData()
    return {
        scatter_damage = self.scatter_damage,
    }
end

function modifier_sniper_assissinate_scatter_dmg_ad_2023:HandleCustomTransmitterData( data )
    self.scatter_damage = data.scatter_damage
end