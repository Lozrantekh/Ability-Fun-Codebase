modifier_model_change_visual = class({})

function modifier_model_change_visual:IsHidden()
	return true
end

function modifier_model_change_visual:IsPurgable()
	return false
end

function modifier_model_change_visual:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_model_change_visual:OnCreated(kv)
	if IsServer() then
		if not kv.model_name then
			self:Destroy()
			return
		end

		self.modelName = kv.model_name
	end
end


function modifier_model_change_visual:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function modifier_model_change_visual:GetModifierModelChange()
	return self.modelName
end