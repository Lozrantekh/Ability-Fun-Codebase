modifier_lone_druid_little_bear_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_lone_druid_little_bear_dark_moon:IsHidden()
	return true
end

function modifier_lone_druid_little_bear_dark_moon:IsPurgeException()
	return false
end

function modifier_lone_druid_little_bear_dark_moon:IsPurgable()
	return false
end

function modifier_lone_druid_little_bear_dark_moon:IsPermanent()
	return true
end

function modifier_lone_druid_little_bear_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_lone_druid_little_bear_dark_moon:OnCreated(table)
    self.duration = 3
end

function modifier_lone_druid_little_bear_dark_moon:OnAbilityFullyCast(params)
    if not IsServer() then
        return
    end

    if self:GetParent() ~= params.unit then
        return
    end

    local spiritBearAbility = self:GetParent():FindAbilityByName("lone_druid_spirit_bear")
    if not spiritBearAbility or spiritBearAbility:GetLevel() < 1 then
        return
    end

    if params.ability:GetAbilityName() ~= "lone_druid_spirit_bear" then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "lone_druid_spirit_bear", "little_bear") then
        return
    end

    local spiritBear = CreateUnitByName( "npc_dota_lone_druid_small_bear", self:GetParent():GetAbsOrigin(), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
    if spiritBear ~= nil then
        -- spiritBear:SetControllableByPlayer( self:GetParent():GetPlayerOwnerID(), false )
        FindClearSpaceForUnit( spiritBear, self:GetParent():GetAbsOrigin(), true )

        if self.littleBear and not self.littleBear:IsNull() and self.littleBear:IsAlive() then
            self.littleBear:ForceKill(false)
        end

        self.littleBear = spiritBear

        if self.bigBearModel then
            self.littleBear:SetModel(self.bigBearModel)
            self.littleBear:SetOriginalModel(self.bigBearModel)
        end

        if not self.bigBearModel then
            Timers:CreateTimer(0.75, function()
                local friends = FindUnitsInRadius(
                    self:GetParent():GetTeamNumber(),	-- int, your team number
                    self:GetParent():GetAbsOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,	-- int, type filter
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                    FIND_ANY_ORDER,	-- int, order filter
                    false	-- bool, can grow cache
                )

                for _, friend in pairs(friends) do
                    if friend:GetClassname() == spiritBear:GetClassname() and friend ~= self.littleBear and not friend:IsNull() then
                        self.bigBearModel = friend:GetModelName()
                        break
                    end
                end

                if self.bigBearModel then
                    self.littleBear:SetModel(self.bigBearModel)
                    self.littleBear:SetOriginalModel(self.bigBearModel)
                end
             end)
        end

        local abilityCount = spiritBear:GetAbilityCount()

        for i = 0, abilityCount - 1 do
            local sbAbility = spiritBear:GetAbilityByIndex(i)
            if sbAbility then
                sbAbility:SetLevel(1)
            end
        end

        local spiritLinkAbility = self:GetParent():FindAbilityByName("lone_druid_spirit_link")
        if spiritLinkAbility and spiritLinkAbility:GetLevel() > 0 then
            spiritBear:AddNewModifier(self:GetParent(), spiritLinkAbility, "modifier_lone_druid_spirit_link", {})
        end

        spiritBear:AddNewModifier(self:GetParent(), nil, "modifier_lone_druid_spirit_bear_baby", {})
    end
end