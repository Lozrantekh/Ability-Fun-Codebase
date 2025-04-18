modifier_medusa_snake_fall_mana_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_medusa_snake_fall_mana_dark_moon:IsHidden()
	return false
end

function modifier_medusa_snake_fall_mana_dark_moon:IsPurgeException()
	return false
end

function modifier_medusa_snake_fall_mana_dark_moon:DestroyOnExpire()
	return false
end

function modifier_medusa_snake_fall_mana_dark_moon:IsPurgable()
	return false
end

function modifier_medusa_snake_fall_mana_dark_moon:IsPermanent()
	return true
end

function modifier_medusa_snake_fall_mana_dark_moon:GetTexture()
	return "medusa_mystic_snake"
end

function modifier_medusa_snake_fall_mana_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_medusa_snake_fall_mana_dark_moon:OnCreated(kv)
    if IsServer() then
        self.canCastSnake = true

        self.coolDown = kv.cooldown or 10
        self.maxSnakes = kv.maxSnakes or 2

        self.manaThreshold = 0.2

        self.unitsNoAttacked = {
			npc_dota_crate = true,
			npc_dota_vase = true,
		}
        
        self:SetHasCustomTransmitterData(true)

        self:StartIntervalThink(0.25)
    end
end

function modifier_medusa_snake_fall_mana_dark_moon:AddCustomTransmitterData()
    return {
        coolDown = self.coolDown,
        maxSnakes = self.maxSnakes,
    }
end

function modifier_medusa_snake_fall_mana_dark_moon:HandleCustomTransmitterData( data )
    self.coolDown = data.coolDown
    self.maxSnakes = data.maxSnakes
end

function modifier_medusa_snake_fall_mana_dark_moon:OnIntervalThink()
    if not IsServer() then
        return
    end

    if not self.canCastSnake then
        if GameRules:GetGameTime() - self.snakeTime >= self.coolDown then
            self.canCastSnake = true
            self:SetDuration(-1, true)
        end

        if not self.canCastSnake then
            return
        end
    end

    if not self:GetParent():IsAlive() or self:GetParent():PassivesDisabled() then
        return
    end

    if self:GetParent():GetMana() <= self:GetParent():GetMaxMana() * self.manaThreshold then

        local abilitySnake = self:GetParent():FindAbilityByName("medusa_mystic_snake")
        if not abilitySnake or abilitySnake:GetLevel() == 0 then
            return
        end

        local castRange = abilitySnake:GetSpecialValueFor("AbilityCastRange") or 750
        castRange = castRange * 2

        local enemies = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),	-- int, your team number
            self:GetParent():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            castRange,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
            FIND_ANY_ORDER,	-- int, order filter
            false	-- bool, can grow cache
        )

        if not enemies or #enemies == 0 then
            return
        end

        self.canCastSnake = false
        self:SetDuration(self.coolDown + 0.1, true)

        local snakes = {}
        for _, enemy in pairs(enemies) do 
            if enemy and not enemy:IsNull() and enemy:IsAlive() and not self.unitsNoAttacked[enemy:GetUnitName()] then
                table.insert(snakes, enemy)

                if #snakes >= self.maxSnakes then
                    break
                end
            end
        end

        --repeat the unit if there is only one
        if #snakes == 1 then
            table.insert(snakes, snakes[1])
        end

        for i = 1, #snakes do
            Timers:CreateTimer(0.2 * i, function()
                self:GetParent():SetCursorCastTarget(snakes[i])
                abilitySnake:OnSpellStart()
            end)
        end

        self.snakeTime = GameRules:GetGameTime()
    end
end

function modifier_medusa_snake_fall_mana_dark_moon:OnTooltip()
    return self.coolDown
end

function modifier_medusa_snake_fall_mana_dark_moon:OnTooltip2()
    return self.maxSnakes
end