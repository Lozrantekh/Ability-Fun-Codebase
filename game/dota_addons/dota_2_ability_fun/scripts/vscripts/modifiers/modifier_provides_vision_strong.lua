
modifier_provides_vision_strong = class({})

-----------------------------------------------------------------------------------------

function modifier_provides_vision_strong:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_provides_vision_strong:IsPurgable()
	return false
end

function modifier_provides_vision_strong:IsPermanent()
	return true
end

--------------------------------------------------------------------------------

function modifier_provides_vision_strong:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_provides_vision_strong:CheckState()
	local state = {}
	state[MODIFIER_STATE_PROVIDES_VISION] = true
	state[MODIFIER_PROPERTY_PROVIDES_FOW_POSITION] = true

	return state
end