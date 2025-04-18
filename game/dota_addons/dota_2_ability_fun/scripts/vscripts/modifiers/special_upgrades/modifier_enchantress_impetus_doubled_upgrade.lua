modifier_enchantress_impetus_doubled_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_enchantress_impetus_doubled_upgrade:IsHidden()
	return false
end

function modifier_enchantress_impetus_doubled_upgrade:IsPurgeException()
	return false
end

function modifier_enchantress_impetus_doubled_upgrade:IsPurgable()
	return false
end

function modifier_enchantress_impetus_doubled_upgrade:IsPermanent()
	return true
end

function modifier_enchantress_impetus_doubled_upgrade:GetTexture()
	return "enchantress_impetus"
end

function modifier_enchantress_impetus_doubled_upgrade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_enchantress_impetus_doubled_upgrade:OnCreated(kv)
    if IsServer() then
        self.impetus_orb = false
        self.chance = kv.chance or 0
        self.maxImpetuses = kv.extra_attacks or 0

        self.unitsNoAttacked = {
			npc_dota_crate = true,
			npc_dota_vase = true,
		}

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_enchantress_impetus_doubled_upgrade:AddCustomTransmitterData()
    return {
        chance = self.chance,
        maxImpetuses = self.maxImpetuses
    }
end

function modifier_enchantress_impetus_doubled_upgrade:HandleCustomTransmitterData( data )
    self.chance = data.chance
    self.maxImpetuses = data.maxImpetuses
end

function modifier_enchantress_impetus_doubled_upgrade:OnTooltip()
    return self.chance
end

function modifier_enchantress_impetus_doubled_upgrade:OnTooltip2()
    return self.maxImpetuses
end

function modifier_enchantress_impetus_doubled_upgrade:GetModifierPercentageManacost()
    if IsServer() then
        if self.freeImpetus then
            return 100
        end
    end

    return 0
end

function modifier_enchantress_impetus_doubled_upgrade:OnAttack(params)
    if not IsServer() then
        return
    end
    
    local attacker = params.attacker

    if attacker ~= self:GetParent() then
        return
    end

    if not params.target then
        return
    end

    if attacker:IsNull() or not attacker:IsAlive() then
        return
    end

    if self.split_shot then
        return
    end

    local impetus = self:GetParent():FindAbilityByName("enchantress_impetus")
    if not impetus or impetus:GetLevel() == 0 or (not impetus:GetAutoCastState() and not self.impetus_orb) then
        return
    end

    local impetusManaCost = impetus:GetEffectiveManaCost(impetus:GetLevel())

    if self:GetParent():GetMana() < impetusManaCost then
        return
    end

    local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")

    if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
        local enemies = FindUnitsInRadius(
            attacker:GetTeamNumber(),	-- int, your team number
            attacker:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            1200,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
            FIND_FARTHEST,	-- int, order filter
            false	-- bool, can grow cache
        )
    
        local attacksPerform = {}

        local extraAttack = 0

        self.split_shot = true
        self.freeImpetus = true
        for _, enemy in ipairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() and enemy ~= params.target and not self.unitsNoAttacked[enemy:GetUnitName()] then    
                if extraAttack >= self.maxImpetuses then
                    break
                end

                attacker:PerformAttack(enemy, false, false, true, true, true, false, true)

                table.insert(attacksPerform, enemy)
                extraAttack = extraAttack + 1
            end
        end

        self.split_shot = false
        self.freeImpetus = false
    end 
end

-- Handle Impetus orb flag by checking if it is manually cast
function modifier_enchantress_impetus_doubled_upgrade:OnOrder(keys)
    if not IsServer() then
        return
    end

	if keys.unit == self:GetParent() then
		if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET and keys.ability:GetName() == self:GetAbility():GetAbilityName() then
			self.impetus_orb = true
		else
			self.impetus_orb = false
		end
	end
end