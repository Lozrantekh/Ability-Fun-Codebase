modifier_phantom_assassin_auto_dagger_ad_2023 = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_phantom_assassin_auto_dagger_ad_2023:IsHidden()
	return false
end

function modifier_phantom_assassin_auto_dagger_ad_2023:IsPurgeException()
	return false
end

function modifier_phantom_assassin_auto_dagger_ad_2023:IsPurgable()
	return false
end

function modifier_phantom_assassin_auto_dagger_ad_2023:IsPermanent()
	return true
end

function modifier_phantom_assassin_auto_dagger_ad_2023:DestroyOnExpire()
	return false
end

function modifier_phantom_assassin_auto_dagger_ad_2023:GetTexture()
	return "phantom_assassin_stifling_dagger"
end

function modifier_phantom_assassin_auto_dagger_ad_2023:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_phantom_assassin_auto_dagger_ad_2023:OnCreated(kv)
    if IsServer() then
        self.cooldown = kv.cooldown or 3.5

        self:SetHasCustomTransmitterData(true)

        self:StartIntervalThink(0.25)
    end
end

function modifier_phantom_assassin_auto_dagger_ad_2023:OnIntervalThink()
    if self:GetRemainingTime() > 0.1 then
        return
    else
        self:SetDuration(-1, true)
    end

    if not self:GetParent():IsAlive() or self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then
        return
    end

    local dagger = self:GetParent():FindAbilityByName("phantom_assassin_stifling_dagger")

    if not dagger or dagger:GetLevel() == 0 then
        return
    end

    local daggerRange = dagger:GetEffectiveCastRange(self:GetParent():GetAbsOrigin(), nil)
    
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        daggerRange,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,	-- int, order filter
        false
    )

    --first try find real heroes
    local target = nil
    local targetCreep = nil
    local targetHero = nil

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsInvulnerable() then
            if enemy:IsRealHero() then
                targetHero = enemy
                break
            else
                targetCreep = enemy
            end
        end
    end

    if targetHero then
        target = targetHero
    elseif targetCreep then
        target = targetCreep
    end

    if target then
        self:GetParent():SetCursorCastTarget(target)
        dagger:OnSpellStart()

        self:SetDuration(self.cooldown + 0.1, true)
    end
end

function modifier_phantom_assassin_auto_dagger_ad_2023:AddCustomTransmitterData()
    return {
        cooldown = self.cooldown,
    }
end

function modifier_phantom_assassin_auto_dagger_ad_2023:HandleCustomTransmitterData( data )
    self.cooldown = data.cooldown
end


function modifier_phantom_assassin_auto_dagger_ad_2023:OnTooltip()
    return self.cooldown
end