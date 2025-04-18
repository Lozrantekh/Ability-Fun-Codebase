LinkLuaModifier("modifier_snapfire_cookie_mortimer_kiss_thinker", "modifiers/special_upgrades/modifier_snapfire_cookie_mortimer_kiss_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_cookie_mortimer_kiss_aura", "modifiers/special_upgrades/modifier_snapfire_cookie_mortimer_kiss_aura", LUA_MODIFIER_MOTION_NONE)

modifier_snapfire_cookie_dark_moon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_cookie_dark_moon:IsHidden()
	return true
end

function modifier_snapfire_cookie_dark_moon:IsPurgeException()
	return false
end

function modifier_snapfire_cookie_dark_moon:IsPurgable()
	return false
end

function modifier_snapfire_cookie_dark_moon:IsPermanent()
	return true
end

function modifier_snapfire_cookie_dark_moon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_snapfire_cookie_dark_moon:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_snapfire_cookie_dark_moon:OnCreated(table)
    self.duration = 3
end

function modifier_snapfire_cookie_dark_moon:OnAbilityFullyCast(params)
    if not IsServer()  then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if not _HasPlayerChosenSpecialUpgrade(self:GetParent():GetPlayerID(), "snapfire_scatterblast", "cooked") then
        return
    end

    if params.ability == nil or params.ability:GetAbilityName() ~= "snapfire_scatterblast" then
        return
    end

    local kiss = self:GetParent():FindAbilityByName("snapfire_mortimer_kisses")
    if kiss and kiss:GetLevel() > 0 then
        local length = params.ability:GetSpecialValueFor("blast_width_end") * 2 or 800
        local snapFireForwardVector = self:GetCaster():GetForwardVector()

        Timers:CreateTimer(0.15, function()
            CreateModifierThinker(
                self:GetParent(), -- player source
                nil, -- ability source
                "modifier_snapfire_cookie_mortimer_kiss_thinker", -- modifier name
                {
                    duration = self.duration,
                },
                self:GetCaster():GetAbsOrigin() + (snapFireForwardVector * 150),
                self:GetCaster():GetTeamNumber(),
                false
            )

            CreateModifierThinker(
                self:GetParent(), -- player source
                nil, -- ability source
                "modifier_snapfire_cookie_mortimer_kiss_thinker", -- modifier name
                {
                    duration = self.duration,
                },
                self:GetCaster():GetAbsOrigin() + (snapFireForwardVector * (length/2 + 150)),
                self:GetCaster():GetTeamNumber(),
                false
            )

            CreateModifierThinker(
                self:GetParent(), -- player source
                nil, -- ability source
                "modifier_snapfire_cookie_mortimer_kiss_thinker", -- modifier name
                {
                    duration = self.duration,
                },
                self:GetCaster():GetAbsOrigin() + (snapFireForwardVector * (length + 150)),
                self:GetCaster():GetTeamNumber(),
                false
            )
        end)
    end
end