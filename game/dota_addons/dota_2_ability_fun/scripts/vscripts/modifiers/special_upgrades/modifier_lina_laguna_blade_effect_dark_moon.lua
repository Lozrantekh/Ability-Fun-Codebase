LinkLuaModifier("modifier_lina_laguna_debuff_dark_moon", "modifiers/special_upgrades/modifier_lina_laguna_debuff_dark_moon", LUA_MODIFIER_MOTION_NONE)

modifier_lina_laguna_blade_effect_dark_moon = class({})

function modifier_lina_laguna_blade_effect_dark_moon:IsHidden()
	return true
end

function modifier_lina_laguna_blade_effect_dark_moon:IsPurgeException()
	return false
end

function modifier_lina_laguna_blade_effect_dark_moon:IsPurgable()
	return false
end

function modifier_lina_laguna_blade_effect_dark_moon:IsPermanent()
	return true
end

function modifier_lina_laguna_blade_effect_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_lina_laguna_blade_effect_dark_moon:OnCreated(kv)
    if IsServer() then
        
    end
end

function modifier_lina_laguna_blade_effect_dark_moon:OnTakeDamage(params)
    local unit = params.unit
    local attacker = params.attacker

    if attacker ~= self:GetParent() or attacker:GetTeamNumber() == unit:GetTeamNumber() then
        return
    end

    if not unit or unit:IsNull() or not unit:IsAlive() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "lina_laguna_blade", "enemy_weak") then
        return
    end


    local isLaguna = (params.inflictor and params.inflictor:GetAbilityName() == "lina_laguna_blade")

    if not isLaguna then
        return
    end

    if not _G._GetSpecialUpgradeValues then
        return
    end

    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"lina_laguna_blade", "enemy_weak")
    if not values or not values.duration then
        return
    end

    local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		unit:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		values.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		FIND_FARTHEST,	-- int, order filter
		false	-- bool, can grow cache
	)

    if enemies and #enemies > 0 then
        for _, enemy in pairs(enemies) do
            if enemy ~= unit and not enemy:IsNull() and enemy:IsAlive() then
                enemy:AddNewModifier(self:GetParent(), params.inflictor, "modifier_lina_laguna_debuff_dark_moon", 
                {
                    duration = values.duration,
                    dmg = 0,
                    miss = values.miss_arround,
                    effect = 0
                }) 
            end
        end
    end
    
    unit:AddNewModifier(self:GetParent(), params.inflictor, "modifier_lina_laguna_debuff_dark_moon", 
    {
        duration = values.duration,
        dmg = values.dmg,
        miss = values.miss,
        effect = 1
    })
end