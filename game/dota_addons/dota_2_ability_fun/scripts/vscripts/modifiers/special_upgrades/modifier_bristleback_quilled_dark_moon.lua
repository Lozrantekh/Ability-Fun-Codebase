LinkLuaModifier("modifier_bristleback_quilled_metamorph_dark_moon", "modifiers/special_upgrades/modifier_bristleback_quilled_metamorph_dark_moon", LUA_MODIFIER_MOTION_NONE)

modifier_bristleback_quilled_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bristleback_quilled_dark_moon:IsHidden()
	return false
end

function modifier_bristleback_quilled_dark_moon:DestroyOnExpire()
	return false
end

function modifier_bristleback_quilled_dark_moon:IsPurgeException()
	return false
end

function modifier_bristleback_quilled_dark_moon:IsPermanent()
	return true
end

function modifier_bristleback_quilled_dark_moon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MIN_HEALTH
    }
end

function modifier_bristleback_quilled_dark_moon:OnCreated(table)
    self.canCastAbility = true

    local values = _G._GetSpecialUpgradeValues(self:GetParent():GetUnitName(),"bristleback_quill_spray", "quilled")
    if not values or not values.hpMargines then
        return
    end

    self.hpMargines = values.hpMargines
    self.hpRegen = values.hpRegen
    self.coolDown = values.coolDown
    self.duration = values.duration
    self.interval = values.interval
end

function modifier_bristleback_quilled_dark_moon:GetMinHealth()
    if self.canCastAbility then
        return 1
    else
        return 0
    end
end

function modifier_bristleback_quilled_dark_moon:GetModifierIncomingDamage_Percentage(params)
    if not IsServer() then return end

    if params.attacker == nil or params.attacker:IsNull() or not params.attacker:IsAlive() then
        return
    end

    if self:GetParent():IsNull() or not self:GetParent():IsAlive() then
        return
    end

    if params.attacker == self:GetParent() or params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "bristleback_quill_spray", "quilled") then
        return
    end

    local quillSprayAbility = self:GetParent():FindAbilityByName("bristleback_quill_spray")
    if not quillSprayAbility or quillSprayAbility:GetLevel() == 0 then
        return
    end
    
    if self.canCastAbility and self:GetParent():GetHealth() <= self:GetParent():GetMaxHealth() * self.hpMargines then
        local modifier = self:GetParent():AddNewModifier(self:GetParent(), quillSprayAbility, "modifier_bristleback_quilled_metamorph_dark_moon", {duration = self.duration})
        EmitSoundOn( "Bristleback.spikes.upgrade", self:GetParent() )

        Timers:CreateTimer(0.1, function()
            self.canCastAbility = false
        end)

        self:SetDuration(self.coolDown + 0.1, true)

        local dmg = quillSprayAbility:GetSpecialValueFor("quill_base_damage") or 0

        local ticks = self.duration/self.interval

        for i = 1, ticks do
            Timers:CreateTimer(self.interval * (i-1), function()
                quillSprayAbility:OnSpellStart()
                self:GetParent():Heal(self:GetParent():GetMaxHealth() * self.hpRegen, quillSprayAbility)
            end) 
        end

        Timers:CreateTimer(self.coolDown, function() 
            self.canCastAbility = true
            self:SetDuration(-1, true)
        end)
    end
end

function modifier_bristleback_quilled_dark_moon:SetCanCastAbility(canCastAbility) 
    self.canCastAbility = canCastAbility
end