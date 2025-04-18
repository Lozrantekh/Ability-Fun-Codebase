modifier_unslowable_2023 = class({})

function modifier_unslowable_2023:IsHidden()
	return true
end

function modifier_unslowable_2023:IsPurgeException()
	return false
end

function modifier_unslowable_2023:IsPurgable()
	return false
end

function modifier_unslowable_2023:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_unslowable_2023:OnCreated(kv)
	if IsServer() then
		print("unslowabals!")
	end
end

function modifier_unslowable_2023:CheckState()
	local state =
	{
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}
	return state
end
