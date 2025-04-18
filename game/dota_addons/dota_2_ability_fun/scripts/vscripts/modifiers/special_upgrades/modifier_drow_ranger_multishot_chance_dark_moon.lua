modifier_drow_ranger_multishot_chance_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_drow_ranger_multishot_chance_dark_moon:IsHidden()
	return false
end

function modifier_drow_ranger_multishot_chance_dark_moon:IsPurgeException()
	return false
end

function modifier_drow_ranger_multishot_chance_dark_moon:IsPurgable()
	return false
end

function modifier_drow_ranger_multishot_chance_dark_moon:IsPermanent()
	return true
end

function modifier_drow_ranger_multishot_chance_dark_moon:GetTexture()
	return "drow_ranger_multishot"
end

function modifier_drow_ranger_multishot_chance_dark_moon:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA + 2
end

function modifier_drow_ranger_multishot_chance_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,

        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_drow_ranger_multishot_chance_dark_moon:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0
        self.waveCount = kv.wave_count or 1

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_drow_ranger_multishot_chance_dark_moon:AddCustomTransmitterData()
    return {
        chance = self.chance,
        waveCount = self.waveCount
    }
end

function modifier_drow_ranger_multishot_chance_dark_moon:HandleCustomTransmitterData( data )
    self.chance = data.chance
    self.waveCount = data.waveCount
end

function modifier_drow_ranger_multishot_chance_dark_moon:GetModifierOverrideAbilitySpecial( params )
    if not IsServer() then
        return 0
    end

	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()
    local szSpecialValueName = params.ability_special_value

    if not self.smallMultishot then
        return 0
    end

	if szAbilityName == "drow_ranger_multishot" and szSpecialValueName == "wave_count"  then
		return 1
	end

	return 0
end

function modifier_drow_ranger_multishot_chance_dark_moon:GetModifierOverrideAbilitySpecialValue( params )
    local szSpecialValueName = params.ability_special_value
    local level = params.ability_special_level

    if not IsServer() then
        return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
    end

    if szSpecialValueName == "wave_count" then
        return self.waveCount or 1
    end

    return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
end

function modifier_drow_ranger_multishot_chance_dark_moon:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    
    local attacker = params.attacker

    if attacker ~= self:GetParent() then
        return
    end

    if attacker:IsNull() or not attacker:IsAlive() then
        return
    end

    if params.target:IsNull() or not params.target:IsAlive() or params.target:IsBuilding() or params.target:IsOther() then
        return
    end

	if params.no_attack_cooldown then
		return
	end

    local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")
    if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local arrows = self:GetParent():FindAbilityByName("drow_ranger_multishot")

        if arrows and arrows:GetLevel() > 0 then
            self:GetParent():SetCursorPosition(params.target:GetAbsOrigin())

            self.smallMultishot = true
            arrows:OnSpellStart()
            self.smallMultishot = false
        end
    end 
end

function modifier_drow_ranger_multishot_chance_dark_moon:OnTooltip()
    return self.chance
end

function modifier_drow_ranger_multishot_chance_dark_moon:OnTooltip2()
    return self.chance
end