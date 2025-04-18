modifier_marci_unleash_attack_buff_ad_2023 = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marci_unleash_attack_buff_ad_2023:IsHidden()
	return false
end

function modifier_marci_unleash_attack_buff_ad_2023:IsPurgeException()
	return false
end

function modifier_marci_unleash_attack_buff_ad_2023:IsPurgable()
	return false
end

function modifier_marci_unleash_attack_buff_ad_2023:IsPermanent()
	return true
end

function modifier_marci_unleash_attack_buff_ad_2023:GetTexture()
	return "marci_unleash"
end

function modifier_marci_unleash_attack_buff_ad_2023:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,

        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_marci_unleash_attack_buff_ad_2023:OnCreated(kv)
    if IsServer() then
        self.chance = kv.chance or 0
        self.attacks = 0
        self.maxAttacks = 0
        self.customFuryApplied = false
        self.unleashNormalCast = false

        self.isRangeAttacker = self:GetParent():IsRangedAttacker()

        --only for ranged attackers
        self.attackRecord = -1

        print("ranged attacker: ", self.isRangeAttacker)

        local unleash = self:GetParent():FindAbilityByName("marci_unleash")
        if unleash and unleash:GetLevel() > 0 then
            self.maxAttacks = unleash:GetSpecialValueFor("charges_per_flurry")
        end

        self:SetHasCustomTransmitterData(true)
    end
end

function modifier_marci_unleash_attack_buff_ad_2023:AddCustomTransmitterData()
    return {
        chance = self.chance,
    }
end

function modifier_marci_unleash_attack_buff_ad_2023:HandleCustomTransmitterData( data )
    self.chance = data.chance
end

function modifier_marci_unleash_attack_buff_ad_2023:OnAbilityExecuted(params)
	if self:GetParent() ~= params.unit then
		return
	end

	local ability = params.ability
	local abilityName = ability:GetAbilityName()

    if abilityName == "marci_unleash" then
        self.unleashNormalCast = true
        self.customFuryApplied = false
        self.firstAttackCounted = false
        self.attacks = 0
    end
end

function modifier_marci_unleash_attack_buff_ad_2023:OnAttackStart(params)
    if not IsServer() then
        return
    end
    
    local attacker = params.attacker

    if attacker ~= self:GetParent() then
        return
    end

    if not attacker:IsAlive() then
        return
    end

    if self.isRangeAttacker then
        self:HandleCustomUnleashAttacks(attacker)
    end
end

function modifier_marci_unleash_attack_buff_ad_2023:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    
    local attacker = params.attacker

    if attacker ~= self:GetParent() then
        return
    end

    if not attacker:IsAlive() then
        return
    end

    if not self.isRangeAttacker then
        self:HandleCustomUnleashAttacks(attacker)

    --for ranged heroes any arrow that was started before gain fury modifier is still counted to the strikes
    elseif self.customFuryApplied and not self.firstAttackCounted then
        self.firstAttackCounted = true
        self.attacks = self.attacks + 1
    end
end

function modifier_marci_unleash_attack_buff_ad_2023:HandleCustomUnleashAttacks(attacker)
    if not attacker then
        return
    end

    if self.unleashNormalCast and not attacker:HasModifier("modifier_marci_unleash") then
        self.unleashNormalCast = false
    end

    if self.unleashNormalCast then
        return
    end

    if self.customFuryApplied then
        self.attacks = self.attacks + 1

        if self.attacks >= self.maxAttacks then
            for _, modifier in pairs(self:GetParent():FindAllModifiers()) do
                if modifier and modifier:GetAbility() and modifier:GetAbility():GetAbilityName() == "marci_unleash" then
                    modifier:Destroy()
                end
            end

            self.attacks = 0
            self.customFuryApplied = false
            self.firstAttackCounted = false
        end
    else
        local attackFromSplitShoter = self:GetParent():GetIntAttr("noProc")
        if attackFromSplitShoter ~= 1 and RollPseudoRandomPercentage( math.floor( self.chance ), DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1 , self:GetParent()) then
            local unleash = self:GetParent():FindAbilityByName("marci_unleash")
    
            if unleash and unleash:GetLevel() > 0 then
                self.attacks = 0
                self.customFuryApplied = true
                self.unleashNormalCast = false
                self.maxAttacks = unleash:GetSpecialValueFor("charges_per_flurry")
    
                unleash:OnSpellStart()
            end
        end
    end
end

function modifier_marci_unleash_attack_buff_ad_2023:OnTooltip()
    return self.chance
end