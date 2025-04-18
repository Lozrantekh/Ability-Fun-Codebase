tusk_walrus_punch_ad_ranked = class({})
LinkLuaModifier( "modifier_tusk_walrus_punch_ad_ranked", "modifiers/heroes/tusk/modifier_tusk_walrus_punch_ad_ranked", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function tusk_walrus_punch_ad_ranked:GetIntrinsicModifierName()
	return "modifier_tusk_walrus_punch_ad_ranked"
end

--------------------------------------------------------------------------------

function tusk_walrus_punch_ad_ranked:GetCastRange( vLocation, hTarget )
	
	return self:GetCaster():Script_GetAttackRange()
end

--------------------------------------------------------------------------------
