modifier_db_hammer_attack_chance_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_db_hammer_attack_chance_upgrade:IsHidden()
	return false
end

function modifier_db_hammer_attack_chance_upgrade:IsPurgeException()
	return false
end

function modifier_db_hammer_attack_chance_upgrade:IsPurgable()
	return false
end

function modifier_db_hammer_attack_chance_upgrade:IsPermanent()
	return true
end

function modifier_db_hammer_attack_chance_upgrade:GetTexture()
	return "dawnbreaker_celestial_hammer"
end

function modifier_db_hammer_attack_chance_upgrade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_db_hammer_attack_chance_upgrade:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0
        self.cooldown = kv.cooldown or 1

        self.hammer = self:GetParent():FindAbilityByName("aghsfort_dawnbreaker_celestial_hammer")

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_db_hammer_attack_chance_upgrade:AddCustomTransmitterData()
    return {
        chance = self.chance,
        cooldown = self.cooldown,
    }
end

function modifier_db_hammer_attack_chance_upgrade:HandleCustomTransmitterData( data )
    self.chance = data.chance
    self.cooldown = data.cooldown
end

function modifier_db_hammer_attack_chance_upgrade:GetModifierIncomingDamage_Percentage(params)
    if IsServer() then
        if params.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then
            return 0
        end

        if params.attacker:IsNull() or not params.attacker:IsAlive() or params.attacker:IsBuilding() or params.attacker:IsOther() then
            return 0
        end

        if params.attacker == self:GetParent() or params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            return 0
        end

        if not self:GetParent():IsAlive() or self:GetParent():PassivesDisabled() then
            return 0
        end

        if self.hammerThrow then
            return 0
        end

        if not self.hammer or self.hammer:GetLevel() == 0 then
            return 0
        end

        if RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
            self.hammerThrow = true

            local distance = (self:GetParent():GetAbsOrigin() - params.attacker:GetAbsOrigin()):Length2D()
            local hammerRange = self.hammer:GetSpecialValueFor("range") or 1000

            if distance > hammerRange + 50 then
                return 0
            end

            local direction = (params.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
            local vPos = params.attacker:GetAbsOrigin() + direction * 100


            self:GetParent():SetCursorPosition(vPos)
            self.hammer:OnSpellStart()

            Timers:CreateTimer(self.cooldown, function ()
                self.hammerThrow = false
            end)
        end
    end
end

function modifier_db_hammer_attack_chance_upgrade:OnTooltip()
    return self.chance
end

function modifier_db_hammer_attack_chance_upgrade:OnTooltip2()
    return self.cooldown
end