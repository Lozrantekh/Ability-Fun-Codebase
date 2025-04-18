dawnbreaker_luminosity_ad_ranked = class({})

LinkLuaModifier( "modifier_dawnbreaker_luminosity_ad_ranked", "modifiers/heroes/dawnbreaker/modifier_dawnbreaker_luminosity_ad_ranked", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
-- function dawnbreaker_luminosity_lua:Precache( context )
-- 	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
-- 	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", context )
-- 	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity_attack_buff.vpcf", context )
-- end

function dawnbreaker_luminosity_ad_ranked:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function dawnbreaker_luminosity_ad_ranked:GetIntrinsicModifierName()
	return "modifier_dawnbreaker_luminosity_ad_ranked"
end

function dawnbreaker_luminosity_ad_ranked:OnOwnerDied()
    if IsServer() then
        local modifier = self:GetCaster():FindModifierByName("modifier_dawnbreaker_luminosity_ad_ranked")
        if modifier then
            modifier:RemoveBuff()
        end
    end
end