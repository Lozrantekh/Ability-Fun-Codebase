modifier_antimage_attack_mana_void = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_antimage_attack_mana_void:IsHidden()
	return false
end

function modifier_antimage_attack_mana_void:IsPurgeException()
	return false
end

function modifier_antimage_attack_mana_void:IsPurgable()
	return false
end

function modifier_antimage_attack_mana_void:IsPermanent()
	return true
end

function modifier_antimage_attack_mana_void:GetTexture()
	return "antimage_mana_void"
end

--need higher priority than ability upgrade modifier: modifier_ability_value_upgrades_sb_2023 (MODIFIER_PRIORITY_SUPER_ULTRA + 1)
function modifier_antimage_attack_mana_void:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 2
end

function modifier_antimage_attack_mana_void:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,

        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_antimage_attack_mana_void:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0

        self.manaVoidDmgPerMana = 0
        self.manaVoidAoeRadius = 0

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_antimage_attack_mana_void:AddCustomTransmitterData()
    return {
        chance = self.chance,
    }
end

function modifier_antimage_attack_mana_void:HandleCustomTransmitterData( data )
    self.chance = data.chance
end

function modifier_antimage_attack_mana_void:OnAttackLanded(params)
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

    if RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local manaVoid = self:GetParent():FindAbilityByName("antimage_mana_void")

        if manaVoid and manaVoid:GetLevel() > 0 then
            self.manaVoidDmgPerMana = manaVoid:GetSpecialValueFor("mana_void_damage_per_mana")
            self.manaVoidAoeRadius = manaVoid:GetSpecialValueFor("mana_void_aoe_radius")

            self:GetParent():SetCursorCastTarget(params.target)

            self.smallManaVoid = true
            manaVoid:OnSpellStart()
            self.smallManaVoid = false
        end
    end
end

function modifier_antimage_attack_mana_void:OnTooltip()
    return self.chance
end

function modifier_antimage_attack_mana_void:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()
    local szSpecialValueName = params.ability_special_value

    if not self.smallManaVoid then
        return 0
    end

    local specialNameUpgrades = {
        mana_void_damage_per_mana = true,
        mana_void_aoe_radius = true,
        mana_void_ministun = true,
    }

	if szAbilityName == "antimage_mana_void" and specialNameUpgrades[szSpecialValueName] then
		return 1
	end

	return 0
end

function modifier_antimage_attack_mana_void:GetModifierOverrideAbilitySpecialValue( params )
	local szSpecialValueName = params.ability_special_value
    local level = params.ability_special_level

    if szSpecialValueName == "mana_void_damage_per_mana" and self.manaVoidDmgPerMana then
        return self.manaVoidDmgPerMana * 0.5
    end

    if szSpecialValueName == "mana_void_aoe_radius" and self.manaVoidAoeRadius then
        return self.manaVoidAoeRadius * 0.5
    end

    if szSpecialValueName == "mana_void_ministun" then
        return 0
    end

    return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
end