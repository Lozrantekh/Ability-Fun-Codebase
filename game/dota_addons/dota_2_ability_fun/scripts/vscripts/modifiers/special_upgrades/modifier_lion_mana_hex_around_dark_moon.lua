modifier_lion_mana_hex_around_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_lion_mana_hex_around_dark_moon:IsHidden()
	return true
end

function modifier_lion_mana_hex_around_dark_moon:IsPurgeException()
	return false
end

function modifier_lion_mana_hex_around_dark_moon:IsPurgable()
	return false
end

function modifier_lion_mana_hex_around_dark_moon:IsPermanent()
	return true
end

function modifier_lion_mana_hex_around_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_lion_mana_hex_around_dark_moon:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_lion_mana_hex_around_dark_moon:OnCreated(table)
    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"lion_mana_drain", "hexed")
    if not values or not values.range then
        return
    end

    self.range = values.range or 0
    self.multiplier = values.multiplier or 1
end

function modifier_lion_mana_hex_around_dark_moon:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()

	if szAbilityName == "lion_voodoo" and self.smallHex then
		return 1
	end

	return 0
end

function modifier_lion_mana_hex_around_dark_moon:GetModifierOverrideAbilitySpecialValue( params )
	local szSpecialValueName = params.ability_special_value
    local level = params.ability_special_level

    if szSpecialValueName == "duration" and self.currentHexDuration then
        return self.currentHexDuration * self.multiplier
    end

    return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
end

function modifier_lion_mana_hex_around_dark_moon:OnAbilityFullyCast(params)
    if not IsServer()  then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "lion_mana_drain", "hexed") then
        return
    end

    if params.ability == nil or params.ability:GetAbilityName() ~= "lion_mana_drain" then
        return
    end

    local hex = self:GetParent():FindAbilityByName("lion_voodoo")
    if hex and hex:GetLevel() > 0 then
        self.currentHexDuration = hex:GetSpecialValueFor("duration")

        for _,unit in pairs( FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
            if not unit:IsNull() and unit:IsAlive() then
                self:GetParent():SetCursorCastTarget(unit)
                self.smallHex = true
                hex:OnSpellStart()
                self.smallHex = false
            end
        end
    end
end