modifier_faceless_void_small_chrono_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_faceless_void_small_chrono_dark_moon:IsHidden()
	return true
end

function modifier_faceless_void_small_chrono_dark_moon:IsPurgeException()
	return false
end

function modifier_faceless_void_small_chrono_dark_moon:IsPurgable()
	return false
end

function modifier_faceless_void_small_chrono_dark_moon:IsPermanent()
	return true
end

function modifier_faceless_void_small_chrono_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_faceless_void_small_chrono_dark_moon:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_faceless_void_small_chrono_dark_moon:OnCreated(table)
    self.chronoRadius = 200
    self.chronoDuration = 1.75

    -- self.multiplier = 0.5
    -- self.chance = 50
end

function modifier_faceless_void_small_chrono_dark_moon:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()

    if not self.smallChrono then
        return 0
    end

	if szAbilityName == "faceless_void_chronosphere" then
		return 1
	end

	return 0
end

function modifier_faceless_void_small_chrono_dark_moon:GetModifierOverrideAbilitySpecialValue( params )
	local szSpecialValueName = params.ability_special_value
    local level = params.ability_special_level

    if szSpecialValueName == "radius" and self.chronoRadius then
        return self.chronoRadius
    end

    if szSpecialValueName == "duration" and self.chronoDuration then
        return self.chronoDuration
    end

    return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
end

function modifier_faceless_void_small_chrono_dark_moon:OnAbilityFullyCast(params)
    if not IsServer()  then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "faceless_void_time_walk", "sphered") then
        return
    end

    if params.ability == nil or params.ability:GetAbilityName() ~= "faceless_void_time_walk" then
        return
    end

    local chrono = self:GetParent():FindAbilityByName("faceless_void_chronosphere")
    if chrono and chrono:GetLevel() > 0 then

        --if small chrono values base on normal chrono
        --this block of code has to be before self.smallChrono = true to avoid endless loop on MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL
        -- self.smallChronoParams = {
        --     duration = (chrono:GetSpecialValueFor("duration") or 0) * self.multiplier,
        --     radius = (chrono:GetSpecialValueFor("radius") or 0) * self.multiplier,
        --     bonus_attack_speed = (chrono:GetSpecialValueFor("bonus_attack_speed") or 0) * self.multiplier,
        -- }

        -- if self:GetParent():HasLearnedTalent("special_bonus_unique_faceless_void_2") then
        --     local talent = self:GetParent():FindAbilityByName("special_bonus_unique_faceless_void_2")
        --     if talent then
        --         local value = talent:GetSpecialValueFor("value")
        --         if value then
        --             self.smallChronoParams.radius = self.smallChronoParams.radius + value
        --         end
        --     end
        -- end

        -- if self:GetParent():HasLearnedTalent("special_bonus_unique_faceless_void") then
        --     local talent = self:GetParent():FindAbilityByName("special_bonus_unique_faceless_void")
        --     if talent then
        --         local value = talent:GetSpecialValueFor("value")
        --         if value then
        --             self.smallChronoParams.bonus_attack_speed = self.smallChronoParams.bonus_attack_speed + value
        --         end
        --     end
        -- end

        local range = params.ability:GetSpecialValueFor("range")
        local speed = params.ability:GetSpecialValueFor("speed") or 1
        local voidPosition = self:GetParent():GetAbsOrigin()

        local direction = params.ability:GetCursorPosition() - voidPosition
        local distance = direction:Length2D()

        if distance > range then 
            distance = range
        end

        local time = distance / speed

        Timers:CreateTimer(time, function()
            voidPosition = self:GetParent():GetAbsOrigin()
            self:GetParent():SetCursorPosition(voidPosition + self:GetParent():GetForwardVector() * 150)

            self.smallChrono = true
            chrono:OnSpellStart()
            self.smallChrono = false
        end)
    end
end