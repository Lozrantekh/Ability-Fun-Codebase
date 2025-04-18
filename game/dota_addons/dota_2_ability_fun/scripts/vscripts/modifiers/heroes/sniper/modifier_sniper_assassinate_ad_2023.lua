modifier_sniper_assassinate_ad_2023 = class({})

function modifier_sniper_assassinate_ad_2023:IsPurgable()
	return false;
end

--------------------------------------------------------------------------------

function modifier_sniper_assassinate_ad_2023:IsHidden()
	return true;
end


function modifier_sniper_assassinate_ad_2023:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_sniper_assassinate_ad_2023:OnDeath(params)
    if IsServer() then
        if params.attacker ~= self:GetParent() then
            return
        end

        if not params.unit or not params.unit:IsRealHero() then
            return
        end

        if not self:GetAbility() then
            return
        end

        if not params.inflictor or params.inflictor ~= self:GetAbility() then
            return
        end

        self:GetAbility():EndCooldown()
    end
end