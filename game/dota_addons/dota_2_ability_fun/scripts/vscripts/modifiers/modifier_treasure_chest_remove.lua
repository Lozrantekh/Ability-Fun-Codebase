modifier_treasure_chest_remove = class({})

--------------------------------------------------------------------------------

function modifier_treasure_chest_remove:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_treasure_chest_remove:OnCreated( kv )
	if IsServer() then
	end
end

--------------------------------------------------------------------------------

function modifier_treasure_chest_remove:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_SCALE
	}
	return funcs
end

-----------------------------------------------------------------------
function modifier_treasure_chest_remove:GetModifierModelScale()
	return -50
end

function modifier_treasure_chest_remove:OnDestroy()
	if IsServer() and self:GetParent() then
		UTIL_Remove(self:GetParent())
	end
end