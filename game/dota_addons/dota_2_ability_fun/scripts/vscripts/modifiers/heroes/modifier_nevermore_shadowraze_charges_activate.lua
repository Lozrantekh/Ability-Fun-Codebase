modifier_nevermore_shadowraze_charges_activate = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_nevermore_shadowraze_charges_activate:IsHidden()
	return false
end

function modifier_nevermore_shadowraze_charges_activate:IsPurgeException()
	return false
end

function modifier_nevermore_shadowraze_charges_activate:IsPurgable()
	return false
end

function modifier_nevermore_shadowraze_charges_activate:IsPermanent()
	return true
end

function modifier_nevermore_shadowraze_charges_activate:GetTexture()
	return "antimage_mana_void"
end

--need higher priority than ability upgrade modifier: modifier_ability_value_upgrades_sb_2023 (MODIFIER_PRIORITY_SUPER_ULTRA + 1)
function modifier_nevermore_shadowraze_charges_activate:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_nevermore_shadowraze_charges_activate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_nevermore_shadowraze_charges_activate:OnCreated(kv)
    if IsServer() then
    end
end

function modifier_nevermore_shadowraze_charges_activate:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()

	if szAbilityName == "nevermore_shadowraze2" then
		return 1
	end

	return 0
end

function modifier_nevermore_shadowraze_charges_activate:GetModifierOverrideAbilitySpecialValue( params )
	local szSpecialValueName = params.ability_special_value
    local level = params.ability_special_level

    if szSpecialValueName == "AbilityChargeRestoreTime" then
        return 10
    end

    if szSpecialValueName == "AbilityCharges" then
        return 3
    end

    if szSpecialValueName == "shadowraze_damage" then
        return 5000
    end

    return params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, level )
end