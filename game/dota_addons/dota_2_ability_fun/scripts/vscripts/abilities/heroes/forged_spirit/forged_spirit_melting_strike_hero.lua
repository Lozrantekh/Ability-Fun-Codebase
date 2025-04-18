---@class forged_spirit_melting_strike_lua:CDOTA_Ability_Lua
forged_spirit_melting_strike_hero = class({})

LinkLuaModifier("modifier_melting_strike_hero", "abilities/heroes/forged_spirit/modifier_melting_strike_hero.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_melting_strike_debuff_hero", "abilities/heroes/forged_spirit/modifier_melting_strike_debuff_hero.lua", LUA_MODIFIER_MOTION_NONE)

function forged_spirit_melting_strike_hero:GetIntrinsicModifierName()
	return "modifier_melting_strike_hero"
end
