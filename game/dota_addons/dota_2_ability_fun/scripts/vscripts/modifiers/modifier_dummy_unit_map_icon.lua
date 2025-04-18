
modifier_dummy_unit_map_icon = class({})

------------------------------------------------------------------------------

function modifier_dummy_unit_map_icon:IsPurgable()
	return false
end

function modifier_dummy_unit_map_icon:IsPermanent()
    return true
end

function modifier_dummy_unit_map_icon:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

------------------------------------------------------------------------------

function modifier_dummy_unit_map_icon:OnCreated( kv )
    if IsServer() then
    end
end


function modifier_dummy_unit_map_icon:CheckState()
	local state =
	{
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,

		[MODIFIER_STATE_NOT_ON_MINIMAP] = false,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = false,
	}
	return state
end

--------------------------------------------------------------------------------

function modifier_dummy_unit_map_icon:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_FORCE_DRAW_MINIMAP,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_dummy_unit_map_icon:GetForceDrawOnMinimap()
    return 1
end