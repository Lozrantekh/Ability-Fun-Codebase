
modifier_generic_collect_stats = class({})

------------------------------------------------------------------------------

function modifier_generic_collect_stats:IsPurgable()
	return false
end

------------------------------------------------------------------------------

function modifier_generic_collect_stats:OnCreated( kv )
    if IsServer() then
    end
end


function modifier_generic_collect_stats:CheckState()
	local state =
	{
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
	}
	return state
end

--------------------------------------------------------------------------------

function modifier_generic_collect_stats:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_generic_collect_stats:OnTakeDamage( params )
    if IsServer() then
        if params.attacker == self:GetParent() or params.unit == self:GetParent() then
            return
        end

        if not params.unit or params.unit:IsNull() or params.unit:IsTower() or params.unit:IsBuilding() or params.unit:IsOther() or
            params.unit:GetUnitName() == "npc_dota_hero_target_dummy"
        then
            return
        end

        local hAttackerUnit = params.attacker
        local hVictimUnit = params.unit

        local damage = math.ceil(params.damage)

        --not sure if this is necessary (-suicide makes physical dmg but 0 original damage)
        local originalDamage = math.ceil(math.max(params.original_damage, params.damage))

        --Damage Dealt
        if hAttackerUnit and hAttackerUnit:IsRealHero() then
            local playerID = hAttackerUnit:GetPlayerID()

            local playerStats = GameRules.AbilityDraftRanked._vPlayerStats[ playerID ]
            if not playerStats then
                return
            end
            
            if params.damage_type == 1 then
                --physical
                if playerStats.dealtDamage and playerStats.dealtDamage.physical and playerStats.dealtDamage.total then
                    playerStats.dealtDamage.physical = playerStats.dealtDamage.physical + damage
                    playerStats.dealtDamage.total = playerStats.dealtDamage.total + damage
                end
            elseif params.damage_type == 2 then
                --magical
                if playerStats.dealtDamage and playerStats.dealtDamage.magical and playerStats.dealtDamage.total then
                    playerStats.dealtDamage.magical = playerStats.dealtDamage.magical + damage
                    playerStats.dealtDamage.total = playerStats.dealtDamage.total + damage
                end
            elseif params.damage_type == 4 then
                --pure
                if playerStats.dealtDamage and playerStats.dealtDamage.pure and playerStats.dealtDamage.total then
                    playerStats.dealtDamage.pure = playerStats.dealtDamage.pure + damage
                    playerStats.dealtDamage.total = playerStats.dealtDamage.total + damage
                end
            else
                --other to physical
                if playerStats.dealtDamage and playerStats.dealtDamage.physical and playerStats.dealtDamage.total then
                    playerStats.dealtDamage.physical = playerStats.dealtDamage.physical + damage
                    playerStats.dealtDamage.total = playerStats.dealtDamage.total + damage
                end
            end
        end

        --Damage received
        if hVictimUnit and hVictimUnit:IsRealHero() then
            local playerID = hVictimUnit:GetPlayerID()

            local playerStats = GameRules.AbilityDraftRanked._vPlayerStats[ playerID ]
            if not playerStats then
                return
            end

            if params.damage_type == 1 then
                --physical
                if playerStats.receivedDamage and playerStats.receivedDamage.physical and playerStats.receivedDamage.physical_original and 
                    playerStats.receivedDamage.total and playerStats.receivedDamage.total_original 
                    then

                    playerStats.receivedDamage.physical = playerStats.receivedDamage.physical + damage
                    playerStats.receivedDamage.physical_original = playerStats.receivedDamage.physical_original + originalDamage
                    playerStats.receivedDamage.total = playerStats.receivedDamage.total + damage
                    playerStats.receivedDamage.total_original = playerStats.receivedDamage.total_original + originalDamage
                end
            elseif params.damage_type == 2 then
                --magical
                if playerStats.receivedDamage and playerStats.receivedDamage.magical and playerStats.receivedDamage.magical_original and 
                    playerStats.receivedDamage.total and playerStats.receivedDamage.total_original
                    then

                    playerStats.receivedDamage.magical = playerStats.receivedDamage.magical + damage
                    playerStats.receivedDamage.magical_original = playerStats.receivedDamage.magical_original + originalDamage
                    playerStats.receivedDamage.total = playerStats.receivedDamage.total + damage
                    playerStats.receivedDamage.total_original = playerStats.receivedDamage.total_original + originalDamage
                end
            elseif params.damage_type == 4 then
                --pure
                if playerStats.receivedDamage and playerStats.receivedDamage.pure and playerStats.receivedDamage.total and 
                    playerStats.receivedDamage.total_original
                    then

                    playerStats.receivedDamage.pure = playerStats.receivedDamage.pure + damage
                    playerStats.receivedDamage.total = playerStats.receivedDamage.total + damage
                    playerStats.receivedDamage.total_original = playerStats.receivedDamage.total_original + damage
                end
            else
                --other to physical
                if playerStats.receivedDamage and playerStats.receivedDamage.physical and playerStats.receivedDamage.physical_original and 
                    playerStats.receivedDamage.total and playerStats.receivedDamage.total_original 
                    then

                    playerStats.receivedDamage.physical = playerStats.receivedDamage.physical + damage
                    playerStats.receivedDamage.physical_original = playerStats.receivedDamage.physical_original + originalDamage
                    playerStats.receivedDamage.total = playerStats.receivedDamage.total + damage
                    playerStats.receivedDamage.total_original = playerStats.receivedDamage.total_original + originalDamage
                end
            end
        end
    end
end