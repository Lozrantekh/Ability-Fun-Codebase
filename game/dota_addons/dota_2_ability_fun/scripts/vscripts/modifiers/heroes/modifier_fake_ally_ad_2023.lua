modifier_fake_ally_ad_2023 = class({})

function modifier_fake_ally_ad_2023:IsHidden()
	return true
end

function modifier_fake_ally_ad_2023:IsPurgable()
	return false
end

function modifier_fake_ally_ad_2023:OnCreated(kv)
	if IsServer() then
		print("created fake ally!")

	end
end

function modifier_fake_ally_ad_2023:CheckState()
	local state = {}
	if IsServer()  then
		state[MODIFIER_STATE_FAKE_ALLY ] = true
	end
	
	return state
end