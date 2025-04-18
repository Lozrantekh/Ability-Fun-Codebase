----------------------------------------------------------------------------------------------------
-- Battle Hunger deny modifier to allow enemies to attack their allies
----------------------------------------------------------------------------------------------------
modifier_scream_of_the_dead_debuff_deny = modifier_scream_of_the_dead_debuff_deny or class({})

function modifier_scream_of_the_dead_debuff_deny:CheckState()
	local state = {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
	return state
end

function modifier_scream_of_the_dead_debuff_deny:IsHidden()
	return true
end

function modifier_scream_of_the_dead_debuff_deny:IsDebuff()
	return true
end

function modifier_scream_of_the_dead_debuff_deny:IsPurgable()
	return false
end