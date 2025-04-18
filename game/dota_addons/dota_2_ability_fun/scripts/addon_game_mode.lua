print( "Loading addon named Ability Draft AP Ranked." )

if CAbilityDraftRanked == nil then
    CAbilityDraftRanked = class({})
    _G.CAbilityDraftRanked = CAbilityDraftRanked
end

require( "libraries/array" )
require( "libraries/timers" )
require( "libraries/strings" )
require( "utility_functions" )
require( "database" )
require( "spells_upgrade_database" )
require( "filters" )
require( "events" )
require( "helper" )
require( "spells_upgrade" )
require( "libraries/httprequests" )
--require( "cosmetic_inventory" )

require("extensions/init")
require("utils/init")

_G.json = require( "libraries/json" )
_G._serverToken = tostring(GetDedicatedServerKeyV2("ad_ranked_2023"))

_G.playerColors = {
	player1R = 255,
	player1G = 0,
	player1B = 0,
	player2R = 255,
	player2G = 128,
	player2B = 0,
	player3R = 255,
	player3G = 255,
	player3B = 0,
	player4R = 128,
	player4G = 255,
	player4B = 0,
	player5R = 0,
	player5G = 255,
	player5B = 0,
	player6R = 0,
	player6G = 255,
	player6B = 128,
	player7R = 0,
	player7G = 255,
	player7B = 255,
	player8R = 0,
	player8G = 128,
	player8B = 255,
	player9R = 0,
	player9G = 0,
	player9B = 255,
	player10R = 128,
	player10G = 0,
	player10B = 255,
	player11R = 255,
	player11G = 0,
	player11B = 255,
	player12R = 255,
	player12G = 0,
	player12B = 128,
	player13R = 124,
	player13G = 216,
	player13B = 185,
	player14R = 225,
	player14G = 195,
	player14B = 185,
	player15R = 102,
	player15G = 51,
	player15B = 0,
	player16R = 51,
	player16G = 102,
	player16B = 0,
	player17R = 255,
	player17G = 204,
	player17B = 255,
	player18R = 102,
	player18G = 0,
	player18B = 0,
	player19R = 74,
	player19G = 24,
	player19B = 100,
	player20R = 204,
	player20G = 255,
	player20B = 255,
}
_G.EXCLUDED_HERO_BASESTATTALENTS = {
	special_bonus_hp_100 = true,
            special_bonus_hp_125 = true,
            special_bonus_hp_150 = true,
            special_bonus_hp_175 = true,
            special_bonus_hp_200 = true,
            special_bonus_hp_225 = true,
            special_bonus_hp_250 = true,
            special_bonus_hp_275 = true,
            special_bonus_hp_300 = true,
            special_bonus_hp_325 = true,
            special_bonus_hp_350 = true,
            special_bonus_hp_375 = true,
            special_bonus_hp_400 = true,
            special_bonus_hp_450 = true,
            special_bonus_hp_475 = true,
            special_bonus_hp_500 = true,
            special_bonus_hp_600 = true,
            special_bonus_hp_650 = true,
            special_bonus_hp_700 = true,
            special_bonus_hp_800 = true,
            special_bonus_hp_900 = true,
            special_bonus_hp_1000 = true,
            special_bonus_mp_100 = true,
            special_bonus_mp_125 = true,
            special_bonus_mp_150 = true,
            special_bonus_mp_175 = true,
            special_bonus_mp_200 = true,
            special_bonus_mp_225 = true,
            special_bonus_mp_250 = true,
            special_bonus_mp_275 = true,
            special_bonus_mp_300 = true,
            special_bonus_mp_350 = true,
            special_bonus_mp_400 = true,
            special_bonus_mp_500 = true,
            special_bonus_mp_600 = true,
            special_bonus_mp_700 = true,
            special_bonus_mp_800 = true,
            special_bonus_mp_1000 = true,
           special_bonus_base_attack_rate_1 = true,
            special_bonus_attack_speed_10 = true,
            special_bonus_attack_speed_15 = true,
           special_bonus_attack_speed_20 = true,
            special_bonus_attack_speed_25 = true,
            special_bonus_attack_speed_30 = true,
           special_bonus_attack_speed_35 = true,
           special_bonus_attack_speed_40 = true,
            special_bonus_attack_speed_45 = true,
            special_bonus_attack_speed_50 = true,
            special_bonus_attack_speed_55 = true,
            special_bonus_attack_speed_60 = true,
            special_bonus_attack_speed_70 = true,
            special_bonus_attack_speed_80 = true,
            special_bonus_attack_speed_90 = true,
            special_bonus_attack_speed_100 = true,
            special_bonus_attack_speed_110 = true,
            special_bonus_attack_speed_120 = true,
            special_bonus_attack_speed_140 = true,
            special_bonus_attack_speed_160 = true,
            special_bonus_attack_speed_175 = true,
            special_bonus_attack_speed_200 = true,
            special_bonus_attack_speed_225 = true,
            special_bonus_attack_speed_250 = true,
            special_bonus_corruption_25 = true,
            special_bonus_corruption_3 = true,
            special_bonus_corruption_4 = true,
            special_bonus_corruption_5 = true,
            special_bonus_cleave_15 = true,
            special_bonus_cleave_20 = true,
            special_bonus_cleave_25 = true,
            special_bonus_cleave_30 = true,
           special_bonus_cleave_35 = true,
           special_bonus_cleave_40 = true,
            special_bonus_cleave_60 = true,
            special_bonus_cleave_100 = true,
           special_bonus_cleave_130 = true,
            special_bonus_cleave_140 = true,
            special_bonus_cleave_150 = true,
            special_bonus_cleave_175 = true,
            special_bonus_haste = true,
            special_bonus_truestrike = true,
            special_bonus_spell_block_15 = true,
            special_bonus_spell_block_18 = true,
            special_bonus_spell_block_20 = true,
            special_bonus_mana_break_15 = true,
            special_bonus_mana_break_20 = true,
            special_bonus_mana_break_25 = true,
            special_bonus_mana_break_35 = true,
            special_bonus_mana_break_40 = true,
            special_bonus_spell_immunity = true,
            special_bonus_hp_regen_4 = true,
            special_bonus_hp_regen_5 = true,
            special_bonus_hp_regen_6 = true,
            special_bonus_hp_regen_7 = true,
            special_bonus_hp_regen_8 = true,
            special_bonus_hp_regen_10 = true,
            special_bonus_hp_regen_12 = true,
            special_bonus_hp_regen_14 = true,
            special_bonus_hp_regen_15 = true,
            special_bonus_hp_regen_16 = true,
            special_bonus_hp_regen_20 = true,
            special_bonus_hp_regen_25 = true,
            special_bonus_hp_regen_30 = true,
            special_bonus_hp_regen_35 = true,
            special_bonus_hp_regen_40 = true,
            special_bonus_hp_regen_50 = true,
            special_bonus_hp_regen_80 = true,
            special_bonus_mana_reduction_8 = true,
            special_bonus_mana_reduction_9 = true,
            special_bonus_mana_reduction_11 = true,
            special_bonus_mp_regen_amp_10 = true,
            special_bonus_mp_regen_1 = true,
            special_bonus_mp_regen_125 = true,
            special_bonus_mp_regen_150 = true,
            special_bonus_mp_regen_175 = true,
            special_bonus_mp_regen_2 = true,
            special_bonus_mp_regen_250 = true,
            special_bonus_mp_regen_4 = true,
            special_bonus_mp_regen_5 = true,
            special_bonus_mp_regen_3 = true,
            special_bonus_mp_regen_6 = true,
            special_bonus_mp_regen_8 = true,
            special_bonus_mp_regen_10 = true,
            special_bonus_mp_regen_14 = true,
            special_bonus_movement_speed_percentage_5 = true,
            special_bonus_movement_speed_percentage_6 = true,
            special_bonus_movement_speed_percentage_8 = true,
            special_bonus_movement_speed_percentage_10 = true,
            special_bonus_movement_speed_10 = true,
            special_bonus_movement_speed_15 = true,
            special_bonus_movement_speed_20 = true,
            special_bonus_movement_speed_25 = true,
            special_bonus_movement_speed_30 = true,
            special_bonus_movement_speed_35 = true,
            special_bonus_movement_speed_40 = true,
            special_bonus_movement_speed_45 = true,
            special_bonus_movement_speed_50 = true,
            special_bonus_movement_speed_60 = true,
            special_bonus_movement_speed_65 = true,
            special_bonus_movement_speed_75 = true,
            special_bonus_movement_speed_90 = true,
            special_bonus_movement_speed_100 = true,
            special_bonus_lifesteal_8 = true,
            special_bonus_lifesteal_10 = true,
            special_bonus_lifesteal_12 = true,
            special_bonus_lifesteal_15 = true,
            special_bonus_lifesteal_18 = true,
            special_bonus_lifesteal_20 = true,
            special_bonus_lifesteal_25 = true,
            special_bonus_lifesteal_30 = true,
            special_bonus_lifesteal_35 = true,
            special_bonus_lifesteal_40 = true,
            special_bonus_lifesteal_100 = true,
            special_bonus_all_stats_4 = true,
            special_bonus_all_stats_5 = true,
            special_bonus_all_stats_6 = true,
            special_bonus_all_stats_7 = true,
            special_bonus_all_stats_8 = true,
            special_bonus_all_stats_10 = true,
            special_bonus_all_stats_12 = true,
            special_bonus_all_stats_14 = true,
            special_bonus_all_stats_15 = true,
            special_bonus_all_stats_20 = true,
            special_bonus_agility_and_intelligence_6 = true,
            special_bonus_intelligence_6 = true,
            special_bonus_intelligence_7 = true,
            special_bonus_intelligence_8 = true,
            special_bonus_intelligence_10 = true,
            special_bonus_intelligence_12 = true,
            special_bonus_intelligence_13 = true,
            special_bonus_intelligence_14 = true,
            special_bonus_intelligence_15 = true,
            special_bonus_intelligence_16 = true,
            special_bonus_intelligence_20 = true,
            special_bonus_intelligence_25 = true,
            special_bonus_intelligence_30 = true,
            special_bonus_intelligence_35 = true,
            special_bonus_intelligence_75 = true,
            special_bonus_spell_lifesteal_6 = true,
            special_bonus_spell_lifesteal_8 = true,
            special_bonus_spell_lifesteal_10 = true,
            special_bonus_spell_lifesteal_12 = true,
            special_bonus_spell_lifesteal_13 = true,
            special_bonus_spell_lifesteal_15 = true,
            special_bonus_spell_lifesteal_20 = true,
            special_bonus_spell_lifesteal_25 = true,
            special_bonus_spell_lifesteal_30 = true,
            special_bonus_spell_lifesteal_40 = true,
            special_bonus_spell_lifesteal_50 = true,
            special_bonus_spell_lifesteal_60 = true,
            special_bonus_spell_lifesteal_70 = true,
            special_bonus_strength_3 = true,
            special_bonus_strength_4 = true,
            special_bonus_strength_5 = true,
            special_bonus_strength_6 = true,
            special_bonus_strength_7 = true,
            special_bonus_strength_8 = true,
            special_bonus_strength_9 = true,
            special_bonus_strength_10 = true,
            special_bonus_strength_11 = true,
            special_bonus_strength_12 = true,
            special_bonus_strength_13 = true,
            special_bonus_strength_14 = true,
            special_bonus_strength_15 = true,
            special_bonus_strength_16 = true,
            special_bonus_strength_18 = true,
            special_bonus_strength_20 = true,
            special_bonus_strength_25 = true,
            special_bonus_strength_30 = true,
            special_bonus_strength_35 = true,
            special_bonus_strength_40 = true,
            special_bonus_agility_5 = true,
            special_bonus_agility_6 = true,
            special_bonus_agility_7 = true,
            special_bonus_agility_8 = true,
            special_bonus_agility_9 = true,
            special_bonus_agility_10 = true,
            special_bonus_agility_12 = true,
            special_bonus_agility_13 = true,
            special_bonus_agility_14 = true,
            special_bonus_agility_15 = true,
            special_bonus_agility_16 = true,
            special_bonus_agility_20 = true,
            special_bonus_agility_25 = true,
            special_bonus_agility_30 = true,
            special_bonus_agility_40 = true,
            special_bonus_agility_80 = true,
            special_bonus_agility_100 = true,
            special_bonus_armor_2 = true,
            special_bonus_armor_3 = true,
            special_bonus_armor_4 = true,
            special_bonus_armor_5 = true,
            special_bonus_armor_6 = true,
            special_bonus_armor_7 = true,
            special_bonus_armor_8 = true,
            special_bonus_armor_9 = true,
            special_bonus_armor_10 = true,
            special_bonus_armor_12 = true,
            special_bonus_armor_15 = true,
            special_bonus_armor_20 = true,
            special_bonus_armor_30 = true,
            special_bonus_status_resistance_10 = true,
            special_bonus_status_resistance_15 = true,
            special_bonus_status_resistance_20 = true,
            special_bonus_status_resistance_25 = true,
            special_bonus_magic_resistance_5 = true,
            special_bonus_magic_resistance_6 = true,
            special_bonus_magic_resistance_8 = true,
            special_bonus_magic_resistance_10 = true,
            special_bonus_magic_resistance_12 = true,
            special_bonus_magic_resistance_14 = true,
            special_bonus_magic_resistance_15 = true,
            special_bonus_magic_resistance_20 = true,
            special_bonus_magic_resistance_25 = true,
            special_bonus_magic_resistance_30 = true,
            special_bonus_magic_resistance_35 = true,
            special_bonus_magic_resistance_40 = true,
            special_bonus_magic_resistance_50 = true,
            special_bonus_magic_resistance_80 = true,
           special_bonus_magic_resistance_100 = true,
            special_bonus_day_vision_400 = true,
            special_bonus_night_vision_400 = true,
            special_bonus_night_vision_500 = true,
            special_bonus_night_vision_600 = true,
            special_bonus_night_vision_800 = true,
            special_bonus_night_vision_1000 = true,
            special_bonus_vision_200 = true,
            special_bonus_attack_damage_10 = true,
            special_bonus_attack_damage_12 = true,
            special_bonus_attack_damage_15 = true,
            special_bonus_attack_damage_16 = true,
            special_bonus_attack_damage_18 = true,
            special_bonus_attack_damage_20 = true,
            special_bonus_attack_damage_25 = true,
            special_bonus_attack_damage_30 = true,
            special_bonus_attack_damage_35 = true,
            special_bonus_attack_damage_40 = true,
            special_bonus_attack_damage_45 = true,
            special_bonus_attack_damage_50 = true,
            special_bonus_attack_damage_55 = true,
            special_bonus_attack_damage_60 = true,
            special_bonus_attack_damage_65 = true,
            special_bonus_attack_damage_70 = true,
            special_bonus_attack_damage_75 = true,
            special_bonus_attack_damage_80 = true,
            special_bonus_attack_damage_90 = true,
            special_bonus_attack_damage_100 = true,
            special_bonus_attack_damage_120 = true,
            special_bonus_attack_damage_150 = true,
            special_bonus_attack_damage_160 = true,
            special_bonus_attack_damage_200 = true,
            special_bonus_attack_damage_250 = true,
            special_bonus_attack_damage_251 = true,
            special_bonus_attack_damage_252 = true,
            special_bonus_attack_damage_400 = true,
            special_bonus_attack_base_damage_15 = true,
            special_bonus_attack_base_damage_20 = true,
            special_bonus_attack_base_damage_25 = true,
            special_bonus_attack_base_damage_30 = true,
            special_bonus_attack_base_damage_40 = true,
            special_bonus_attack_base_damage_45 = true,
            special_bonus_attack_base_damage_50 = true,
            special_bonus_attack_base_damage_100 = true,
            special_bonus_cast_speed_30 = true,
            special_bonus_attack_range_50 = true,
            special_bonus_attack_range_75 = true,
            special_bonus_attack_range_100 = true,
            special_bonus_attack_range_125 = true,
            special_bonus_attack_range_150 = true,
            special_bonus_attack_range_175 = true,
            special_bonus_attack_range_200 = true,
            special_bonus_attack_range_250 = true,
            special_bonus_attack_range_275 = true,
            special_bonus_attack_range_300 = true,
            special_bonus_attack_range_325 = true,
            special_bonus_attack_range_400 = true,
            special_bonus_cast_range_50 = true,
            special_bonus_cast_range_60 = true,
            special_bonus_cast_range_75 = true,
            special_bonus_cast_range_100 = true,
            special_bonus_cast_range_125 = true,
            special_bonus_cast_range_150 = true,
            special_bonus_cast_range_175 = true,
            special_bonus_cast_range_200 = true,
            special_bonus_cast_range_225 = true,
            special_bonus_cast_range_250 = true,
            special_bonus_cast_range_275 = true,
            special_bonus_cast_range_300 = true,
            special_bonus_cast_range_325 = true,
            special_bonus_cast_range_350 = true,
            special_bonus_cast_range_400 = true,
            special_bonus_spell_amplify_3 = true,
            special_bonus_spell_amplify_4 = true,
            special_bonus_spell_amplify_5 = true,
            special_bonus_spell_amplify_6 = true,
            special_bonus_spell_amplify_7 = true,
            special_bonus_spell_amplify_8 = true,
            special_bonus_spell_amplify_9 = true,
            special_bonus_spell_amplify_10 = true,
            special_bonus_spell_amplify_1 = true,
            special_bonus_spell_amplify_12 = true,
            special_bonus_spell_amplify_14 = true,
            special_bonus_spell_amplify_15 = true,
            special_bonus_spell_amplify_16 = true,
            special_bonus_spell_amplify_18 = true,
            special_bonus_spell_amplify_20 = true,
            special_bonus_spell_amplify_25 = true,
            special_bonus_cooldown_reduction_6 = true,
            special_bonus_cooldown_reduction_8 = true,
            special_bonus_cooldown_reduction_10 = true,
            special_bonus_cooldown_reduction_12 = true,
            special_bonus_cooldown_reduction_14 = true,
            special_bonus_cooldown_reduction_15 = true,
            special_bonus_cooldown_reduction_20 = true,
            special_bonus_cooldown_reduction_25 = true,
            special_bonus_cooldown_reduction_30 = true,
            special_bonus_cooldown_reduction_40 = true,
            special_bonus_cooldown_reduction_50 = true,
            special_bonus_cooldown_reduction_65 = true,
            special_bonus_respawn_reduction_15 = true,
            special_bonus_respawn_reduction_20 = true,
            special_bonus_respawn_reduction_25 = true,
            special_bonus_respawn_reduction_30 = true,
            special_bonus_respawn_reduction_35 = true,
            special_bonus_respawn_reduction_40 = true,
            special_bonus_respawn_reduction_45 = true,
            special_bonus_respawn_reduction_50 = true,
            special_bonus_respawn_reduction_60 = true,
            special_bonus_gold_income_30 = true,
            special_bonus_gold_income_60 = true,
            special_bonus_gold_income_90 = true,
            special_bonus_gold_income_120 = true,
            special_bonus_gold_income_150 = true,
            special_bonus_gold_income_180 = true,
            special_bonus_gold_income_210 = true,
            special_bonus_gold_income_240 = true,
            special_bonus_gold_income_300 = true,
            special_bonus_gold_income_420 = true,
            special_bonus_evasion_8 = true,
            special_bonus_evasion_10 = true,
            special_bonus_evasion_12 = true,
            special_bonus_evasion_15 = true,
            special_bonus_evasion_16 = true,
            special_bonus_evasion_20 = true,
            special_bonus_evasion_25 = true,
            special_bonus_evasion_30 = true,
            special_bonus_evasion_40 = true,
            special_bonus_evasion_50 = true,
            special_bonus_evasion_75 = true,
            special_bonus_20_bash_2 = true,
            special_bonus_24_crit_2 = true,
            special_bonus_30_crit_2 = true,
            special_bonus_20_crit_15 = true,
            special_bonus_50_crit_40 = true,
            special_bonus_exp_boost_5 = true,
            special_bonus_exp_boost_10 = true,
            special_bonus_exp_boost_15 = true,
            special_bonus_exp_boost_20 = true,
            special_bonus_exp_boost_25 = true,
            special_bonus_exp_boost_30 = true,
            special_bonus_exp_boost_35 = true,
            special_bonus_exp_boost_40 = true,
            special_bonus_exp_boost_50 = true,
            special_bonus_exp_boost_60 = true,
}

-- Precache resources
LinkLuaModifier( "modifier_player_ability_checker", "modifiers/players/modifier_player_ability_checker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_collect_stats", "modifiers/players/modifier_generic_collect_stats", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_starbreaker_effect_only", "modifiers/heroes/dawnbreaker/modifier_dawnbreaker_starbreaker_effect_only", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_z_delta_visual", "modifiers/modifier_z_delta_visual", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_model_scale_ad_2023", "modifiers/modifier_model_scale_ad_2023", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fix_death_units_crash_modifiers", "modifiers/modifier_fix_death_units_crash_modifiers", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_unslowable_2023", "modifiers/modifier_unslowable_2023", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_model_change_visual", "modifiers/modifier_model_change_visual", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_strong_illusion_hoodwink_ult", "modifiers/illusion/modifier_strong_illusion_hoodwink_ult", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_provides_vision_strong", "modifiers/modifier_provides_vision_strong", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dummy_unit_map_icon", "modifiers/modifier_dummy_unit_map_icon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_value_upgrades_sb_2023", "modifiers/special_upgrades/modifier_ability_value_upgrades_sb_2023", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_spirit_bear_upgrades_ad_2023", "modifiers/heroes/lone_druid/modifier_spirit_bear_upgrades_ad_2023", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_summoned_unit_bat_upgrade_ad_2023", "modifiers/special_upgrades/modifier_summoned_unit_bat_upgrade_ad_2023", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_hero_ability_modified_ad_2023", "modifiers/special_upgrades/modifier_hero_ability_modified_ad_2023", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_fake_ally_ad_2023", "modifiers/modifier_fake_ally_ad_2023", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier( "modifier_cosmetic_inventory_sb2023", "modifiers/cosmetic_inventory/modifier_cosmetic_inventory_sb2023", LUA_MODIFIER_MOTION_NONE )


function Precache( context )
    --sound
    PrecacheResource( "soundfile", "soundevents/game_sounds_hero_pick.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_broodmother.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/ability_draft_sounds.vsndevts", context )

	--High five
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl1_overhead.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_impact.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_customlvl1_overhead.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl1_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_impact.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl1_overhead.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_impact.vpcf", context)
	PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_customlvl1_overhead.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl1_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_impact.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl2_overhead_custom.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl2_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl2_impact.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl3_overhead.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/ti10/high_five/high_five_lvl3_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/plus/high_five/high_five_lvl3_hearts_impact.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/newbloom_2024/high_five_customnewbloom_dragon_overhead.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/newbloom_2024/high_five_custom_newbloom_dragon_dire_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/events/newbloom_2020/high_five_newbloom_impact.vpcf", context)
    PrecacheResource( "particle", "particles/econ/misc/high_five/aghanim_puppet_2021/high_five_agh_2021_overhead.vpcf", context)
    PrecacheResource( "particle", "particles/econ/misc/high_five/aghanim_puppet_2021/high_five_agh_2021_travel.vpcf", context)
    PrecacheResource( "particle", "particles/econ/misc/high_five/aghanim_puppet_2021/high_five_agh_2021_impact.vpcf", context)
	
	PrecacheResource( "particle", "particles/scream/axe_battle_hunger.vpcf", context)
	PrecacheResource( "particle", "particles/healthburn/nyx_assassin_mana_burn.vpcf", context)

	PrecacheResource( "model", "models/heroes/furion/treant.vmdl", context)
	PrecacheResource( "model", "models/heroes/lycan/lycan_wolf.vmdl", context)
	PrecacheResource( "model", "models/heroes/juggernaut/jugg_healing_ward.vmdl", context)
	PrecacheResource( "model", "models/heroes/lich/ice_spire.vmdl", context)
	PrecacheResource( "model", "models/props_gameplay/frog.vmdl", context)
	PrecacheResource( "model", "models/props_gameplay/chicken.vmdl", context)
	PrecacheResource( "model", "models/heroes/shadowshaman/shadowshaman_totem.vmdl", context)
	PrecacheResource( "model", "models/heroes/enigma/eidelon.vmdl", context)
	PrecacheResource( "model", "models/heroes/warlock/warlock_demon.vmdl", context)
	PrecacheResource( "model", "models/heroes/beastmaster/beastmaster_bird.vmdl", context)
	PrecacheResource( "model", "models/heroes/beastmaster/beastmaster_beast.vmdl", context)
	PrecacheResource( "model", "models/heroes/doom/doom.vmdl", context)

end


function Activate()
    GameRules.AbilityDraftRanked = CAbilityDraftRanked()
    GameRules.AbilityDraftRanked:InitGameMode()
end

function CAbilityDraftRanked:InitGameMode()
    self.realPlayerHeroes = {}
    self.maxPlayers = 20
    self.heroMaxLevel = 30
    self.basePlayerMMR = 1500
    self.acceptedMaxMMRDiff = 100

    --test MMR
    self.fakePlayersMMR = {
        [0] = 100,
        [1] = 1050,
        [2] = 1600,
        [3] = 1675,
        [4] = 3850,

        [5] = 300,
        [6] = 600,
        [7] = 1000,
        [8] = 800,
        [9] = 350,
        [10] = 650,
        [11] = 200,

        [12] = 2100,
        [13] = 600,
        [14] = 500,
        [15] = 500,
        [16] = 100,
        [17] = 100,
    }

	--Cosmetic Inventory
    --self.cosmeticInventory = CCosmeticInventory()
    --self.cosmeticInventory:Init(self)


	--keybinds
	self.playersCustomKeyBinds = {}
	self.customKeyBindsRecreated = {}

    --test data
    self.testMinDiffMMR = 0
    self.testAllPlayers = {}
    self.testSortedPlayers = {}
    self.testMaxAttempts = 0
    self.testUsedAttempts = 0
    self.testFirstPlayerMaxMMR = 0
    self.testPartyMMR = false

    self.currentTime = 0
    self.currentTimer = 1
    self.adjustedTime = 0

    self.baseGoldenTreasureChance = 15

    self.jungleCrepsBaseDropChance = 50
    self.ancientCreepsBaseDropChance = 60

	self.teamGoodGuysAmount = 0
	self.teamBadGuysAmount = 0

    self.extraGoldenTreasureChance = {
        [DOTA_TEAM_GOODGUYS] = self.baseGoldenTreasureChance,
        [DOTA_TEAM_BADGUYS] = self.baseGoldenTreasureChance,
    }

    self.jungleCreepsTreasureChance = {
        [DOTA_TEAM_GOODGUYS] = {
            ancients = self.ancientCreepsBaseDropChance,
            small_ancients = self.jungleCrepsBaseDropChance,
            normal = self.jungleCrepsBaseDropChance,
        },

        [DOTA_TEAM_BADGUYS] = {
            ancients = self.ancientCreepsBaseDropChance,
            small_ancients = self.jungleCrepsBaseDropChance,
            normal = self.jungleCrepsBaseDropChance,
        }
    }

    self.playerLevel30TreasureChanceIncrease = 10

    --new Jungle Treasures Drop System:
    
    self.jungleTreasureLimitIncreasePerInterval = 0
    self.jungleTreasureLimitIncreaseInterval = 80

    self.jungleTreasuresLimit = {
        [DOTA_TEAM_GOODGUYS] = 0,
        [DOTA_TEAM_BADGUYS] = 0,
    }

    self.jungleTreasuresDropped = {
        [DOTA_TEAM_GOODGUYS] = 0,
        [DOTA_TEAM_BADGUYS] = 0,
    }

    self.standardHeroRerolls = 1
    self.standardTalentRerolls = 1
    self.standardSkipAbilityUpgrades = 5
    self.standardGoldenAbilityUpgrades = 3
    self.standardAbilityUpgradeRerolls = 2

	self.balanceShuffleCooldown = 0

    --0 means radiant team
    --1 means dire team
    self.playersTeam = {
        radiant = {},
        dire = {}
    }

    --tree talents
    self.allSelectedHeroTalents = {
        level_1 = {},
        level_2 = {},
        level_3 = {},
        level_4 = {},
    }
    
    self.heroBaseTalents = {}
    self.playersTreeTalents = {}
    self.playersPickedTalents = {}
    self.talentsLevelCount = 10

    --picked abilities
    self.playersPickedAbilities = {}
    self.playersPickedAbilitiesCount = {}

    --ability options
    self.allUsedAbilityHeroNames = {}
    
    self.availableAbilities = {
        base = {},
        ultimate = {},
        jungle = {},
    }

    self._vPlayerStats = {}
    
    self.heroPickingTime = 61
    
    self.abilityPreRoundTime = 30
    self.abilityBanTime = 20
    self.abilityPickTime = 8
    self.abilityPostRoundTime = 45

    self.totalAbilityPickRounds = 4

    self.abilityPickRound1 = 1
    self.abilityPickRound2 = 1
    self.abilityPickRound3 = 1
    self.abilityPickRound4 = 1

    self.heroesAbilityCount = 18
    self.jungleAbilityCount = 18
    self.abilityPerPlayer = 4
    self.extraUlts = 0

    self.abilityBanVotes = {}
    self.maxTotalAbilityBans = 18
    self.maxBaseAbilityBans = 14
    self.maxUltimateAbilityBans = 6
    --self.maxTotalAbilityBans = 18
    --self.maxBaseAbilityBans = 8
    --self.maxUltimateAbilityBans = 6
    
    self.hasBanned = {}
    
    -- expected time for 20 players, will be updated when players connect to the game (20 * 4 * 7 = 560)
    self.abilityRoundExpectedTime =  self.maxPlayers * self.totalAbilityPickRounds * self.abilityPickTime
    
    --this value is used only to GameRules:SetHeroSelectionTime() but when all players pick hero (after picking abilities round) game will end hero selection
    self.totalDraftExpectedTime = self.heroPickingTime + self.abilityPreRoundTime + self.abilityBanTime + self.abilityRoundExpectedTime + self.abilityPostRoundTime + 10
    
    -- selection phases
    -- 0 - hero selection
    -- 1 - ability pre selection
    -- 2 - ability selection
    -- 3 - ability post selection
    self.selectionPhaseTimers = {
        [0] = self.heroPickingTime,
        [1] = self.abilityPreRoundTime,
        [2] = self.abilityBanTime,
        [3] = self.abilityRoundExpectedTime,
        [4] = self.abilityPostRoundTime,
    }
    
    self.currentSelectionPhase = 0
    self.currentSelectionTimer = 0
    
    --Hero selection (picks are saved but heroes are assigned to players at the end of ability picking)
    --It allows to manage hero and ability picks during DOTA_GAMERULES_STATE_HERO_SELECTION and have pre-game strategy screen at the end
    self.reservedHerosForPlayers = {}
    self.reservedHeroNames = {}
    self.heroRerollQueue = {}
    
    self.playersHeroPicks = {}
    self.playersHeroPicksConfirm = {}
    self.allPickedHeroNames = {}

    --based on self.playersHeroPicks (heroes selected in game for players)
    self.playersHeroSelected = {}

    --player pick order
    self.playersIdPickOrder = {}

    self.playersPickOrder = {
        order = {},
        current_player_pick = {},
        pick_time = 0,
        end_picking_time = 0,
        draft_end = 0,
        base_pick_time = 0,
        picks_per_round = 0,
        pick_rounds = 0,
    }

    --flags
    self.allPlayersPickedHeroes = false
    self.randomAbilitiesChosen = false
    self.allPlayersSelectedHeroes = false
    self.playerPickOrderChosen = false
    self.allUsedHeroesPrecached = false
    self.abilityDraftPickingEnd = false

    self.precachedUnits = {}
    self.heroAbilityOwners = {}

    --abilities set for player when game start (or when player reconnect) true/false
    self.playersAbilityModified = {}

    --orders
    self.playerLoseItemOrders = {
        [DOTA_UNIT_ORDER_DROP_ITEM] = true,
        [DOTA_UNIT_ORDER_GIVE_ITEM] = true,
        [DOTA_UNIT_ORDER_SELL_ITEM] = true,
        [DOTA_UNIT_ORDER_DROP_ITEM_AT_FOUNTAIN] = true
    }

    self.unitSpellOrders = {
        [DOTA_UNIT_ORDER_CAST_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        [DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
    }

    self.stoneworkArtifactNoCritAbilities = {
        --abilities
        muerta_pierce_the_veil = true,
        tidehunter_anchor_smash = true,
        monkey_king_boundless_strike = true,
        black_dragon_splash_attack_hero = true,

        --items
        item_bogduggs_cudgel = true,
        item_bfury = true,
    }

    self.bossRespawnBoost = {
        hp = 2500,
        dmg = 50,
        armor = 10,
        magic_armor = 10,
    }

    --Spells Upgrade
    self.spellsUpgrade = CDungeonSpellsUpgrade()
    self.spellsUpgrade:Init( self )

    self.extraUltimateAbilitiesPicked = {}
    self.specialAbilityModifierUpgradesAdded = {}
    
    --server reconnect last attempt time
    self.minIntervalToServerConnection = 7
    self.playersServerReconnectTry = {}

	--Cosmetic Inventory
	--self.cosmeticInventory = CCosmeticInventory()
	--self.cosmeticInventory:Init(self)

	--self.musicSoundEmitersData = {}

    --create dummy unit to collect statistics
    local statsUnit = CreateUnitByName("npc_dota_statistics_dummy", Vector(-8000, -7600, 950), false, nil, nil, DOTA_TEAM_GOODGUYS)
    if statsUnit then
        statsUnit:AddNewModifier(statsUnit, nil, "modifier_generic_collect_stats", {})
    end

    GameRules:SetCustomGameSetupTimeout( 60 )
    GameRules:SetCustomGameSetupAutoLaunchDelay( 60 )

    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 10 )

    GameRules:SetHeroSelectionTime(self.totalDraftExpectedTime)
    GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride(self.totalDraftExpectedTime)
    
    GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
    GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( false )
    GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic( true )
    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
    GameRules:GetGameModeEntity():DisableClumpingBehaviorByDefault( true )
    GameRules:GetGameModeEntity():DisableHudFlip( true )
    GameRules:GetGameModeEntity():SetPlayerHeroAvailabilityFiltered( true )
    GameRules:SetHideBlacklistedHeroes(true)
    GameRules:SetTimeOfDay(0.251)
    
    --turbo options
    GameRules:SetUseUniversalShopMode(true)
    GameRules:GetGameModeEntity():SetCanSellAnywhere(true)
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
    GameRules:GetGameModeEntity():SetUseTurboCouriers(true)
    GameRules:GetGameModeEntity():SetRespawnTimeScale(0.6)
    GameRules:GetGameModeEntity():SetCustomGlyphCooldown(180)
    GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:SetStartingGold( 1000 )
    GameRules:SetPreGameTime(60)
    GameRules:SetStrategyTime(20)
    GameRules:SetShowcaseTime(0)

    self.turboUpgradeInterval = 150 -- 2.5 minutes
    self.turboGoldMultiplier = 2.0
    self.turboXPModifier = 1.5
    self.turboBuybackTime = 300
    self.maxCreepsUpgradeMultiplier = 55
    
    self.teamTowersStatus = {
        [DOTA_TEAM_GOODGUYS] = {
            top = {
                owned = 0,
                lost = 0,
            },
            mid = {
                owned = 0,
                lost = 0,
            },
            bot = {
                owned = 0,
                lost = 0,
            },
        },
        [DOTA_TEAM_BADGUYS] = {
            top = {
                owned = 0,
                lost = 0,
            },
            mid = {
                owned = 0,
                lost = 0,
            },
            bot = {
                owned = 0,
                lost = 0,
            },
        },
    }
    
    self.towersForwardVector = {}
    
    --save towers forward 
    --update tower abilities
    local towers = Entities:FindAllByClassname("npc_dota_tower")

    for _, tower in pairs(towers) do    
        local towerName = tower:GetUnitName()

        self.towersForwardVector[towerName] = tower:GetForwardVector()

        if tower:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            self.towersForwardVector[towerName] = tower:GetForwardVector() * -1
        end

        if not self.teamTowersStatus[tower:GetTeamNumber()] then
            self.teamTowersStatus[tower:GetTeamNumber()] = {}
        end
    end

    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CAbilityDraftRanked, 'OnGameRulesStateChange' ), self )
    ListenToGameEvent( "dota_player_reconnected", Dynamic_Wrap( CAbilityDraftRanked, 'OnPlayerReconnected' ), self )
    ListenToGameEvent( "player_chat", Dynamic_Wrap( CAbilityDraftRanked, "OnPlayerChat" ), self )
    ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CAbilityDraftRanked, "OnPlayerPickHero" ), self )
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CAbilityDraftRanked, "OnNPCSpawned" ), self )
    ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CAbilityDraftRanked, "OnPlayerDisconnect" ), self )
    ListenToGameEvent( "dota_match_done", Dynamic_Wrap( CAbilityDraftRanked, "OnMatchDone" ), self )
    --ListenToGameEvent( "dota_rune_activated_server", Dynamic_Wrap( CAbilityDraftRanked, "OnRunePickUp" ), self )
    ListenToGameEvent( "entity_killed", Dynamic_Wrap( CAbilityDraftRanked, 'OnEntityKilled' ), self )
    ListenToGameEvent( "dota_buyback", Dynamic_Wrap( CAbilityDraftRanked, 'OnBuyBack' ), self )
    ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( CAbilityDraftRanked, "OnPlayerGainedLevel" ), self )

    -- Filter Registration: Functions are found in filters.lua
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( CAbilityDraftRanked, "ExecuteOrderFilter" ), self )
    GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap( CAbilityDraftRanked, "ModifierGainedFilter" ), self )
    GameRules:GetGameModeEntity():SetModifyGoldFilter( Dynamic_Wrap( CAbilityDraftRanked, "ModifyGoldFilter" ), self )
    GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( CAbilityDraftRanked, "DamageFilter" ), self )
    GameRules:GetGameModeEntity():SetModifyExperienceFilter( Dynamic_Wrap( CAbilityDraftRanked, "ModifyExperienceFilter" ), self )
    GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( CAbilityDraftRanked, "ModifyBountyRuneFilter" ), self )
    GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap( CAbilityDraftRanked, "ItemAddedToInventoryFilter" ), self )
    GameRules:GetGameModeEntity():SetTrackingProjectileFilter( Dynamic_Wrap( CAbilityDraftRanked, "TrackingProjectileFilter" ), self )

    --spell upgrades
    CustomGameEventManager:RegisterListener( "ability_upgrades_localizated", function(...) return self.spellsUpgrade:AbilityUpgradesLocalizated( ... ) end)
    CustomGameEventManager:RegisterListener( "ability_upgrade_chosen", function(...) return self.spellsUpgrade:AbilityUpgradePick( ... ) end)
    CustomGameEventManager:RegisterListener( "ability_upgrades_reroll", function(...) return self.spellsUpgrade:AbilityUpgradeReroll( ... ) end )
    CustomGameEventManager:RegisterListener( "skip_reward_upgrade", function(...) return self.spellsUpgrade:SkipRewardUpgrades( ... ) end )

    CustomGameEventManager:RegisterListener( "server_reconnect", function(...) return self:ServerReconnect( ... ) end)
    CustomGameEventManager:RegisterListener( "custom_key_bind_set", function(...) return self:OnCustomKeyBindSet( ... ) end )
    CustomGameEventManager:RegisterListener( "custom_key_bind_removed", function(...) return self:OnCustomKeyBindRemoved( ... ) end )
    CustomGameEventManager:RegisterListener( "custom_key_bind_quick_cast", function(...) return self:OnCustomKeyBindQuickCast( ... ) end )

    GameRules:GetGameModeEntity():SetThink( "DisconnectAbandonPlayerThink", self, "DisconnectAbandonPlayerThinker", 1 )

    self.playersAvailableCommands = {
        normal = {},

        cheats = {
            {
                ["-drop_treasure x y z"] = "Testing Golden Treasures (x: [0-4], y: [0-1], z[0-1])"
            },
        }
    }

    self.cheatModeRestrictedCommand = {
        ["-drop_treasure"] = true,
    }
end

function CAbilityDraftRanked:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()

    if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        print( "OnGameRulesStateChange: Game Setup" )
        self:CreateInitialPlayerStats()


    elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        print( "OnGameRulesStateChange: Hero Selection" )

        self:LoadAbilityDraftData(1)

		GameRules:GetGameModeEntity():SetPauseEnabled(true)
        
    elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        --print( "OnGameRulesStateChange: Strategy Time" )

    elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        --print( "OnGameRulesStateChange: Pre Game" )

        --add extra abiliites for 10/20/30 level treasures
        --base abilities
        local availableHeroes = self:GetAllAvailableHeroNames()
        self:SelectRandomHeroAbilitiesToPick(availableHeroes, nil)

        --jungle abilities
        local jungleAbilities = self:GetAllNotSelectedJungleAbilities()
        if jungleAbilities then
            self:SelectRandomJungleAbilitiesToPick(#jungleAbilities, true)
        end
        
        -- Timers:CreateTimer(1.5, function ()
        --  self:SavePickedAbilitiesAndTalents(1)
        -- end)

    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        --print( "OnGameRulesStateChange: Game In Progress" )

        --neutral for jungler
        GameRules:SpawnNeutralCreeps()

        --last XP gain on start for checking AFK
        local allPlayers = self:GetAllPlayersConnectedFromLobby()

        for team, _ in pairs(self.jungleTreasuresLimit) do
            self.jungleTreasuresLimit[team] = self.jungleTreasureLimitIncreasePerInterval

            local currentDrop = 0
            if self.jungleTreasuresDropped[team] then
                currentDrop = self.jungleTreasuresDropped[team]
            end
            
            CustomNetTables:SetTableValue( "jungle_treasures_limit", string.format( "%d", team ), {limit = self.jungleTreasuresLimit[team], dropped = currentDrop})
        end

        GameRules:GetGameModeEntity():SetThink( "JungleTreasuresLimitThink", self, "JungleTreasuresLimitThinker", self.jungleTreasureLimitIncreaseInterval )
        GameRules:GetGameModeEntity():SetThink( "treasurePerMinuteThink", self, "treasurePerMinuteThinker", self.currentTimer )

    elseif nNewState == DOTA_GAMERULES_STATE_POST_GAME then
        print( "OnGameRulesStateChange: Game End" )
    elseif nNewState == DOTA_GAMERULES_STATE_DISCONNECT  then
        print( "OnGameRulesStateChange: Game Disconnect" )
    end
end
        
function CAbilityDraftRanked:SavePickedAbilitiesAndTalents(attemptNumber)
    -- if attemptNumber >= 10 then
    --  return
    -- end

    --check if data is available for all players
    -- local isDataAvailable = true

    -- for playerID = 0, self.maxPlayers - 1, 1 do
    --  if PlayerResource:IsValidPlayerID(playerID) then
    --      if not PlayerResource:GetSelectedHeroEntity(playerID) then
    --          isDataAvailable = false
    --          break
    --      end
    --  end
    -- end

    -- if not isDataAvailable then
    --  Timers:CreateTimer(0.5, function ()
    --      self:SavePickedAbilitiesAndTalents(attemptNumber + 1)
    --  end)

    --  return
    -- end

    local data = {
        match_id = tostring(GameRules:Script_GetMatchID()),
        name = "mmr_test",
        ad_picked_data = {
            mmr_diff = self.testMinDiffMMR,
            all_players = self.testAllPlayers,
            sorted_players = self.testSortedPlayers,
            max_attempts = self.testMaxAttempts,
            used_attempts = self.testUsedAttempts,
            max_mmr = self.testFirstPlayerMaxMMR,
            party_mmr = self.testPartyMMR,
        }
    }


    -- for playerID, abilityData in pairs(self.playersPickedAbilities) do
    --  local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    --  if hero then
    --      local heroName = hero:GetUnitName()

    --      if heroName then
    --          if not data["ad_picked_data"][heroName] then
    --              data["ad_picked_data"][heroName] = {
    --                  abilities = {},
    --                  talents = {}
    --              }
    --          end
    
    --          for _, abilities in ipairs(abilityData) do
    --              local abilityName = abilities["ability_name"]
                
    --              table.insert(data["ad_picked_data"][heroName]["abilities"], abilityName)
    --          end
        
    --          --talents
    --          local abilityCount = 32
    --          local talentsCount = 0
    
    --          if hero then
    --              for i = 0, abilityCount - 1 , 1 do
    --                  local ability = hero:GetAbilityByIndex(i)
                
    --                  if ability and ability:IsAttributeBonus() and string.find(ability:GetAbilityName(), "special_bonus") and ability:GetAbilityName() ~= "special_bonus_attributes" then
    --                      table.insert(data["ad_picked_data"][heroName]["talents"], ability:GetAbilityName())
    --                      talentsCount = talentsCount + 1
    --                  end
    --              end
                    
    --          end

    --          data["ad_picked_data"][heroName]["talentsCount"] = talentsCount
    --      end
    --  end
    -- end

    _HTTPConnection:updateMatchTestData(data, 0)
end

function CAbilityDraftRanked:AddBossRandomRelicItem(hBoss, spawnNumber)
    local itemsNumber = math.min(spawnNumber, 2)

    if not hBoss or hBoss:IsNull() then
        return
    end

    local bossKeyValues = GetUnitKeyValuesByName(hBoss:GetUnitName())

    if (not bossKeyValues or not bossKeyValues["Creature"] or not bossKeyValues["Creature"]["Relics_Custom_Drop"] or
        not bossKeyValues["Creature"]["Relics_Custom_Drop"]["Item"])
    then
        print("no boss relic items")
        return
    end

    local relicsList = bossKeyValues["Creature"]["Relics_Custom_Drop"]["Item"]

    local relicTable = {}
    for _, relicName in pairs(relicsList) do
        table.insert(relicTable, relicName)
    end

    for i = 1, itemsNumber, 1 do
        if #relicTable > 0 then
            local randomIndex = RandomInt(1, #relicTable)
            local randomRelicName = relicTable[randomIndex]

            if randomRelicName and not hBoss:HasItemInInventory(randomRelicName) then
                hBoss:AddItemByName(randomRelicName)
            end

            table.remove(relicTable, randomIndex)
        end
    end

end

function CAbilityDraftRanked:LoadAbilityDraftData(attemptNumber)
    --waiting until data from server is fetched!
    if not self.playersDataFetched and attemptNumber <= 4 then
        Timers:CreateTimer(0.25 * (attemptNumber + 1), function ()
            self:LoadAbilityDraftData(attemptNumber + 1)
        end)

        return
    end

    --need to be first to create playersTeam table
    self:BalanceTeamsMMR()

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 10 )

    self:RandomPlayersHeroOrder()
    self:RandomAvailableHeroesForPlayers()

    self:CreatePlayersAbilityPickedInfo()
    self:StartHeroAndAbilityPicking()
end

function CAbilityDraftRanked:OnThink()
    local nNewState = GameRules:State_Get()

    -- print("sprawdzam state: ", nNewState)
    if nNewState == DOTA_GAMERULES_STATE_POST_GAME then
        print( "OnGameRulesStateChange: Game Disconnect - think" )
    elseif nNewState == DOTA_GAMERULES_STATE_DISCONNECT  then
        print( "OnGameRulesStateChange: Game Disconnect - think" )
    end

    return 1
end

function CAbilityDraftRanked:CreateInitialPlayerStats()
    local allPlayers = self:GetAllPlayersConnectedFromLobby()

    local sendToServerData = {}

    for _, playerID in pairs(allPlayers) do
        self._vPlayerStats[playerID] = {
            supporter_level = 0,
            hero_rerolls = self.standardHeroRerolls,
            talent_rerolls = self.standardTalentRerolls,

            reroll_ability_upgrades = self.standardAbilityUpgradeRerolls,
            skip_ability_upgrades = self.standardSkipAbilityUpgrades,

            ability_golden_upgrades = self.standardGoldenAbilityUpgrades,
            ability_golden_upgrades_balance = self.standardGoldenAbilityUpgrades,

            dealtDamage = {
                magical = 0,
                physical = 0,
                pure = 0,
                total = 0,
            },
    
            receivedDamage = {
                magical = 0,
                magical_original = 0,
                physical = 0,
                physical_original = 0,
                pure = 0,
                total = 0,
                total_original = 0,
            },

            netWorth = 0,
            kills = 0,
            deaths = 0,
            assists = 0,
            last_hits = 0,
            denies = 0,
            gold_per_m = 0,
            xp_per_m = 0,

            upgrade_treasures_opened = 0,
        }

        CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), self._vPlayerStats[playerID] )

        table.insert(sendToServerData, {player_id = playerID, steam_id = steamID})
    end

    _HTTPConnection:getManyUsersInfo(sendToServerData, 0)

end

function CAbilityDraftRanked:CreatePlayersAbilityPickedInfo()
    local players = self:GetAllPlayersConnectedFromLobby()

    for _, playerID in pairs(players) do
        for i = 1, self.abilityPerPlayer, 1 do
            local abilitySlot = "base_" .. i

            if i == self.abilityPerPlayer then
                abilitySlot = "ultimate"
            end

            if not self.playersPickedAbilities[playerID] then
                self.playersPickedAbilities[playerID] = {}
            end

            table.insert(self.playersPickedAbilities[playerID], {ability_name = "", ability_slot = abilitySlot})
        end

        self.playersPickedAbilitiesCount[playerID] = {
            base = 0,
            ultimate = 0,
        }

		local team = PlayerResource:GetTeam( playerID )

		if (team == DOTA_TEAM_GOODGUYS) then
			self.teamGoodGuysAmount = self.teamGoodGuysAmount + 1
		else
			self.teamBadGuysAmount = self.teamBadGuysAmount + 1
		end

        CustomNetTables:SetTableValue( "players_ability_picks", string.format( "%d", playerID ), self.playersPickedAbilities[playerID])
    end

	print("TEAM GOOD GUYS HAS : " .. self.teamGoodGuysAmount)
	print("TEAM BAD GUYS HAS : " .. self.teamBadGuysAmount)
end

function CAbilityDraftRanked:RandomPlayersHeroOrder()
	self.playersTeam["radiant"] = shuffleTable(self.playersTeam["radiant"])
	self.playersTeam["dire"] = shuffleTable(self.playersTeam["dire"])

    CustomNetTables:SetTableValue( "players_hero_order", "radiant", self.playersTeam["radiant"])
    CustomNetTables:SetTableValue( "players_hero_order", "dire", self.playersTeam["dire"])
end

function CAbilityDraftRanked:BalanceTeamsMMR()

    local allPlayers = self:GetAllPlayersConnectedFromLobby()
    local playersCount = #allPlayers

    local nActualPlayersPerTeam = math.ceil( PlayerResource:NumTeamPlayers() / 2 )
    --print( nActualPlayersPerTeam .. " players per team" )

    local nPlayerCount = 0
    local nRadiant = 0
    local nDire = 0
    local nUnassigned = 0
    local indexr = 1
    local indexd = 1
    local count = 1
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:IsValidPlayerID( nPlayerID ) then
            local nTeam = PlayerResource:GetTeam( nPlayerID )
            local nTeamCustom = PlayerResource:GetCustomTeamAssignment( nPlayerID )
			if nTeamCustom == DOTA_TEAM_GOODGUYS then
                PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS)

                table.insert(self.playersTeam["radiant"], nPlayerID)

                nRadiant = nRadiant + 1
            elseif nTeamCustom == DOTA_TEAM_BADGUYS then
                PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_BADGUYS)

                table.insert(self.playersTeam["dire"], nPlayerID)

                nDire = nDire + 1
            elseif nTeam == DOTA_TEAM_GOODGUYS then
                PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS)

                table.insert(self.playersTeam["radiant"], nPlayerID)

                nRadiant = nRadiant + 1
            elseif nTeam == DOTA_TEAM_BADGUYS then
                PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_BADGUYS)

                table.insert(self.playersTeam["dire"], nPlayerID)

                nDire = nDire + 1
            else
                nUnassigned = nUnassigned + 1
            end

			PlayerResource:SetCustomPlayerColor(nPlayerID, playerColors["player" .. count .. "R"], playerColors["player" .. count .. "G"], playerColors["player" .. count .. "B"])
			count = count + 1
        end
    end

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if ( nRadiant >= nActualPlayersPerTeam and nDire >= nActualPlayersPerTeam ) or nUnassigned == 0 then
            break
        end
        if PlayerResource:IsValidPlayerID( nPlayerID ) then
            local nTeam = PlayerResource:GetTeam( nPlayerID )
            local nTeamCustom = PlayerResource:GetCustomTeamAssignment( nPlayerID )
            if nTeam ~= DOTA_TEAM_GOODGUYS and nTeam ~= DOTA_TEAM_BADGUYS and nTeamCustom ~= DOTA_TEAM_GOODGUYS and nTeamCustom ~= DOTA_TEAM_BADGUYS then
                local nTeamNumber = ( nRadiant > nDire and DOTA_TEAM_BADGUYS ) or DOTA_TEAM_GOODGUYS
                
                print( "Assigning player " .. nPlayerID .. " to " .. nTeamNumber )
                PlayerResource:SetCustomTeamAssignment( nPlayerID, nTeamNumber )
                
                if nTeamNumber == DOTA_TEAM_GOODGUYS then
                    PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS)

                    table.insert(self.playersTeam["radiant"], nPlayerID)

                    nRadiant = nRadiant + 1
                else
                    PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_BADGUYS)

                    table.insert(self.playersTeam["dire"], nPlayerID)
                    nDire = nDire + 1
                end
                nUnassigned = nUnassigned - 1
            end
        end
    end
end

function CAbilityDraftRanked:StartHeroAndAbilityPicking()
    local players = self:GetAllPlayersConnectedFromLobby()
    local playersCount = #players

    for _, playerID in pairs(players) do
        local team = "radiant"

        --check if player is in dire team
        for _, pID in pairs(self.playersTeam["dire"]) do
            if pID == playerID then
                team = "dire"
                break
            end 
        end

        CustomNetTables:SetTableValue( "players_hero_picks", string.format( "%d", playerID ), {player_id = playerID, team = team})
    end

    self.currentSelectionTimer = self.selectionPhaseTimers[0]

    --set ability picking total time
    --can be only reduced cause hero selecting time can't be increased after game start (self.totalDraftExpectedTime)
    --20 * 4 * 7 = 560 - max pick time (set in InitGameMode)
    --20 * 2 * 10 = 400
    --if playersCount > 1 then
    --    self.totalAbilityPickRounds = 2
    --    self.abilityPickTime = 10
    --    self.abilityPickRound1 = 2
    --    self.abilityPickRound2 = 2

        --self.heroesAbilityCount = 26 
        --self.jungleAbilityCount = 0

        --local availableUltimates = math.max(self.heroesAbilityCount, playersCount)
        --local ultimatesSurplus = availableUltimates - playersCount

        --if (ultimatesSurplus < self.maxUltimateAbilityBans) then
        --  self.maxUltimateAbilityBans = math.max(ultimatesSurplus, 0)
        --end

        --self.playerLevel30TreasureChanceIncrease = self.playerLevel30TreasureChanceIncrease - math.min((0.25 * (playersCount - 10)), 4.5)
    --end

    self.selectionPhaseTimers[3] = playersCount * self.abilityPickTime * self.totalAbilityPickRounds

    --Start thinker for hero and ability picking
    GameRules:GetGameModeEntity():SetThink( "HeroAndAbilitySelectionThink", self, "HeroAndAbilityThinker", 0)

    --Start thinker for queue hero rerolls
    GameRules:GetGameModeEntity():SetThink( "HeroRerollsQueueThink", self, "HeroRerollsQueueThinker", 0)

    --Listen for the pick event from client
    CustomGameEventManager:RegisterListener( "hero_selected", function(...) return self:HeroSelect( ... ) end )
    CustomGameEventManager:RegisterListener( "hero_pick_confirm", function(...) return self:HeroPickConfirm( ... ) end )
    CustomGameEventManager:RegisterListener( "ability_selected", function(...) return self:AbilitySelect( ... ) end )
    CustomGameEventManager:RegisterListener( "talent_selected", function(...) return self:TalentSelect( ... ) end )
    CustomGameEventManager:RegisterListener( "talent_removed", function(...) return self:TalentRemoved( ... ) end )
    CustomGameEventManager:RegisterListener( "talent_reroll", function(...) return self:TalentReroll( ... ) end )
    CustomGameEventManager:RegisterListener( "heroes_reroll", function(...) return self:HeroReroll( ... ) end )
    CustomGameEventManager:RegisterListener( "ability_slot_swapped", function(...) return self:AbilitySlotSwapped( ... ) end )
end

function CAbilityDraftRanked:RandomAvailableHeroesForPlayers()
    local heroData = self:GetAvailableHeroNamesForHeroSelecting()
    local players = self:GetAllPlayersConnectedFromLobby()

    for _, playerID in pairs(players) do
        self:CreateRandomHeroesForPlayer(playerID, heroData, false)
    end
end

function CAbilityDraftRanked:GetAvailableHeroNamesForHeroSelecting()
    local allAvailableHeroes = self:GetAllAvailableHeroNames()
    allAvailableHeroes = shuffleTable(allAvailableHeroes)

    local allHeroesData = {}
    local heroesByPrimaryAttr = {
        [0] = {},
        [1] = {},
        [2] = {},
        [3] = {},
    }

    for _, heroName in pairs(allAvailableHeroes) do
        local heroData = DOTAGameManager:GetHeroDataByName_Script(heroName)

        if heroData and heroData["AttributePrimary"] then
            allHeroesData[heroName] = {
                main_attr = heroData["AttributePrimary"],
            }
        end
    end

    local heroMainAttrToInt = {
        DOTA_ATTRIBUTE_STRENGTH = 0,
        DOTA_ATTRIBUTE_AGILITY = 1,
        DOTA_ATTRIBUTE_INTELLECT = 2,
        DOTA_ATTRIBUTE_ALL = 3,
    }

    for heroName, heroData in pairs(allHeroesData) do
        if not self.reservedHeroNames[heroName] then
            if heroData["main_attr"] and heroMainAttrToInt[ heroData["main_attr"]] and heroesByPrimaryAttr[heroMainAttrToInt[ heroData["main_attr"]]] then
                table.insert(heroesByPrimaryAttr[heroMainAttrToInt[ heroData["main_attr"]]], {
                    hero_name = heroName,
                    hero_id = DOTAGameManager:GetHeroIDByName( heroName ) or -1,
                    main_attr = heroMainAttrToInt[heroData["main_attr"]],
                })
            end
        end
    end

    return heroesByPrimaryAttr
end

function CAbilityDraftRanked:HeroAndAbilitySelectionThink()
    --check if all players confirm hero picks

    if self.currentSelectionPhase == 0 then
        local allPlayers = self:GetAllPlayersConnectedFromLobby()

        local allplayersConfirmed = true
        for _, playerID in pairs(allPlayers) do
            if not self.playersHeroPicksConfirm[playerID] then
                allplayersConfirmed = false
                break
            end
        end

        if allplayersConfirmed then
            self.currentSelectionPhase = 1

            if self.selectionPhaseTimers[self.currentSelectionPhase] then
                self.currentSelectionTimer = self.selectionPhaseTimers[self.currentSelectionPhase]
            end
        end
    end

    --update Timer:
    local initPickingPhase = false
    self.currentSelectionTimer = self.currentSelectionTimer - 1

    if self.currentSelectionTimer <= 0 then
        self.currentSelectionPhase = self.currentSelectionPhase + 1

        if self.currentSelectionPhase == 1 then
            initPickingPhase = true
        end

        if self.selectionPhaseTimers[self.currentSelectionPhase] then
            self.currentSelectionTimer = self.selectionPhaseTimers[self.currentSelectionPhase]
        end
    end

    --check if all players selected heroes
    if self.currentSelectionPhase > 0 and not self.allPlayersPickedHeroes then
        local players = self:GetAllPlayersConnectedFromLobby()
        
        for _, playerID in pairs(players) do
            if not self.playersHeroPicks[playerID] or self.playersHeroPicks[playerID] == "" then
                self:MakeRandomHeroPickForPlayer(playerID)
            end
        end
        
        self.allPlayersPickedHeroes = true
    end

    if self.currentSelectionPhase == 1 then
        --player pick order, must be before creating ability board, becuase ability is in player pick order
        if not self.playerPickOrderChosen then
            self:CreatePlayersPickingOrder()
            self.playerPickOrderChosen = true

            if self.gameIsSaveToLeave or (GameRules:IsCheatMode() and IsDedicatedServer()) then
                self:SendChatCombatMessageTeam("#DOTA_Chat_MatchWillNotBeScoredRanked", DOTA_TEAM_GOODGUYS, true, 0)
                self:SendChatCombatMessageTeam("#DOTA_Ability_Draft_NO_MMR_SAVE", DOTA_TEAM_GOODGUYS, true, 0)
            end
        end

        --Random abilities to select for players
        --Must be created after hero picks to add picked hero abilities.
        if not self.randomAbilitiesChosen then
            self:RandomAbilityBoard()
            self.randomAbilitiesChosen = true
        end

        if not self.randomHeroTalentsChosen then
            self:RandomHeroTalentsForPlayers()
            self.randomHeroTalentsChosen = true
        end
    end

    if self.currentSelectionPhase == 3 and not self.abilitiesBanned then
        self:BanAbilities()
        self.abilitiesBanned = true
    end

    if self.currentSelectionPhase == 4 then
        if not self.allPlayersPickedAbilities then
            self:VerifyAllPlayersPickedAbilities()
        end
    end

    if self.currentSelectionPhase >= 4 and self.currentSelectionTimer <= 0 then
        self:EndAbilityPicking()
        self.abilityDraftPickingEnd = true

        return nil
    end

    if self.currentSelectionPhase >= 1 and not initPickingPhase then
        --Update players picking rules
        self:UpdatePlayersPickingOrder()
    end

    CustomNetTables:SetTableValue( "selection_info", "0", {select_phase = self.currentSelectionPhase, time = self.currentSelectionTimer})

    return 1
end

function CAbilityDraftRanked:ReserveRandomBaseAbility(excludedAbilityName, updateNetTable)
    local abilityName = ""
    local allBaseAbilities = {}

    for _, abilityData in pairs(self.availableAbilities["base"]) do
        if abilityData["ability_name"] and  abilityData["available"] == "1" and 
            (not excludedAbilityName or abilityData["ability_name"] ~= excludedAbilityName) 
        then
            table.insert(allBaseAbilities, abilityData["ability_name"])
        end
    end

    for _, abilityData in pairs(self.availableAbilities["jungle"]) do
        if abilityData["ability_name"] and abilityData["available"] == "1" and 
            (not excludedAbilityName or abilityData["ability_name"] ~= excludedAbilityName) 
        then
            table.insert(allBaseAbilities, abilityData["ability_name"])
        end
    end

    if #allBaseAbilities > 0 then
        local randomAbilityName = allBaseAbilities[RandomInt(1, #allBaseAbilities)]

        if randomAbilityName then
            abilityName = randomAbilityName
        end
    end

    if not abilityName or abilityName == "" then
        return ""
    end

    local abilityFound = false
    for _, data in pairs(self.availableAbilities["base"]) do
        if data["ability_name"] == abilityName then
            data["available"] = "0"
            abilityFound = true
            break
        end
    end

    if not abilityFound then
        for _, data in pairs(self.availableAbilities["jungle"]) do
            if data["ability_name"] == abilityName then
                data["available"] = "0"
                abilityFound = true
                break
            end
        end
    end

    --needed only on ability picking screen (before game start)
    --don't update it when game has already start, because this table is bigger (increased by all abilities in DOTA!), and this make game lagging
    if updateNetTable then
        CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)
    end

    return abilityName
end

function CAbilityDraftRanked:ReserveRandomUltimateAbility(excludedAbilityName, updateNetTable)
    local ultimateName = ""
    local allUltimateAbilities = {}

    for _, abilityData in pairs(self.availableAbilities["ultimate"]) do
        if abilityData["ability_name"] and abilityData["available"] == "1" and 
            (not excludedAbilityName or abilityData["ability_name"] ~= excludedAbilityName) 
        then
            table.insert(allUltimateAbilities, abilityData["ability_name"])
        end
    end

    if #allUltimateAbilities > 0 then
        local randomUltimateName = allUltimateAbilities[RandomInt(1, #allUltimateAbilities)]

        if randomUltimateName  then
            ultimateName = randomUltimateName
        end
    end

    if not ultimateName or ultimateName == "" then
        return ""
    end

    for _, data in pairs(self.availableAbilities["ultimate"]) do
        if data["ability_name"] == ultimateName then
            data["available"] = "0"
            break
        end
    end

    --needed only on ability picking screen (before game start)
    --don't update it when game has already start, because this table is bigger (increased by all abilities in DOTA!), and this make game lagging
    if updateNetTable then
        CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)
    end

    return ultimateName
end

function CAbilityDraftRanked:UnreserveAbility(abilityName, updateNetTable)
    local abilityFound = false

    for _, data in pairs(self.availableAbilities["base"]) do
        if data["ability_name"] == abilityName then
            data["available"] = "1"
            abilityFound = true
            break
        end
    end

    if not abilityFound then
        for _, data in pairs(self.availableAbilities["jungle"]) do
            if data["ability_name"] == abilityName then
                data["available"] = "1"
                abilityFound = true
                break
            end
        end
    end

    if not abilityFound then
        for _, data in pairs(self.availableAbilities["ultimate"]) do
            if data["ability_name"] == abilityName then
                data["available"] = "1"
                abilityFound = true
                break
            end
        end
    end

    --needed only on ability picking screen (before game start)
    --don't update it when game has already start, because this table is bigger (increased by all abilities in DOTA!), and this make game lagging
    if updateNetTable then
        CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)
    end
end

function CAbilityDraftRanked:VerifyAllPlayersPickedAbilities()

    for playerID, abilitiesData in pairs(self.playersPickedAbilities) do
        for _, abilityData in ipairs(abilitiesData) do
            local abilityType = "base"

            if abilityData["ability_slot"] and string.find(abilityData["ability_slot"], "ultimate") then
                abilityType = "ultimate"
            end

            if abilityData["ability_name"] then
                if abilityData["ability_name"] == "" then
                    if abilityType == "base" then
                        local excludedAbilityName = nil
                        local heroName = self.playersHeroPicks[playerID]

                        --if heroName and heroName ~= "" and not self:IsHeroRangedAttacker(heroName) then
                        --    excludedAbilityName = "muerta_gunslinger"
                        --end

                        local abilityName = self:ReserveRandomBaseAbility(excludedAbilityName, true)
    
                        if abilityName and abilityName ~= "" then
                            abilityData["ability_name"] = abilityName
                        end
                    end
    
                    if abilityType == "ultimate" then
                        local abilityName = self:ReserveRandomUltimateAbility(nil, true)
    
                        if abilityName and abilityName ~= "" then
                            abilityData["ability_name"] = abilityName
                        end
                    end
                else
                    if EXCLUDED_BASE_ABILITIES_MELEE_HERO[abilityData["ability_name"]] then
                        local heroName = self.playersHeroPicks[playerID]

                        if heroName and heroName ~= "" and not self:IsHeroRangedAttacker(heroName) then
                            local abilityName = self:ReserveRandomBaseAbility(abilityData["ability_name"], true)

                            if not abilityName then
                                abilityName = ""
                            end

                            abilityData["ability_name"] = abilityName
                        end
                    end
                end
            end
        end

        CustomNetTables:SetTableValue( "players_ability_picks", string.format( "%d", playerID ), self.playersPickedAbilities[playerID])

        local szAccountID = tostring( PlayerResource:GetSteamAccountID( playerID ) )
        CustomNetTables:SetTableValue( "players_ability_picks_2", szAccountID, self.playersPickedAbilities[playerID])
    end

    self.allPlayersPickedAbilities = true
end

function CAbilityDraftRanked:HeroRerollsQueueThink()
    if self.currentSelectionPhase > 0 then
        return nil
    end

    if not self.heroRerollQueue or #self.heroRerollQueue == 0 then
        return 0.1
    end

    local playerID = self.heroRerollQueue[1]
    local heroData = self:GetAvailableHeroNamesForHeroSelecting()

    self:CreateRandomHeroesForPlayer(playerID, heroData, true)
    
    table.remove(self.heroRerollQueue, 1)

    return 0.1
end

function CAbilityDraftRanked:CreateRandomHeroesForPlayer(playerID, heroesByPrimaryAttr, isReroll)
    local selectedHeroName = self.playersHeroPicks[playerID] or ""
    local selectedHeroMainAttr = nil
    local selectedHeroData = {}

    --remove current reserved hero names (except current selected hero - for rerolls)
    local playerReservedHeroes = self.reservedHerosForPlayers[playerID]
    if playerReservedHeroes then
        for index, heroData in pairs(playerReservedHeroes) do
            if heroData["hero_name"] and self.reservedHeroNames[heroData["hero_name"]] then

                if not isReroll or selectedHeroName ~= heroData["hero_name"]  then
                    self.reservedHeroNames[heroData["hero_name"]] = nil
                else
                    selectedHeroMainAttr = index
                    selectedHeroData = heroData
                end
            end
        end
    end

    local playerSelectedHeroes = {
        [0] = {},
        [1] = {},
        [2] = {},
        [3] = {},
    }

    --hero main attributes (0,1,2,3)
    for attr, _ in pairs(playerSelectedHeroes) do
        
        --keep selected hero name in player reserved hero names (only for rerolls)
        if isReroll and selectedHeroMainAttr and selectedHeroData and selectedHeroData["hero_name"] and attr == selectedHeroMainAttr then
            playerSelectedHeroes[attr] = selectedHeroData

        -- random heroes
        else
            if heroesByPrimaryAttr[attr] and #heroesByPrimaryAttr[attr] > 0 then
                local randomElement = RandomInt(1, #heroesByPrimaryAttr[attr])
                local randomHero = deepcopy(heroesByPrimaryAttr[attr][randomElement])

                randomHero["player_id"] = playerID

                if randomHero["hero_name"] and randomHero["hero_name"] ~= "" and randomHero["hero_id"] then
                    local heroData = DOTAGameManager:GetHeroDataByName_Script(randomHero["hero_name"])
                    local selectSound = ""
                    
                    --add pick sound name
                    if heroData then
                        selectSound = heroData["PickSound"]
    
                        if not selectSound or selectSound == 0 then
                            selectSound = heroData["HeroSelectSoundEffect"]
                        end

                        randomHero["pick_sound"] = selectSound
                    end

                    playerSelectedHeroes[attr] = randomHero

                    table.remove(heroesByPrimaryAttr[attr], randomElement)

                    self.reservedHeroNames[randomHero["hero_name"]] = true

                    GameRules:AddHeroToPlayerAvailability( playerID, randomHero["hero_id"] )

                    --create base hero stats for client tooltips
                    CustomNetTables:SetTableValue( "hero_base_stats", string.format( "%d", randomHero["hero_id"] ), self:GetBaseHeroStats(randomHero["hero_name"]))
                end
            end
        end
    end

    self.reservedHerosForPlayers[playerID] = playerSelectedHeroes

    CustomNetTables:SetTableValue( "players_hero_options", string.format( "%d", playerID ), self.reservedHerosForPlayers[playerID])
end

function CAbilityDraftRanked:CreatePlayersPickingOrder()
    local playersOrder = {}
    local playersCount = 0

    if not self.playersTeam["radiant"] and not self.playersTeam["dire"] then
        return
    end

    if self.playersTeam["radiant"] and #self.playersTeam["radiant"] > 0 then
        playersCount = playersCount + #self.playersTeam["radiant"]
    end

    if self.playersTeam["dire"] and #self.playersTeam["dire"] > 0 then
        playersCount = playersCount + #self.playersTeam["dire"]
    end

    local radiantTeam = deepcopy(self.playersTeam["radiant"])
    local direTeam = deepcopy(self.playersTeam["dire"])

    for i = 1, playersCount, 1 do
        if (i % 2 ~= 0) then
            if #radiantTeam > 0 then
                table.insert(playersOrder, radiantTeam[1])
                table.remove(radiantTeam, 1)
            elseif #direTeam > 0 then
                table.insert(playersOrder, direTeam[1])
                table.remove(direTeam, 1)
            end
        else
            if #direTeam > 0 then
                table.insert(playersOrder, direTeam[1])
                table.remove(direTeam, 1)
            elseif #radiantTeam > 0 then
                table.insert(playersOrder, radiantTeam[1])
                table.remove(radiantTeam, 1)
            end
        end
    end

    self.playersIdPickOrder = shallowcopy(playersOrder)

    local pickOrder = 1
    local abilityPickCount = self.abilityPickRound1
    local order = 1

    --players ability picks: round 1: 1, round 2: 2, round 3: 1
    --pick_number - max number of ability to pick in round (round 1: 1, round 2: 3, round 3: 4 ) includes not picked ability from previous rounds
    --pick_number is never updated (but is compared with picked abilties when player picks ability)
    --pick_count - real number of ability to pick in round (includes picked abilities, and not picked abilities from previous rounds)
    --pick_count is updated when player picks ability (decreased) or miss his pick (increased)

    for i = 1, self.totalAbilityPickRounds, 1 do
        local totalPickNumber = self.abilityPickRound1

        --banning is before and counted as round 1
        local roundNumber = i + 1

        if i == 2 then
            abilityPickCount = self.abilityPickRound2
            totalPickNumber = self.abilityPickRound1 + self.abilityPickRound2
        elseif i == 3 then
            abilityPickCount = self.abilityPickRound3
            totalPickNumber = self.abilityPickRound1 + self.abilityPickRound2 + self.abilityPickRound3
        elseif i == 4 then
            abilityPickCount = self.abilityPickRound4
            totalPickNumber = self.abilityPickRound1 + self.abilityPickRound2 + self.abilityPickRound3 + self.abilityPickRound4
        end

        if order == 1 then
            for j = 1, #playersOrder do
                local pickTime = self.abilityPreRoundTime + self.abilityBanTime +  self.abilityPickTime * (pickOrder - 1)

                local heroID = -1
                local heroName = ""
                if self.playersHeroPicks[playersOrder[j]] then
                    heroName = self.playersHeroPicks[playersOrder[j]]
                    heroID = DOTAGameManager:GetHeroIDByName(heroName)
                end

                table.insert(self.playersPickOrder["order"], 
                            {
                                player_id = playersOrder[j], 
                                pick_time = pickTime, 
                                hero_id = heroID, 
                                pick_number = totalPickNumber, 
                                pick_count = abilityPickCount,
                                round_number = roundNumber
                            }   
                )
                
                pickOrder = pickOrder + 1
            end
        else
            for j = #playersOrder, 1, -1 do
                local pickTime = self.abilityPreRoundTime + self.abilityBanTime + self.abilityPickTime * (pickOrder - 1)

                local heroID = -1
                if self.playersHeroPicks[playersOrder[j]] then
                    local heroName = self.playersHeroPicks[playersOrder[j]]
                    heroID = DOTAGameManager:GetHeroIDByName(heroName)
                end

                table.insert(self.playersPickOrder["order"], 
                            {
                                player_id = playersOrder[j], 
                                pick_time = pickTime, 
                                hero_id = heroID, 
                                pick_number = totalPickNumber, 
                                pick_count = abilityPickCount,
                                round_number = roundNumber,
                            }
                )

                pickOrder = pickOrder + 1
            end
        end

        order = order * (-1)
    end

    self.playersPickOrder["pick_time"] = self.abilityPreRoundTime + self.abilityBanTime
    self.playersPickOrder["end_picking_time"] = self.abilityPreRoundTime + self.abilityBanTime + playersCount * self.abilityPickTime * self.totalAbilityPickRounds + self.abilityPostRoundTime
    self.playersPickOrder["base_pick_time"] = self.abilityPickTime
    self.playersPickOrder["current_phase"] = self.currentSelectionPhase
    self.playersPickOrder["current_phase_timer"] = self.currentSelectionTimer

    --currently all rounds use the same pick count, there is difference only for games with more than 10 players
    -- 10vs10: 4x1pick, more players: 2x2picks
    self.playersPickOrder["picks_per_round"] = self.abilityPickRound1
    self.playersPickOrder["pick_rounds"] = self.totalAbilityPickRounds

    CustomNetTables:SetTableValue( "ability_pick_order", "0", self.playersPickOrder)
end

function CAbilityDraftRanked:UpdatePlayersPickingOrder()
    self.playersPickOrder["current_phase"] = self.currentSelectionPhase
    self.playersPickOrder["current_phase_timer"] = self.currentSelectionTimer

    if self.playersPickOrder["end_picking_time"] > 0 then
        self.playersPickOrder["end_picking_time"] = self.playersPickOrder["end_picking_time"] - 1
    else
        self.playersPickOrder["end_picking_time"] = 0
    end

    if self.playersPickOrder["draft_end"] ~= 1 then
        for _, playerData in ipairs(self.playersPickOrder["order"]) do
            if playerData["pick_time"] and playerData["pick_time"] >= 1 then
                playerData["pick_time"] = playerData["pick_time"] - 1
            end
        end

        if self.playersPickOrder["pick_time"] >= 2 then
            self.playersPickOrder["pick_time"] = self.playersPickOrder["pick_time"] - 1
        else
            if #self.playersPickOrder["order"] > 0 then
                self.playersPickOrder["pick_time"] = self.abilityPickTime
                self.playersPickOrder["current_player_pick"] = shallowcopy(self.playersPickOrder["order"][1])

                local playerID = self.playersPickOrder["current_player_pick"]["player_id"] or -1
                local pickNumber = self.playersPickOrder["current_player_pick"]["pick_number"] or 0

                local pickedAbilityCount = 0
                if self.playersPickedAbilitiesCount[playerID] and self.playersPickedAbilitiesCount[playerID]["base"] and
                    self.playersPickedAbilitiesCount[playerID]["ultimate"]
                then
                    pickedAbilityCount = self.playersPickedAbilitiesCount[playerID]["base"] + self.playersPickedAbilitiesCount[playerID]["ultimate"]
                end

                --get current player pick count if player is currently pick player
                --if player missed his turn to pick, he can pick more abiltiies in current rounds (min:1, max: abilities per player)
                self.playersPickOrder["current_player_pick"]["pick_count"] = math.max(pickNumber - pickedAbilityCount, 0)
                
                table.remove(self.playersPickOrder["order"], 1)
            else
                --the end
                self.playersPickOrder["draft_end"] = 1
                self.playersPickOrder["current_player_pick"] = {}
            end
        end
    end

    CustomNetTables:SetTableValue( "ability_pick_order", "0", self.playersPickOrder)
end

function CAbilityDraftRanked:MakeRandomHeroPickForPlayer(playerID)
    local playerAvailableHeroes = self.reservedHerosForPlayers[playerID]

    if playerAvailableHeroes then
        local randomHeroMainAttr = RandomInt(0, 3)

        local heroName = ""

        for _, heroData in pairs(playerAvailableHeroes) do
            if heroData["main_attr"] == randomHeroMainAttr and heroData["hero_name"] then
                heroName = heroData["hero_name"]
                break
            end
        end

        if not heroName or heroName == "" then
            if #playerAvailableHeroes > 0 then
                for _, heroData in pairs(playerAvailableHeroes) do
                    if heroData["hero_name"] and heroData["hero_name"] ~= "" then
                        heroName = heroData["hero_name"]
                        break
                    end
                end
            else
                heroName = "npc_dota_hero_jakiro"
            end
        end

        self:UpdatePlayerHeroPick(playerID, heroName)
    end
end

function CAbilityDraftRanked:HeroSelect(eventSourceIndex, event )
    if self.currentSelectionPhase > 0 then
        return
    end

    if event.hero_option and event.player_id then
        local heroName = self:GetSelectedHeroNameByOptionID(event.player_id, event.hero_option)
        if not heroName or heroName == "" then
            return
        end

        self:UpdatePlayerHeroPick(event.player_id, heroName)
    end
end

function CAbilityDraftRanked:HeroPickConfirm(eventSourceIndex, event)
    if event.player_id then
        self.playersHeroPicksConfirm[event.player_id] = true

        --save picks to net table
        local playerPickInfo = CustomNetTables:GetTableValue("players_hero_picks", string.format( "%d", event.player_id ))

        if playerPickInfo ~= null then
            playerPickInfo["confirmed"] = true
            
            CustomNetTables:SetTableValue( "players_hero_picks", string.format( "%d", event.player_id ), playerPickInfo)
        end

    end
end

function CAbilityDraftRanked:UpdatePlayerHeroPick(playerID, heroName)
    self.playersHeroPicks[ playerID ] = heroName
    local heroID = DOTAGameManager:GetHeroIDByName( heroName )

    local team = "radiant"

    --check if player is in dire team
    for _, pID in pairs(self.playersTeam["dire"]) do
        if pID == playerID then
            team = "dire"
            break
        end
    end

    self.allPickedHeroNames[heroName] = true

    --save picks to net table
    CustomNetTables:SetTableValue( "players_hero_picks", string.format( "%d", playerID ), {player_id = playerID, team = team, hero_name = heroName, hero_id = heroID})
end

function CAbilityDraftRanked:GetSelectedHeroNameByOptionID(playerID, optionID)
    local result = ""
    local selectedHeroAttr = string.sub(optionID, -1)
    local playerHeroOptions = self.reservedHerosForPlayers[playerID]

    for _, heroOptionData in pairs(playerHeroOptions) do
        if tostring(heroOptionData.main_attr) == selectedHeroAttr and heroOptionData.hero_name then
			--result = "npc_dota_hero_ringmaster"
            result = heroOptionData.hero_name
            break
        end
    end

    return result
end

function CAbilityDraftRanked:BanAbilities()
    local abilityBanVotesByType = {
        base = {},
        ultimate = {}
    }

    for _, voteData in pairs(self.abilityBanVotes) do
        local abilityName = voteData["ability_name"]
        local abilityType = voteData["ability_type"]

        if abilityName and abilityType then
            if abilityType == "ultimate" then
                if not abilityBanVotesByType["ultimate"][abilityName] then
                    abilityBanVotesByType["ultimate"][abilityName] = 0
                end

                abilityBanVotesByType["ultimate"][abilityName] = abilityBanVotesByType["ultimate"][abilityName] + 1
            else
                if not abilityBanVotesByType["base"][abilityName] then
                    abilityBanVotesByType["base"][abilityName] = 0
                end

                abilityBanVotesByType["base"][abilityName] = abilityBanVotesByType["base"][abilityName] + 1
            end
        end
    end

    local abilityBanVotes = {}

    for type, data in pairs(abilityBanVotesByType) do
        for abilityName, votes in pairs(data) do
            table.insert(abilityBanVotes, {
                ability_name = abilityName,
                votes = votes,
                type = type,
            })
        end
    end

    table.sort(abilityBanVotes, function (a, b)
        return TableSortBy(a, b, "votes", true)
    end)

    local abilitiesToBan = {}
    local bannedAbilities = 0
    local bannedUltimates = 0

    for _, data in ipairs(abilityBanVotes) do
        if bannedAbilities >= self.maxTotalAbilityBans then
            break
        end

        if data["type"] and data["ability_name"] and data["ability_name"] ~= "" then
            if data["type"] ~= "ultimate" or (bannedUltimates < self.maxUltimateAbilityBans) then
                table.insert(abilitiesToBan, data["ability_name"])

                bannedAbilities = bannedAbilities + 1

                if data["type"] == "ultimate" then
                    bannedUltimates = bannedUltimates + 1
                end
            end
        end
    end

    local anyAbilityBanned = false

    --set abiity not available
    --clear ban voted
    for _, abilityName in pairs(abilitiesToBan) do
        for _, abilities in pairs(self.availableAbilities) do
            for _, abilityData in pairs(abilities) do
                if abilityData["ability_name"] == abilityName then
                    anyAbilityBanned = true

                    abilityData["available"] = "0"
                    abilityData["banned"] = "1"
                    abilityData["ban_voted"] = "0"

                elseif abilityData["ban_voted"] then
                    abilityData["ban_voted"] = "0"
                end
            end
        end
    end

    if anyAbilityBanned then
        CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)
    end
end

function CAbilityDraftRanked:EndAbilityPicking()
    --Assign the picked heroes to all players that have picked
    print("end hero picking")
    for playerID, heroName in pairs( self.playersHeroPicks ) do
        if not self.playersHeroSelected[playerID] or self.playersHeroSelected[playerID] == "" then
            local player = PlayerResource:GetPlayer(playerID)
            if player then
                player:SetSelectedHero(heroName)
                self.playersHeroSelected[playerID] = heroName
            end
        end
    end

    if not self.allUsedHeroesPrecached then
        --precache all heroes that abilities could be picked
        for _, heroName in pairs(self.allUsedAbilityHeroNames) do
            --picked heroes are preacache automatically when enter game
            if not self.precachedUnits[heroName] and not self.allPickedHeroNames[heroName] then
                --PrecacheUnitByNameAsync( "precache_" .. heroName,
				PrecacheUnitByNameAsync( heroName,
                    function (precacheId) 
                        self.precachedUnits[heroName] = precacheId
                        print("precached: ", heroName)
                    end
                )
            end
        end

        self.allUsedHeroesPrecached = true
    end

    --seems not working (Probably hero selecting time can't be changed after game init)
    GameRules:SetHeroSelectionTime(1)
    GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride(1)
end

function CAbilityDraftRanked:SetSelectedAbilities(hero, playerID)
    if not self.playersPickedAbilities[playerID] then
        return
    end

    if self.playersAbilityModified[playerID] then
        return
    end

    if hero then
        local heroName = hero:GetUnitName()
        local abilityCount = hero:GetAbilityCount()
        
        --first: remove base abilities
        for i = 0, abilityCount - 1 , 1 do
            local ability = hero:GetAbilityByIndex(i)

            if ability and not ability:IsAttributeBonus() and not ability:_IsSecretRequiredAbility() and (not ability:_IsInnate_AD2023() or ability:GetAbilityName() == "invoker_invoke" )
			and (ability:GetAbilityName() ~= "ringmaster_empty_souvenir" and ability:GetAbilityName() ~= "ringmaster_dark_carnival_souvenirs" and ability:GetAbilityName() ~= "ringmaster_funhouse_mirror"
			and ability:GetAbilityName() ~= "ringmaster_strongman_tonic" and ability:GetAbilityName() ~= "ringmaster_whoopee_cushion"and ability:GetAbilityName() ~= "ringmaster_crystal_ball"
			and ability:GetAbilityName() ~= "ringmaster_summon_unicycle" and ability:GetAbilityName() ~= "ringmaster_weighted_pie" and ability:GetAbilityName() ~= "ability_capture"
			and ability:GetAbilityName() ~= "ability_lamp_use") then
                ability:SetLevel(0)
                self:ClearBaseAbilityModifiers(hero, ability)
                hero:RemoveAbility(ability:GetAbilityName())
            end
        end

        --add picked base abilities
        local baseAbilityCounter = 0
        for _, abilityData in ipairs(self.playersPickedAbilities[playerID]) do
            if baseAbilityCounter >= 3 then
                break
            end

            local abilityName = abilityData["ability_name"] or ""

            if abilityName and abilityName ~= "" and abilityData["ability_slot"] ~= "ultimate" then
                local newAbility = hero:AddAbility(abilityName)
                baseAbilityCounter = baseAbilityCounter + 1

                if newAbility then
                    self:SetNewAddedAbility(newAbility, hero)
                end

                if string.find(abilityName, "invoker") then
					newAbility:SetLevel(0)
				end
            end
        end

        -- add generic hidden abilities to place ultimate in slot 6 (i == 5, cause abilities are counting from 0)
		for i = 0, 4, 1 do
			local ability = hero:GetAbilityByIndex(i)
			if not ability then
				hero:AddAbility("generic_hidden")
			end
		end

        -- add ultimate
        for _, abilityData in ipairs(self.playersPickedAbilities[playerID]) do
            if abilityData["ability_slot"] == "ultimate" then
                local ultimate = hero:AddAbility(abilityData["ability_name"])
                
                if ultimate then
                    --need to remove modifiers otherwise ability can be invalid
                    self:ClearBaseAbilityModifiers(hero, ultimate)
                    ultimate:SetRefCountsModifiers(true)
                end

                break
            end
        end

        --add all required other abilities 
        self:AddOtherRequiredAbilitiesToHero(hero)

		--add abilities binded to hero
		local bindedAbilities = HERO_BIND_ABILITIES[heroName]
		if bindedAbilities then
			for abilityName, abilityData in pairs(bindedAbilities) do
				local equivalentAbility = abilityData["equivalent"]
				local requiredFacet = abilityData["required_facet"]
				local level = abilityData["set_level"]
				if level and level > 1 then
					level = 1
				end

				if (not equivalentAbility or not hero:HasAbility(equivalentAbility) or not hero:HasAbility(abilityName)) and (not requiredFacet or hero:GetHeroFacetID() == requiredFacet) then
					local bindedAbility = hero:AddAbility(abilityName)

					if bindedAbility then
						self:ClearBaseAbilityModifiers(hero, bindedAbility)

						if level then
							bindedAbility:SetLevel(level)
						end

						bindedAbility:RefreshIntrinsicModifier()

						if abilityData["hidden"] then
							bindedAbility:SetHidden(true)
						end
					end
				end
			end
		end

        --add selected talents
        self:AddTalentsToHero(hero, playerID)

        --add bonus attributes to Invoker
        --if hero:GetUnitName() == "npc_dota_hero_invoker" then
        --  hero:AddAbility("special_bonus_attributes")
        --end

        self.playersAbilityModified[playerID] = true

        --only for client to know if this is unit with modified abilities to show base tooltips (as Aghanim Scepter/Shard upgrades)
        hero:AddNewModifier(hero, nil, "modifier_hero_ability_modified_ad_2023", {})
    end
end

function CAbilityDraftRanked:SetNewAddedAbility(newAbility, hero)
    if not newAbility then
        return
    end

    local abilityName = newAbility:GetAbilityName()

    if self:IsJungleAbility(abilityName) then
        newAbility:SetLevel(0)
        
        if newAbility:GetAutoCastState() then
            newAbility:ToggleAutoCast()
        end
    end

    --need to remove modifiers otherwise ability can be invalid
    self:ClearBaseAbilityModifiers(hero, newAbility)
    newAbility:SetRefCountsModifiers(true)

    --fix for auto levelled abilities
    if AUTO_LEVELLED_ABILITIES[abilityName] then
        newAbility:RefreshIntrinsicModifier()

        if newAbility:GetAbilityName() == "medusa_mana_shield" then
            newAbility:SetLevel(1)
        end
    end
end

function CAbilityDraftRanked:AddTalentsToHero(hero, playerID)
    if not hero or hero:IsNull() or playerID == nil then
        return
    end

    local heroName = hero:GetUnitName()
    local pickedTalents = self.playersPickedTalents[playerID]

    local addedTalents = deepcopy(pickedTalents)

    if pickedTalents then
        for talentLevel, talentsName in pairs(pickedTalents) do
            local talents = {}

            if type(talentsName) == "table" and #talentsName > 0 then

                if talentsName[1] ~= "" then
                    table.insert(talents, talentsName[1])
                end

                if #talentsName > 1 and talentsName[2] ~= "" and talentsName[1] ~= talentsName[2] then
                    table.insert(talents, talentsName[2])
                end
            end

            for index = 1, 2, 1 do
                local talentName = talents[index] or ""

                if talentName ~= "" then
                    local talentPos = "right"
                    local subTalentPos = "left"
                    
                    if index == 2 then
                        talentPos = "left"
                        subTalentPos = "right"
                    end

                    if talentName and talentName ~= "" and not hero:HasAbility(talentName)then
                        local currentTalentName = self:GetBaseTreeTalentName(heroName, talentLevel, talentPos)
                        local subCurrentTalentName = self:GetBaseTreeTalentName(heroName, talentLevel, subTalentPos)
    
                        if currentTalentName and subCurrentTalentName and 
                            currentTalentName ~= "" and subCurrentTalentName ~= "" and
                            currentTalentName ~= talentName and subCurrentTalentName ~= talentName then
                            
                            local newTalentAbility = hero:AddAbility(talentName)
                            if newTalentAbility then
                                local currentAbility = hero:FindAbilityByName(currentTalentName)
    
                                if currentAbility then
                                    hero:SwapAbilities(currentTalentName, talentName, true, true)
                                    hero:RemoveAbilityByHandle(currentAbility)

                                    --need to remove modifiers from talent otherwise talent will not work
                                    self:ClearBaseAbilityModifiers(hero, newTalentAbility)
                                end

                                addedTalents[talentLevel][index] = talentName
                            end
                        end
                    end
                end
            end
        end

        local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

        CustomNetTables:SetTableValue( "players_talent_added", steamID, addedTalents)

        --need to verify talents count (if for some reason or bug there will be more than 8 talents game will crash)
        self:VerifyAllTalents(hero)
    end
end

function CAbilityDraftRanked:IsHeroMeetTalentRequirments(hero, talentName, talentLevel)
    if not hero or not talentName then
        return false
    end

    local talentsInfo = self:GetSelectedHeroesAllTalentsData()
    local allTalentsData = talentsInfo["talents"]

    if not allTalentsData or not allTalentsData[talentLevel] then
        return false
    end

    local talentData = nil
				

    for _, data in pairs(allTalentsData[talentLevel]) do
        if data["talent_name"] == talentName then
            talentData = deepcopy(data)
            break
        end
    end
    
    if not talentData then
        return false
    end



    if talentData["talent_type"] and talentData["talent_type"] ~= "hero_talent" then
        return true
    end

    if talentData["talent_type"] and talentData["talent_type"] == "hero_talent" and 
        (not talentData["ability_names"] or #talentData["ability_names"] == 0) 
    then
        --non unique hero talents that weren't added to AD 10vs10 database (_G.BASE_HERO_TALENTS)
        if not string.find(talentName, "special_bonus_unique_") or UNIVERSAL_HERO_TALENTS[talentName] then
            return true
        end

        --return false
    end

    if talentData["ability_names"] and talentData["ability_names"][1] and string.starts(talentData["ability_names"][1], "item_") then
        return true
    end

    if talentData["ability_names"] and talentData["relation"] then
        local requiredAbilities = talentData["ability_names"]
        local abilityRelation = talentData["relation"]

        local needAbilityCount = #requiredAbilities
        if needAbilityCount > 1 then
            needAbilityCount = 1
        end

        local counter = 0
        for _, abilityName in pairs(requiredAbilities) do
            if hero:HasAbility(abilityName) then
                counter = counter + 1
            end
        end

        if counter >= needAbilityCount then
            return true
        end
    end

	--TOREMOVEMAYBE
	--return true
    return false
end

function CAbilityDraftRanked:AddOtherRequiredAbilitiesToHero(hero)
    if not hero or hero:IsNull() then
        return
    end

    local abilityCount = hero:GetAbilityCount()

    for i = 0, abilityCount - 1 , 1 do
        local ability = hero:GetAbilityByIndex(i)

        if ability and not ability:IsAttributeBonus() and not string.find(ability:GetAbilityName(), "special_bonus_") then
            self:AddOtherRequiredAbilitiesForAbility(hero, ability)
        end
    end
end

function CAbilityDraftRanked:AddOtherRequiredAbilitiesForAbility(hero, ability)
	if not hero or not ability then
		return
	end

	-- add hidden sub abilities (base required abilities)
	local subAbilityName = self:GetSubAbilityForBaseAbility(ability:GetAbilityName())
	if subAbilityName and subAbilityName ~= "" and not hero:HasAbility(subAbilityName) then
		local subAbility = hero:AddAbility(subAbilityName)
		if subAbility then
			subAbility:SetHidden(true)

			if ability.abilityLevelMaxed then
				subAbility:SetLevel(subAbility:GetMaxLevel())
			end
		end
	end

	--add abilities that is required to base ability work correctly
	--add right click swap base abilities (e.g. morph switch attr)
	--add right click swap new abilities from scepter/shard from base abilities
	--also scepter/shard new abilities from ultimate

	local requiredAbilityData = self:GetOtherRequiredAbilities(ability:GetAbilityName())

	for abilityName, data in pairs(requiredAbilityData) do
		if abilityName ~= "" and not hero:HasAbility(abilityName) and data["required_ability"] then
			if data["required_ability"] == "" or (hero:HasAbility(data["required_ability"])) then
				local requiredFacet = data["required_facet"]

				if not requiredFacet or hero:GetHeroFacetID() == requiredFacet then
					--ability without prefered slot (probably hidden)
					if not data["slot"] then
						local newAbility = hero:AddAbility(abilityName)
						if newAbility then

							if data["hidden"] then
								newAbility:SetHidden(data["hidden"])
							end

							--need to remove modifiers otherwise ability can be invalid
							self:ClearBaseAbilityModifiers(hero, newAbility)
							
							if data["set_level"] and data["set_level"] > 0 then
								newAbility:SetLevel(1)
								newAbility:RefreshIntrinsicModifier()
							end

							if data["base_ability"] then
								newAbility.baseAbilityLevelling = true
							end

							local isGrantedByScepter = self:IsAbilityGrantedByScepter(abilityName)

							if isGrantedByScepter and SWAP_ABILITIES[abilityName] then
								--add name of base ability to swapped scepter ability for case when scepter is dropped,
								--and player has swapped to this scepter ability (to back normal ability)
								--currently only non-ulimate abilities can be swapped (so without prefered slot)
								newAbility.swappedScepterAbility = ability:GetAbilityName()
							end
						end
					--if new ability has preferes slot (for example templar assassin trap)
					--prefered slot should be only 4 or 5, if there is generic_hidden and is availble then take it, 
					--if both generic_hidden are taken then just add ability to the end
					elseif data["slot"] >= 4 and data["slot"] <= 5 then
						local slotNumber = data["slot"]

						--slots are indexed from 0 (so -1)
						local abilityInPreferedSlot = hero:GetAbilityByIndex(slotNumber - 1)
						local abilityToChange = nil
						local backUpSlotNumber = 4
						local addedToPreferedSlot = false

						if slotNumber == 4 then
							backUpSlotNumber = 5
						end

						if abilityInPreferedSlot then
							if abilityInPreferedSlot:GetAbilityName() == "generic_hidden" then
								abilityToChange = abilityInPreferedSlot				
								addedToPreferedSlot = true
							else
								abilityInPreferedSlot = hero:GetAbilityByIndex(backUpSlotNumber - 1)

								if abilityInPreferedSlot and abilityInPreferedSlot:GetAbilityName() == "generic_hidden" then
									abilityToChange = abilityInPreferedSlot
								end
							end
						end

						if abilityToChange then
							hero:RemoveAbilityByHandle(abilityToChange)
						end

						--ability should be added to the removed slots (or if prefered slost can't be removed to the first available slot)
						--if not use: SetAbilityByIndex
						local newAbility = hero:AddAbility(abilityName)
						if newAbility then						
							self:SetNewAddedAbility(newAbility, hero)
							
							if data["hidden"] then
								newAbility:SetHidden(data["hidden"])
							end

							if data["set_level"] and data["set_level"] > 0 then
								newAbility:SetLevel(1)
								newAbility:RefreshIntrinsicModifier()
							end

							--check if new ability is second ultimate and there is no free slots 4/5
							if not addedToPreferedSlot and ability:GetAbilityType() == 1 then
								local isGrantedByScepter = self:IsAbilityGrantedByScepter(abilityName)
								local isGrantedByShard = self:IsAbilityGrantedByShard(abilityName)

								if isGrantedByScepter then
									newAbility.scepterManuallyHide = true

									if hero:HasScepter() then
										newAbility:SetLevel(1)
										newAbility:SetHidden(false)
									end
								end

								if isGrantedByShard then
									newAbility.shardManuallyShow = true

									if hero:_HasHeroAghanimShard() then
										newAbility:SetLevel(1)
										newAbility:SetHidden(false)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function CAbilityDraftRanked:VerifyAllTalents(hero)
    if not hero or hero:IsNull() then
        return
    end

    local abilityCount = hero:GetAbilityCount()
    local talentsToRemove = {}
    local talentCounts = 0

    for i = 0, abilityCount - 1 , 1 do
        local ability = hero:GetAbilityByIndex(i)

        if ability and ability:IsAttributeBonus() and string.find(ability:GetAbilityName(), "special_bonus") and ability:GetAbilityName() ~= "special_bonus_attributes" then
            talentCounts = talentCounts + 1

            if talentCounts > 8 then
                table.insert(talentsToRemove, ability:GetAbilityName())
            end
        end
    end

    if talentCounts > 8 then
        print("THERE ARE TOO MANY TALENTS - GAME WILL CRASH!")

        --remove talents:
        for _, talentName in pairs(talentsToRemove) do
            print("remove talent: ", talentName)
            hero:RemoveAbility(talentName)
        end
    end
end

function CAbilityDraftRanked:GetSelectedHeroNames()
    local heroes = {}

    for _, heroName in pairs(self.playersHeroPicks) do
        table.insert(heroes, heroName)
    end

    return heroes
end

function CAbilityDraftRanked:GetSelectedHeroNamesInDraftingOrder()
    local heroes = {}
    local allPlayersOrder = self.playersIdPickOrder

    if #allPlayersOrder == 0 then
        print("simple version of hero pick order")
        allPlayersOrder = deepcopy(self.playersTeam["radiant"])
        TableMerge(allPlayersOrder, self.playersTeam["dire"])
    end

    for _, playerID in pairs(allPlayersOrder) do
        if self.playersHeroPicks[playerID] then
            local heroNamePicked = self.playersHeroPicks[playerID]
            table.insert(heroes, heroNamePicked)
        end
    end

    return heroes
end

function CAbilityDraftRanked:RandomAbilityBoard()
    local heroes = {}

    local allHeroes = self:GetAllAvailableHeroNames()
    allHeroes = shuffleTable(allHeroes)

    --get hero names picked by players in order they pick abilities
    heroes = self:GetSelectedHeroNamesInDraftingOrder()

    --remove picked hero names from all available heroes
    --needed to random other heroes to build ability draft
    for _, heroNamePicked in pairs(heroes) do
        for index, heroName in pairs(allHeroes) do
            if heroName == heroNamePicked then
                table.remove(allHeroes, index)
                break
            end
        end
    end

    local heroesCount = #heroes
    local missingHeroes = math.max(self.heroesAbilityCount - heroesCount, 0)

    if heroesCount > 10 then
        --self.jungleAbilityCount = self.jungleAbilityCount * 2
        self.extraUlts = 8
    end

    for i = 1, missingHeroes+self.extraUlts, 1 do
        local randomHeroElement = RandomInt(1, #allHeroes)

        local randomHeroName = allHeroes[randomHeroElement]
        
        --if i == 1 then
		--	randomHeroName = "npc_dota_hero_arc_warden"
        --end
    
        table.insert(heroes, randomHeroName)

        table.remove(allHeroes, randomHeroElement)
    end

    self.allUsedAbilityHeroNames = shallowcopy(heroes)

    self:SelectRandomHeroAbilitiesToPick(heroes, allHeroes)
    self:SelectRandomJungleAbilitiesToPick(self.jungleAbilityCount, false)

    CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)
end

function CAbilityDraftRanked:SelectRandomJungleAbilitiesToPick(count, excludeSelected)
    local jungleAbilities = self:GetAllAvailableJungleAbilities(excludeSelected)

    for i = 1, count, 1 do
        if #jungleAbilities > 0 then
            local randomAbilityIndex = RandomInt(1, #jungleAbilities)
            local randomAbilityName = jungleAbilities[randomAbilityIndex]
    
            table.insert(self.availableAbilities["jungle"], {ability_name = randomAbilityName, available = "1", upgrade_status=""})
            table.remove(jungleAbilities, randomAbilityIndex)
        end
    end
end

function CAbilityDraftRanked:SelectRandomHeroAbilitiesToPick(heroes, allHeroes)
	local abilityNumbers = {1, 2, 3, 6}

	-- 1 means available to pick
	-- 0 means already picked by player (will be updated in other function)
	for _, heroName in ipairs(heroes) do
		if not self.heroAbilityOwners[heroName] then
			self.heroAbilityOwners[heroName] = {}
		end

		-- other random hero is for the case when base hero has no 3 base abilities or no ultimate (for example: Invoker)
		local otherRandomHero = ""
		local otherRandomHeroTableIndex = nil
		local otherRandomHeroUsed = false

		if allHeroes then
			for index, newHeroName in pairs(allHeroes) do
				if newHeroName ~= heroName and not self:GetSpecialHeroAbilityNames(newHeroName) then
					otherRandomHero = newHeroName
					otherRandomHeroTableIndex = index
					break
				end
			end				
		end

		local addedBaseAbilities = 0
		local addedUltimateAbilities = 0

		local specialAbilities = self:GetSpecialHeroAbilityNames(heroName)

		if specialAbilities then
			local baseAbilities = specialAbilities["base"]
			local ultimateAbilities = specialAbilities["ultimate"]

			if baseAbilities then
				if #baseAbilities <= 3 then
					for _, abilityName in ipairs(baseAbilities) do
						local abilityInfo = {
							ability_name = abilityName,
							available = "1"
						}

						table.insert(self.availableAbilities["base"], abilityInfo)
						table.insert(self.heroAbilityOwners[heroName], abilityName)

						addedBaseAbilities = addedBaseAbilities + 1
					end
				else
					local baseAbilitiesCopy = shallowcopy(baseAbilities)
	
					for i = 1, 3, 1 do
						local randomAbilityIndex = RandomInt(1, #baseAbilitiesCopy)
						local randomAbilityName = baseAbilitiesCopy[randomAbilityIndex]

						local abilityInfo = {
							ability_name = randomAbilityName,
							available = "1"
						}

						table.insert(self.availableAbilities["base"], abilityInfo)
						table.insert(self.heroAbilityOwners[heroName], randomAbilityName)

						table.remove(baseAbilitiesCopy, randomAbilityIndex)

						addedBaseAbilities = addedBaseAbilities + 1
					end
				end
			end

			--facets allow heroes to select ultimate from 2 or more
			if ultimateAbilities and type(ultimateAbilities) == "table" and #ultimateAbilities > 0 then
				local randomUltimateName = ultimateAbilities[RandomInt(1, #ultimateAbilities)]

				local abilityInfo = {
					ability_name = randomUltimateName,
					available = "1"
				}

				table.insert(self.availableAbilities["ultimate"], abilityInfo)

				if not self.heroAbilityOwners[otherRandomHero] then
					self.heroAbilityOwners[otherRandomHero] = {}
				end
				
				table.insert(self.heroAbilityOwners[otherRandomHero], randomUltimateName)

				addedUltimateAbilities = addedUltimateAbilities + 1
			end
		else
			for _, abilityNr in ipairs(abilityNumbers) do
				local abilityNumberName = "Ability" .. abilityNr

				local heroData = DOTAGameManager:GetHeroDataByName_Script(heroName)
				if heroData then
					local abilityName = heroData[abilityNumberName] or ""

					if abilityName and abilityName ~= "" and abilityName ~= "generic_hidden" and not IsInnateAbility_AD2023(abilityName) then
						local abilityInfo = {
							ability_name = abilityName,
							available = "1"
						}
		
						if abilityNr == 6 then
							table.insert(self.availableAbilities["ultimate"], abilityInfo)
							addedUltimateAbilities = addedUltimateAbilities + 1
						else
							table.insert(self.availableAbilities["base"], abilityInfo)
							addedBaseAbilities = addedBaseAbilities + 1
						end

						table.insert(self.heroAbilityOwners[heroName], abilityName)
					end
				end
			end
		end

		--add missing abilities from other hero if this hero has less than 3
		local missingAbilitiesCounter = 0

		while addedBaseAbilities < 3 do
			local missingAbilities = 3 - addedBaseAbilities
			
			for i = 1, missingAbilities, 1 do
				if addedBaseAbilities >= 3 then
					break
				end
				
				local heroData = DOTAGameManager:GetHeroDataByName_Script(otherRandomHero)
				
				if heroData then
					local abilityName = heroData["Ability" .. i]
					
					if abilityName and abilityName ~= "" and abilityName ~= "generic_hidden" and not IsInnateAbility_AD2023(abilityName) then
						otherRandomHeroUsed = true

						local abilityInfo = {
							ability_name = abilityName,
							available = "1"
						}
		
						table.insert(self.availableAbilities["base"], abilityInfo)

						if not self.heroAbilityOwners[otherRandomHero] then
							self.heroAbilityOwners[otherRandomHero] = {}
						end

						table.insert(self.heroAbilityOwners[otherRandomHero], abilityName)

						addedBaseAbilities = addedBaseAbilities + 1
					end
				end
			end

			missingAbilitiesCounter = missingAbilitiesCounter + 1
			if missingAbilitiesCounter > 10 then
				break
			end
		end

		--add missing ultimate from other hero if this hero has not available ultimate
		local missingUltimatesCounter = 0

		while addedUltimateAbilities == 0 do
			local heroData = DOTAGameManager:GetHeroDataByName_Script(otherRandomHero)
			if heroData then
				local abilityName = heroData["Ability6"]
				
				if abilityName and abilityName ~= "" and abilityName ~= "generic_hidden" and not IsInnateAbility_AD2023(abilityName) then
					otherRandomHeroUsed = true

					local abilityInfo = {
						ability_name = abilityName,
						available = "1"
					}
					
					table.insert(self.availableAbilities["ultimate"], abilityInfo)

					if not self.heroAbilityOwners[otherRandomHero] then
						self.heroAbilityOwners[otherRandomHero] = {}
					end

					table.insert(self.heroAbilityOwners[otherRandomHero], abilityName)

					addedUltimateAbilities = addedUltimateAbilities + 1
				end
			end

			missingUltimatesCounter = missingUltimatesCounter + 1
			if missingUltimatesCounter > 10 then
				break
			end
		end

		if allHeroes and otherRandomHeroUsed and otherRandomHeroTableIndex ~= nil then
			table.insert (self.allUsedAbilityHeroNames, otherRandomHero)
			table.remove(allHeroes, otherRandomHeroTableIndex)
		end
	end

    --check if selected abilities have special upgrades
    local specialUpgrades = {}

    for _, data in pairs(self.availableAbilities) do
        for _, abilityInfo in pairs(data) do
            if abilityInfo["ability_name"] then
                local upgradesInfo = self.spellsUpgrade:GetAbilitySpecialUpgradesDescription(abilityInfo["ability_name"])

                if upgradesInfo and #upgradesInfo > 0 then
                    specialUpgrades[abilityInfo["ability_name"]] = upgradesInfo

                    abilityInfo["special_upgrade"] = true
                end

                --add scepter/shard info for custom aghanim status tooltips
                local aghanimsInfo = self:GetAbilityAghanimUpgrades(abilityInfo["ability_name"])

                if aghanimsInfo and aghanimsInfo["upgrade_status"] and aghanimsInfo["upgrade_status"] ~= "" then
                    CustomNetTables:SetTableValue( "ability_aghanim_upgrades", abilityInfo["ability_name"], aghanimsInfo)
                end
            end
        end
    end

    CustomNetTables:SetTableValue( "global_info", "ability_special_upgrades", specialUpgrades)
end

function CAbilityDraftRanked:RandomHeroTalentsForPlayers()
    local pickedHeroes = self.allUsedAbilityHeroNames
    
    if #pickedHeroes == 0 then
        pickedHeroes = self:GetSelectedHeroNames()
    end

    --create table with talents from all heroes picked by players
    for _, heroName in pairs(pickedHeroes) do
        self:AddHeroTalentsToTable(heroName, self.allSelectedHeroTalents)
    end
    
    local talentData = self:GetSelectedHeroesAllTalentsData()

    local allAvailableTalents = talentData["talents"] or {}
    local heroTalentsCountOnLevels = talentData["hero_talents_count"] or {}
    
    --create random talents for players
    local allplayersID = self:GetAllPlayersConnectedFromLobby()
    
    for _, playerID in pairs(allplayersID) do
        self:CreateRandomTalentsForPlayer(playerID, allAvailableTalents, heroTalentsCountOnLevels, false)
    end
end

function CAbilityDraftRanked:CreateRandomTalentsForPlayer(playerID, allAvailableTalents, heroTalentsCountOnLevels, rerollTalents)
    if not playerID or type(allAvailableTalents) ~= "table" or type(heroTalentsCountOnLevels) ~= "table" then
        return
    end

    if not self.playersTreeTalents[playerID] or rerollTalents then
        self.playersTreeTalents[playerID] = {
            level_1 = {},
            level_2 = {},
            level_3 = {},
            level_4 = {},
        }
    end

    local heroName = self.playersHeroPicks[playerID]
    local isHeroRangedAttacker = self:IsHeroRangedAttacker(heroName)
	--local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    if heroName then
        --create base talents list
        if not self.heroBaseTalents[heroName] then
            self.heroBaseTalents[heroName] = self:GetHeroValidTalentNamesOnLevels(heroName)
        end

        --set player talents to base talents
        if not self.playersPickedTalents[playerID] then
            self.playersPickedTalents[playerID] = deepcopy(self.heroBaseTalents[heroName])

            CustomNetTables:SetTableValue( "players_talent_picks", string.format( "%d", playerID ), self.playersPickedTalents[playerID])
        end
        
        --1. Remove hero base talents from available talents (players have option to remove selected talent restoring them to default hero talent)
        -- Remove also other talents of the same type (to avoid repeat talents like +250 dmg and +200 dmg on the same level)
        if self.heroBaseTalents[heroName] then
            self:UpdateTalentsTableToValidTalents(self.heroBaseTalents[heroName], allAvailableTalents)
        end

        --1a. Remove hero picked talents (they will be different from base talents if player swapped talents and used reroll talents)
        -- (to avoid add talents that player already has picked)
        -- Remove also other talents of the same type (to avoid repeat talents like +250 dmg and +200 dmg on the same level)
        if rerollTalents and self.playersPickedTalents[playerID] then
            self:UpdateTalentsTableToValidTalents(self.playersPickedTalents[playerID], allAvailableTalents)
        end

        --2.shuffle table for every player
        for talentLevel, talents in pairs(allAvailableTalents) do
            allAvailableTalents[talentLevel] = shuffleTable(talents)
        end

        --3. Choose talents
        for talentLevel, playerTalents in pairs(self.playersTreeTalents[playerID]) do
            local randomAvailableTalents = allAvailableTalents[talentLevel]
            
            if randomAvailableTalents then
                local heroLevelsCount = shallowcopy(heroTalentsCountOnLevels)

                for i = 1, self.talentsLevelCount , 1 do
                    local desiredTalentType = ""

                    if heroLevelsCount[talentLevel] and heroLevelsCount[talentLevel] > 0 and RandomInt(0, 1) == 1 then
                        desiredTalentType = "hero_talent"
                    end

                    for _, talentData in pairs(randomAvailableTalents) do
                        if talentData["talent_name"] and talentData["ability_names"] and talentData["talent_type"] then
                            local isValidTalent = true
                            local hasPlayerThisTalent = false

                            if desiredTalentType == "hero_talent" and talentData["talent_type"] ~= desiredTalentType  then
                                isValidTalent = false
                            end

                            if desiredTalentType == "" and talentData["talent_type"] == "hero_talent"  then
                                isValidTalent = false
                            end

                            if not isHeroRangedAttacker and string.find(talentData["talent_name"], "special_bonus_attack_range") then
                                isValidTalent = false
                            end

                            if isHeroRangedAttacker and string.find(talentData["talent_name"], "special_bonus_cleave") then
                                isValidTalent = false
                            end
							
							if talentData["talent_type"] == "hero_talent" and EXCLUDED_HERO_BASESTATTALENTS[talentData["talent_name"]] then
								isValidTalent = false
							end

							local requiredAbilities = talentData["ability_names"]
							for _, abilityName in pairs(requiredAbilities) do
								--print(abilityName)
								--print("IS INNATE?: " .. tostring(IsInnateAbility_AD2023(abilityName)))

								local requiredFacet
								if _G.HERO_BIND_ABILITIES[heroName] and _G.HERO_BIND_ABILITIES[heroName][abilityName] and _G.HERO_BIND_ABILITIES[heroName][abilityName]["required_facet"] then
									requiredFacet= _G.HERO_BIND_ABILITIES[heroName][abilityName]["required_facet"]
								end

								if IsInnateAbility_AD2023(abilityName) or (requiredFacet and (requiredFacet == 1 or requiredFacet == 2)) then
									isValidTalent = false
								end
							end
							--print(isValidTalent)

                            if isValidTalent then
                                for _, playerTalentData in pairs(playerTalents) do

                                    --check if player already has this talent (the same name)
                                    if playerTalentData["talent_name"] and playerTalentData["talent_name"] == talentData["talent_name"] then
                                        hasPlayerThisTalent = true
                                        break
                                    end

                                    --check if player already has this type talent (except hero talents that can repeat but not exactly the same)
                                    if playerTalentData["talent_type"] and playerTalentData["talent_type"] ~= "" and playerTalentData["talent_type"] ~= "hero_talent"
                                        and playerTalentData["talent_type"] == talentData["talent_type"] then
                                        hasPlayerThisTalent = true
                                        break
                                    end
                                end
                                
                                if not hasPlayerThisTalent then
                                    table.insert(self.playersTreeTalents[playerID][talentLevel], {
                                        talent_name = talentData["talent_name"],
                                        talent_type = talentData["talent_type"],
                                        ability_names = talentData["ability_names"],
                                        custom_icon = talentData["custom_icon"],
                                        picked = 0
                                    })

                                    if heroLevelsCount[talentLevel] and heroLevelsCount[talentLevel] > 0 then
                                        heroLevelsCount[talentLevel] = heroLevelsCount[talentLevel] - 1
                                    end

                                    --break when correct talent added to table
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        CustomNetTables:SetTableValue( "talent_options", string.format( "%d", playerID ), self.playersTreeTalents[playerID])
    end
end

function CAbilityDraftRanked:UpdateTalentsTableToValidTalents(tableToVerify, tableToUpdate)
    if not tableToVerify or type(tableToVerify) ~= "table" or not tableToUpdate or type(tableToUpdate) ~= "table" then
        return
    end

    for talentLevel, talentsName in pairs(tableToVerify) do
        for _, pickedTalentName in pairs(talentsName) do
            local pickedTalentType = self:GetTalentTypeByName(pickedTalentName) or ""

            if tableToUpdate[talentLevel] then
                local validTalents = {}

                for _, talentData in ipairs(tableToUpdate[talentLevel]) do
                    if talentData["talent_name"] and talentData["talent_type"] then
                        if talentData["talent_name"] ~= pickedTalentName and talentData["talent_type"] ~= pickedTalentType then
                            table.insert(validTalents, talentData)
                        end
                    end
                end

                tableToUpdate[talentLevel] = validTalents
            end
        end
    end
end

function CAbilityDraftRanked:GetAbilityNamesConnectedToTalent(heroName, talentName)
    local result = {
        type = "",
        relation = "",
        ability_names = {}
    }

    --check if talents has hard coded ability
    local hardCodedAbilityName = self:GetHeroTalentAbilityHardCoded(talentName)

    if hardCodedAbilityName and hardCodedAbilityName ~= "" then
        result["type"] = "hero_talent"
        result["relation"] = "any"
        table.insert(result["ability_names"], hardCodedAbilityName)

        return result
    end

    local heroData = DOTAGameManager:GetHeroDataByName_Script(heroName)
    if not heroData then
        return result
    end

    --check if talent is base type
    local connectedItemName = self:GetBaseTalentConnectedItemName(talentName)

    if connectedItemName and connectedItemName ~= "" then
        result["type"] = "base"
        result["relation"] = "any"
        table.insert(result["ability_names"], connectedItemName)

        return result
    end

    --check if talent has linked ability draft key
    local talentKV = GetAbilityKeyValuesByName(talentName)
    local abilityDraftKeyName = "ad_linked_abilities"
    local connectedAbilityName = ""

	if talentKV then
		if talentKV[abilityDraftKeyName] and type(talentKV[abilityDraftKeyName]) == "string" and talentKV[abilityDraftKeyName] ~= "" then
			connectedAbilityName = talentKV[abilityDraftKeyName]
		else
			local abilityValues = talentKV["AbilityValues"]
	
			if abilityValues then
				for key, value in pairs(abilityValues) do
					if type(value) == "string" then
						if key == abilityDraftKeyName then
							connectedAbilityName = value
							break
						end
					elseif type(value) == "table" then
						for nestedKey, nestedValue in pairs(value) do
							if nestedKey == abilityDraftKeyName and type(nestedValue) == "string" then
								connectedAbilityName = nestedValue
								break
							end
						end
					end
				end
			end
		end

        if connectedAbilityName ~= "" then
            if string.find(connectedAbilityName, " && ") then
                local abilityNames = string.split(connectedAbilityName, " && ")
    
                if abilityNames and type(abilityNames) == "table" and #abilityNames > 0 then
                    result["type"] = "hero_talent"
                    result["relation"] = "and"
                    result["ability_names"] = abilityNames
            
                    return result
                end

            elseif string.find(connectedAbilityName, " || ") then
                local abilityNames = string.split(connectedAbilityName, " || ")
                
                if abilityNames and type(abilityNames) == "table" and #abilityNames > 0 then
                    result["type"] = "hero_talent"
                    result["relation"] = "or"
                    result["ability_names"] = abilityNames
            
                    return result
                end
            else
                result["type"] = "hero_talent"
                result["relation"] = "any"
                table.insert(result["ability_names"], connectedAbilityName)
        
                return result
            end
        end
    end

    --check hero abilities
    local specialAbilities = self:GetSpecialHeroAbilityNames(heroName)
    local heroAbilities = {}

    if specialAbilities then
        for _, abilityNameData in pairs(specialAbilities) do
            if type(abilityNameData) == "table" then
                for _, abilityName in pairs(abilityNameData) do
                    table.insert(heroAbilities, abilityName)
                end
            elseif type(abilityNameData) == "string" then
                table.insert(heroAbilities, abilityNameData)
            end
        end
    else
        local abilityNumbers = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

        for _, abilityNumber in pairs(abilityNumbers) do
            local abilityNumberName = "Ability" .. abilityNumber

            if heroData[abilityNumberName] and heroData[abilityNumberName] ~= "" and heroData[abilityNumberName] ~= 0 then
                table.insert(heroAbilities, heroData[abilityNumberName])
            end
        end
    end

    for _, abilityName in pairs(heroAbilities) do
        local abilityKV = GetAbilityKeyValuesByName(abilityName)

        if abilityKV then
            local abilityValues = abilityKV["AbilityValues"]

			if abilityValues then
				for _, values in pairs(abilityValues) do
					if type(values) == "table" then
						for key, value in pairs(values) do
							if key == talentName or (key == "LinkedSpecialBonus" and value == talentName) then

								result["type"] = "hero_talent"
								result["relation"] = "any"
								table.insert(result["ability_names"], abilityName)
						
								return result
							end
						end
					end
				end
			end
		end
	end

	--check talent name contains ability name
	for _, abilityName in pairs(heroAbilities) do
		if string.find(talentName, abilityName) then
			result["type"] = "hero_talent"
			result["relation"] = "any"
			table.insert(result["ability_names"], abilityName)

			return result
		end
	end

    return result
end

function CAbilityDraftRanked:GetAbilityAghanimUpgrades(abilityName)
    local scepterShardInfo = self:GetScepterAndShardUpgradeInfo(abilityName)

    if string.find(scepterShardInfo["upgrade_status"], "scepter") then
        local scepterAbility = abilityName
        if scepterShardInfo["scepter_ability"] ~= abilityName then
            scepterAbility = scepterShardInfo["scepter_ability"]
            scepterShardInfo["scepter_keys"] = self:GetAllAbilityKeyNames(scepterAbility)
        else
            scepterShardInfo["scepter_keys"] = self:GetAbilityKeyNamesContainString(scepterAbility, "scepter")
        end
    end

    if string.find(scepterShardInfo["upgrade_status"], "shard") then
        local shardAbility = abilityName
        if scepterShardInfo["shard_ability"] ~= abilityName then
            shardAbility = scepterShardInfo["shard_ability"]
            scepterShardInfo["shard_keys"] = self:GetAllAbilityKeyNames(shardAbility)
        else
            scepterShardInfo["shard_keys"] = self:GetAbilityKeyNamesContainString(shardAbility, "shard")
        end
    end

    return scepterShardInfo
end

function CAbilityDraftRanked:GetAllAbilityKeyNames(abilityName)
    local result = {}
    local abilityKV = GetAbilityKeyValuesByName(abilityName)

    if not abilityKV then
        return result
    end

    local abilityValues = abilityKV["AbilityValues"]
    local abilitySpecial = abilityKV["AbilitySpecial"]

    if abilityValues then
        for key, _ in pairs(abilityValues) do
            table.insert(result, key)
        end
    elseif abilitySpecial then
        for _, values in pairs(abilitySpecial) do
            for key, _ in pairs(values) do
                if key ~= "var_type" and key ~= "RequiresScepter" and key ~= "LinkedSpecialBonus" then
                    table.insert(result, key)
                end
            end
        end
    end

    return result
end

function CAbilityDraftRanked:GetAbilityKeyNamesContainString(abilityName, str)
    local result = {}
    local abilityKV = GetAbilityKeyValuesByName(abilityName)

    if not abilityKV then
        return result
    end

    local abilityValues = abilityKV["AbilityValues"]
    local abilitySpecial = abilityKV["AbilitySpecial"]

    if abilityValues then
        for key, values in pairs(abilityValues) do
            if type(values) == "string" and string.find(string.lower(key), str) then
                table.insert(result, key)
            elseif type(values) == "table" then
                for valueName, _ in pairs(values) do
                    if string.find(string.lower(valueName), str) then
                        table.insert(result, key)

                        break
                    end
                end
            end
        end
    elseif abilitySpecial then
        for _, values in pairs(abilitySpecial) do
            local found = false
            for key, _ in pairs(values) do
                if string.find(string.lower(key), str) then
                    if key ~= "RequiresScepter" then
                        table.insert(result, key)
                    else
                        found = true
                    end

                    break
                end
            end

            if found then
                for key, _ in pairs(values) do
                    if key ~= "var_type" and key ~= "RequiresScepter" and key ~= "LinkedSpecialBonus" then
                        table.insert(result, key)
                    end
                end
            end
        end
    end

    return result
end

--Handle also Ban Abilities
function CAbilityDraftRanked:AbilitySelect(eventSourceIndex, event)
    if not event.ability_name or not event.ability_type or not event.player_id then
        return
    end

    local abilityType = event.ability_type

    if event.ctrl_hold and event.ctrl_hold == 1 and event.suggest_text then
        -- print("ctrl clicked!")
        local hPlayer = PlayerResource:GetPlayer( event.player_id )
        if hPlayer then
            Say(hPlayer, event.suggest_text, true)
        end
    end

    if event.alt_hold and event.alt_hold == 1 and event.request_text then
        -- print("alt clicked!")
        local hPlayer = PlayerResource:GetPlayer( event.player_id )
        if hPlayer then
            Say(hPlayer, event.request_text, true)
        end
    end
    
    if not self.hasBanned[(event.player_id+1)*100+2] and self.currentSelectionPhase == 2 and self.currentSelectionTimer >= 1
			and (not self.abilityBanVotes[(event.player_id+1)] or self.abilityBanVotes[(event.player_id+1)] and self.abilityBanVotes[(event.player_id+1)]["ability_name"] and not (self.abilityBanVotes[(event.player_id+1)]["ability_name"] == event.ability_name))
			and (not self.abilityBanVotes[(event.player_id+1)*100+1] or self.abilityBanVotes[(event.player_id+1)*100+1] and self.abilityBanVotes[(event.player_id+1)*100+1]["ability_name"] and not (self.abilityBanVotes[(event.player_id+1)*100+1]["ability_name"] == event.ability_name))
			and (not self.abilityBanVotes[(event.player_id+1)*100+2] or self.abilityBanVotes[(event.player_id+1)*100+2] and self.abilityBanVotes[(event.player_id+1)*100+2]["ability_name"] and not (self.abilityBanVotes[(event.player_id+1)*100+2]["ability_name"] == event.ability_name))
			and (not self.abilityBanVotes[(event.player_id+1)*100+3])  then

        if not self.hasBanned[(event.player_id+1)] then
            self.abilityBanVotes[event.player_id+1] = {
                ability_name = event.ability_name,
                ability_type = event.ability_type
            }
        elseif not self.hasBanned[(event.player_id+1)*100+1] then
            self.abilityBanVotes[(event.player_id+1)*100+1] = {
                ability_name = event.ability_name,
                ability_type = event.ability_type
            }
        elseif not self.hasBanned[(event.player_id+1)*100+2] then
            self.abilityBanVotes[(event.player_id+1)*100+2] = {
                ability_name = event.ability_name,
                ability_type = event.ability_type
            }
        else
            self.abilityBanVotes[(event.player_id+1)*100+3] = {
                ability_name = event.ability_name,
                ability_type = event.ability_type
            }
        end

        --set abiity ban voted
        for _, abilities in pairs(self.availableAbilities) do
            local abilityFound = false

            for _, abilityData in pairs(abilities) do
                if abilityData["ability_name"] == event.ability_name then
                    abilityData["ban_voted"] = "1"

                    abilityFound = true

                    break
                end
            end

            if abilityFound then
                break
            end
        end
        
        CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)

        if not self.hasBanned[(event.player_id+1)] then
            self.hasBanned[(event.player_id+1)] = true
        elseif not self.hasBanned[(event.player_id+1)*100+1] then
            self.hasBanned[(event.player_id+1)*100+1] = true
        elseif not self.hasBanned[(event.player_id+1)*100+2] then
            self.hasBanned[(event.player_id+1)*100+2] = true
        elseif not self.hasBanned[(event.player_id+1)*100+3] then
            self.hasBanned[(event.player_id+1)*100+3] = true
        end

        return
    end

    if self.currentSelectionPhase < 3 then
        return
    end

    --check if current player turn pick
    local currentPlayerTurn = false
    if self.playersPickOrder["current_player_pick"] and self.playersPickOrder["current_player_pick"]["player_id"] and 
        self.playersPickOrder["current_player_pick"]["player_id"] == event.player_id    
    then
        currentPlayerTurn = true
    end

    if not currentPlayerTurn then
        -- print("no player turn!")
        return
    end

    --check if player has free pick count (players can pick 1 ability per round, but if missed previous round he can pick 2 abilities, etc.)
    local availablePlayerPicks = 0
    local pickedAbilityCount = 0

    if self.playersPickedAbilitiesCount[event.player_id] and self.playersPickedAbilitiesCount[event.player_id]["base"] and
        self.playersPickedAbilitiesCount[event.player_id]["ultimate"]

        then
        pickedAbilityCount = self.playersPickedAbilitiesCount[event.player_id]["base"] + self.playersPickedAbilitiesCount[event.player_id]["ultimate"]
    end

    availablePlayerPicks = math.max(self.playersPickOrder["current_player_pick"]["pick_number"] - pickedAbilityCount, 0)

    if availablePlayerPicks == 0 then
        return
    end

    --check if player ability slot is free
    local abilitySlotAvailable = false

    local chosenAbilitySlot = "base"
    if abilityType == "ultimate" then
        chosenAbilitySlot = "ultimate"
    end

    if self.playersPickedAbilities[event.player_id] then
        for _, abilitySlotData in pairs(self.playersPickedAbilities[event.player_id]) do
            if abilitySlotData["ability_slot"] and string.starts(abilitySlotData["ability_slot"], chosenAbilitySlot) then
                if abilitySlotData["ability_name"] and abilitySlotData["ability_name"] == "" then
                    abilitySlotAvailable = true
                    break
                end
            end
        end
    end

    if not abilitySlotAvailable then
        print("no free slots for this ability!")
        return
    end

    --check if ability is available
    local abilityAvailable = false
    if self.availableAbilities[abilityType] then
        for _, abilityData in pairs(self.availableAbilities[abilityType]) do
            if abilityData["ability_name"] == event.ability_name and abilityData["available"] == "1" then
                print("ability available for pick")
                abilityAvailable = true
                break
            end
        end
    end

    if not abilityAvailable then
        print("ability not available, already picked!")
        return
    end

    --set abiity not available
    if self.availableAbilities[abilityType] then
        for _, abilityData in pairs(self.availableAbilities[abilityType]) do
            if abilityData["ability_name"] == event.ability_name then
				--TOREMOVEMAYBE
                abilityData["available"] = "0"
                break
            end
        end
    end

    CustomNetTables:SetTableValue( "ability_options", "0", self.availableAbilities)

    --increase picked abilities count
    if self.playersPickedAbilitiesCount[event.player_id] and self.playersPickedAbilitiesCount[event.player_id][chosenAbilitySlot] then
        self.playersPickedAbilitiesCount[event.player_id][chosenAbilitySlot] = self.playersPickedAbilitiesCount[event.player_id][chosenAbilitySlot] + 1
    end

    --take the first free ability slot
    if self.playersPickedAbilities[event.player_id] then
        for _, abilitySlotData in ipairs(self.playersPickedAbilities[event.player_id]) do
            if abilitySlotData["ability_slot"] and string.starts(abilitySlotData["ability_slot"], chosenAbilitySlot) and abilitySlotData["ability_name"] == "" then
                abilitySlotData["ability_name"] = event.ability_name
                break;
            end
        end
    end

    CustomNetTables:SetTableValue( "players_ability_picks", string.format( "%d", event.player_id ), self.playersPickedAbilities[ event.player_id])

    --update order to show current player left picks
    if self.playersPickOrder["current_player_pick"] then
        self.playersPickOrder["current_player_pick"]["pick_count"] = availablePlayerPicks - 1
    end

    CustomNetTables:SetTableValue( "ability_pick_order", "0", self.playersPickOrder)
end

function CAbilityDraftRanked:TalentReroll(eventSourceIndex, event)
    if not event.player_id then
        return
    end

    local playerID = event.player_id
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end

    --check available Rerolls
    if self._vPlayerStats[playerID] then

        --Currently disabled -> cause of Valve Custom Games Monetization rules
        -- all players have rerolls not only Patrons
        local isPatron = (self._vPlayerStats[playerID]["supporter_level"] and self._vPlayerStats[playerID]["supporter_level"] > 0)
        local talentRerolls = self._vPlayerStats[playerID]["talent_rerolls"]

        if talentRerolls > 0 then
            local talentData = self:GetSelectedHeroesAllTalentsData()
    
            local allAvailableTalents = talentData["talents"] or {}
            local heroTalentsCountOnLevels = talentData["hero_talents_count"] or {}
        
            self:CreateRandomTalentsForPlayer(playerID, allAvailableTalents, heroTalentsCountOnLevels, true)

            self._vPlayerStats[playerID]["talent_rerolls"] = self._vPlayerStats[playerID]["talent_rerolls"] - 1
            CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), self._vPlayerStats[playerID] )
        end
    end
end

function CAbilityDraftRanked:HeroReroll(eventSourceIndex, event)
    if not event.player_id then
        return
    end

    local playerID = event.player_id
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end

    --if hero confirm pick then don't make rerolls
    if self.playersHeroPicksConfirm[playerID] then
        return
    end

    --check available Rerolls
    if self._vPlayerStats[playerID] then

        --Currently disabled -> cause of Valve Custom Games Monetization rules
        -- all players have rerolls not only Patrons
        local isPatron = (self._vPlayerStats[playerID]["supporter_level"] and self._vPlayerStats[playerID]["supporter_level"] > 0)
        local heroRerolls = self._vPlayerStats[playerID]["hero_rerolls"]

        if heroRerolls > 0 then
            table.insert(self.heroRerollQueue, playerID)

            self._vPlayerStats[playerID]["hero_rerolls"] = self._vPlayerStats[playerID]["hero_rerolls"] - 1
            CustomNetTables:SetTableValue( "players_info", string.format( "%d", playerID ), self._vPlayerStats[playerID] )
        end
    end
end

function CAbilityDraftRanked:TalentRemoved(eventSourceIndex, event)
    if not event.talent_level or not event.player_id or not event.talent_slot then
        return
    end

    local talentIndex = 1

    if event.talent_slot == "left" then
        talentIndex = 2
    end

    if self.playersPickedTalents[event.player_id] and self.playersPickedTalents[event.player_id][event.talent_level] then
        
        local heroName = self.playersHeroPicks[event.player_id] or ""

        --verify if first slot is occupied by some talent if not add base hero talent or empty string (to keep table indexes)
        if talentIndex == 2 and not self.playersPickedTalents[event.player_id][event.talent_level][1] then
            local baseHeroTalent = ""

            if heroName and heroName ~= "" then
                if self.heroBaseTalents[heroName] and self.heroBaseTalents[heroName][event.talent_level] and self.heroBaseTalents[heroName][event.talent_level][1] then
                    baseHeroTalent = self.heroBaseTalents[heroName][event.talent_level][1]
                end
            end

            self.playersPickedTalents[event.player_id][event.talent_level][1] = baseHeroTalent
        end

        --update current removed talent by base hero talent or empty string if not found.
        local baseHeroTalent = ""
        local currentHeroTalent = ""
        local needUpate = true

        --verify if current player talent is the same as base hero talent
        if heroName and heroName ~= "" then
            if self.heroBaseTalents[heroName] and self.heroBaseTalents[heroName][event.talent_level] and self.heroBaseTalents[heroName][event.talent_level][talentIndex] then
                baseHeroTalent = self.heroBaseTalents[heroName][event.talent_level][talentIndex]

                if self.playersPickedTalents[event.player_id][event.talent_level][talentIndex] then
                    currentHeroTalent = self.playersPickedTalents[event.player_id][event.talent_level][talentIndex]
                    
                    if baseHeroTalent == currentHeroTalent then
                        needUpate = false
                    end
                end
            end
        end

        if needUpate then
            --update talent in removed slot
            self.playersPickedTalents[event.player_id][event.talent_level][talentIndex] = baseHeroTalent
            
            CustomNetTables:SetTableValue( "players_talent_picks", string.format( "%d", event.player_id ), self.playersPickedTalents[event.player_id])

            --set talent not picked
            if self.playersTreeTalents[event.player_id] and self.playersTreeTalents[event.player_id][event.talent_level] then
                local playerLevelTalents = self.playersTreeTalents[event.player_id][event.talent_level]

                for _, talentData in pairs(playerLevelTalents) do
                    if talentData["talent_name"] and talentData["talent_name"] == currentHeroTalent then
                        talentData["picked"] = 0

                        CustomNetTables:SetTableValue( "talent_options", string.format( "%d", event.player_id ), self.playersTreeTalents[event.player_id])
                        break
                    end
                end
            end
        end
    end
end

function CAbilityDraftRanked:TalentSelect(eventSourceIndex, event)
    if not event.talent_name or not event.talent_level or not event.player_id or not event.talent_slot then
        return
    end

    --check if talent is available (talents can't repeat on the same level)
    local talentAvailable = false
    if self.playersTreeTalents[event.player_id] and self.playersTreeTalents[event.player_id][event.talent_level] then
        local playerLevelTalents = self.playersTreeTalents[event.player_id][event.talent_level]

        for _, talentData in pairs(playerLevelTalents) do
            if talentData["talent_name"] and talentData["picked"] and talentData["talent_name"] == event.talent_name and talentData["picked"] == 0 then
                talentAvailable = true
                break
            end
        end
    end

    if self.playersPickedTalents[event.player_id] and self.playersPickedTalents[event.player_id][event.talent_level] then
        local playerPickedLevelTalents = self.playersPickedTalents[event.player_id][event.talent_level]

        for _, talentName in pairs(playerPickedLevelTalents) do
            if talentName == event.talent_name then
                talentAvailable = false
                break
            end
        end
    end

    if not talentAvailable then
        print("talent not available!")
        return
    end

    --if talent is already picked, remove this talent from picked talents
    --check if player talent level slot is free, if not, replace last picked talent (first in table)
    if self.playersPickedTalents[event.player_id] and self.playersPickedTalents[event.player_id][event.talent_level] then
        local playerPickedLevelTalents = self.playersPickedTalents[event.player_id][event.talent_level]

        if event.talent_slot == "left" then
            if not playerPickedLevelTalents[1] then
                playerPickedLevelTalents[1] = ""
            end

            playerPickedLevelTalents[2] = event.talent_name
        elseif event.talent_slot == "right" then
            playerPickedLevelTalents[1] = event.talent_name
        end
    end

    CustomNetTables:SetTableValue( "players_talent_picks", string.format( "%d", event.player_id ), self.playersPickedTalents[event.player_id])

    --set talent picked and unmark all other talents
    if self.playersTreeTalents[event.player_id] and self.playersTreeTalents[event.player_id][event.talent_level] and  
        self.playersPickedTalents[event.player_id] and self.playersPickedTalents[event.player_id][event.talent_level]
        
        then
        local playerLevelTalents = self.playersTreeTalents[event.player_id][event.talent_level]
        local playerPickedLevelTalents = self.playersPickedTalents[event.player_id][event.talent_level]

        for _, talentData in pairs(playerLevelTalents) do
            talentData["picked"] = 0

            for _, pickedTalentName in pairs(playerPickedLevelTalents) do
                if talentData["talent_name"] and talentData["talent_name"] == pickedTalentName then
                    talentData["picked"] = 1
                    break
                end
            end
        end

        CustomNetTables:SetTableValue( "talent_options", string.format( "%d", event.player_id ), self.playersTreeTalents[event.player_id])
    end
end

function CAbilityDraftRanked:AbilitySlotSwapped(eventSourceIndex, event)
    if not event.player_id or not event.ability_name or not event.previous_slot or not event.current_slot then
        return
    end

    if not self.playersPickedAbilities[event.player_id] then
        print("nie ma takiego gracza")
        return
    end

    --check if slots exist
    local currentSlotExist = false
    local previousSlotExist = false

    --check if this player has swapped ability in this slot
    local hasPlayerThisAbilityInSlot = false
    local abilitySlotIndex = nil

    --check if current slot is occupied by some other ability
    local swappedAbilityName = ""
    local swappedAbilitySlotIndex = nil

    for slotIndex, slotData in pairs(self.playersPickedAbilities[event.player_id]) do
        if slotData["ability_slot"] and slotData["ability_slot"] == event.previous_slot then
            previousSlotExist = true

            if slotData["ability_name"] and slotData["ability_name"] == event.ability_name then
                hasPlayerThisAbilityInSlot = true
                abilitySlotIndex = slotIndex
            end
        end

        if slotData["ability_slot"] and slotData["ability_slot"] == event.current_slot then
            currentSlotExist = true
            swappedAbilitySlotIndex = slotIndex

            if slotData["ability_name"] and slotData["ability_name"] ~= "" then
                swappedAbilityName = slotData["ability_name"]
            end
        end

    end

    if not currentSlotExist or not previousSlotExist then
        print("nie ma takich slotow")
        return
    end

    if not hasPlayerThisAbilityInSlot or not abilitySlotIndex then
        print("nie ma tego ability w slocie")
        return
    end

    if abilitySlotIndex and self.playersPickedAbilities[event.player_id][abilitySlotIndex] then
        --if current slot has ability move it to the previous slot or clear when there is no swapeed ability
        self.playersPickedAbilities[event.player_id][abilitySlotIndex]["ability_name"] = swappedAbilityName
    end

    --move ability to the new slot
    if swappedAbilitySlotIndex and self.playersPickedAbilities[event.player_id][swappedAbilitySlotIndex] then
        self.playersPickedAbilities[event.player_id][swappedAbilitySlotIndex]["ability_name"] = event.ability_name
    end

    CustomNetTables:SetTableValue( "players_ability_picks", string.format( "%d", event.player_id ), self.playersPickedAbilities[event.player_id])
end

function CAbilityDraftRanked:GetConnectedPlayers()
    local connectedPlayers = {}
    for nPlayerID = 0, DOTA_MAX_PLAYERS -1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS or PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
            if PlayerResource:IsValidPlayerID( nPlayerID ) and PlayerResource:GetConnectionState( nPlayerID ) < DOTA_CONNECTION_STATE_DISCONNECTED then
                table.insert( connectedPlayers, nPlayerID )
            end
        end
    end

    return connectedPlayers
end

function CAbilityDraftRanked:GetAllPlayersConnectedFromLobby()
    local players = {}

    for nPlayerID = 0, self.maxPlayers - 1 do
        if PlayerResource:IsValidPlayerID( nPlayerID ) and 
            PlayerResource:GetConnectionState( nPlayerID ) ~= DOTA_CONNECTION_STATE_ABANDONED and  
            PlayerResource:GetConnectionState( nPlayerID ) ~= DOTA_CONNECTION_STATE_UNKNOWN 
        then
            table.insert( players, nPlayerID )
        end
    end

    if IsInToolsMode() then
        players = {}

        for nPlayerID = 0, self.maxPlayers - 1 do
            if PlayerResource:IsValidPlayerID( nPlayerID ) then
                table.insert( players, nPlayerID )
            end
        end
    end

    return players
end

function CAbilityDraftRanked:GetAllPlayersInTeamConnectedFromLobby()
    local players = {}

    for nPlayerID = 0, self.maxPlayers - 1 do
        if PlayerResource:GetTeam( nPlayerID ) and PlayerResource:IsValidPlayerID( nPlayerID ) and 
            PlayerResource:GetConnectionState( nPlayerID ) ~= DOTA_CONNECTION_STATE_ABANDONED and  
            PlayerResource:GetConnectionState( nPlayerID ) ~= DOTA_CONNECTION_STATE_UNKNOWN
        then 
            table.insert( players, nPlayerID )
        end
    end

    if IsInToolsMode() then
        players = {}

        for nPlayerID = 0, self.maxPlayers - 1 do
            if PlayerResource:GetTeam( nPlayerID ) and PlayerResource:IsValidPlayerID( nPlayerID ) then
                table.insert( players, nPlayerID )
            end
        end
    end

    return players
end

function CAbilityDraftRanked:GetTotalPlayersCount()
    local players = self:GetAllPlayersConnectedFromLobby()

    if players then
        return #players
    end

    return 0
end

function CAbilityDraftRanked:GetAllRealPlayers()
    local players = {}
    for nPlayerID = 0, self.maxPlayers -1 do
        local steamID = tostring(PlayerResource:GetSteamAccountID(nPlayerID)) or "0"

        if PlayerResource:IsValidPlayerID( nPlayerID ) and steamID and steamID ~= "0" then
            table.insert( players, nPlayerID )
        end
    end

    return players
end

function CAbilityDraftRanked:HandleSpawnHeroIllusion(spawnedUnit, owner)
    Timers:CreateTimer(0.1, function ()
		local hero = owner:GetAssignedHero()
        self:ProcessIllusionAbilities(spawnedUnit, hero)
        
        if spawnedUnit:IsStrongIllusion() then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_player_ability_checker", {})
        end

        if not spawnedUnit:IsControllableByAnyPlayer() and spawnedUnit:HasAbility("hoodwink_sharpshooter") then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_strong_illusion_hoodwink_ult", {})
        end

		if spawnedUnit:HasModifier("modifier_dazzle_nothl_projection_soul_clone") then
			local ability = spawnedUnit:FindAbilityByName("dazzle_nothl_projection")
			ability:SetHidden(true)		

			ability = spawnedUnit:FindAbilityByName("dazzle_nothl_projection_end")
			ability:SetHidden(false)
		end

		if spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
			local ability = spawnedUnit:FindAbilityByName("arc_warden_tempest_double")
			ability:SetLevel(0)	
		end

		--update hero main Ability Upgrade modifier
        local upgradeModifier = spawnedUnit:AddNewModifier(hero, nil, "modifier_ability_value_upgrades_sb_2023", {})
            
        if upgradeModifier then
			upgradeModifier:UpdateAbilityUpgrades()
			spawnedUnit:CalculateStatBonus(true)
        end
    end)
end

-- updates illusion to match hero custom abilities
function CAbilityDraftRanked:ProcessIllusionAbilities(illusion, owner)
    if not illusion or not owner then
        return
    end

    for abilityIndex = 0, owner:GetAbilityCount() - 1 do
        
        local illusionAbility = illusion:GetAbilityByIndex(abilityIndex)
        local ownerAbility = owner:GetAbilityByIndex(abilityIndex)

        if illusionAbility then
            if not owner:HasAbility(illusionAbility:GetAbilityName()) then
                illusion:RemoveAbilityByHandle(illusionAbility)
            end
        end

        if ownerAbility and not ownerAbility:_IsSecretRequiredAbility() then
            local ownerAbilityName = ownerAbility:GetAbilityName()
            local isScepterAbility = self:IsAbilityGrantedByScepter(ownerAbilityName)
            local isShardAbility = self:IsAbilityGrantedByShard(ownerAbilityName)
            local abilityOnIllusion = illusion:FindAbilityByName(ownerAbilityName)
            
            if not abilityOnIllusion then
                if not EXCLUDED_STRONG_ILLUSION_ABILITIES[ownerAbilityName] and illusion:IsStrongIllusion() and isScepterAbility then
                    ownerAbilityName = ownerAbilityName .. "_no_scepter_info"
                end

                abilityOnIllusion = illusion:AddAbility(ownerAbilityName)

                if abilityOnIllusion then
                    --need to remove modifiers otherwise ability can be invalid
                    self:ClearBaseAbilityModifiers(illusion, abilityOnIllusion)
                end
            end
            
            if abilityOnIllusion and not abilityOnIllusion:IsNull() then
                -- Reorder new illusion ability to match owner slots
                illusion:RemoveAbilityFromIndexByName(ownerAbilityName)
                illusion:SetAbilityByIndex(abilityOnIllusion, ownerAbility:GetAbilityIndex())

                abilityOnIllusion:SetHidden(ownerAbility:IsHidden())

                local abilityLevel = ownerAbility:GetLevel()

                if illusion:IsStrongIllusion() and isScepterAbility and illusion:HasScepter() then
                    abilityLevel = 1
                end

                if illusion:IsControllableByAnyPlayer() and EXCLUDED_STRONG_ILLUSION_ABILITIES[ownerAbilityName] then
                    abilityLevel = 0
                    abilityOnIllusion:SetActivated(false)
                end

                if (not illusion:IsStrongIllusion() and ownerAbilityName ~= "hill_troll_rally_hero" and 
                    (EXCLUDED_ILLUSIONS_ABILITIES[ownerAbilityName] or TableContainsValue(JUNGLE_ABILITIES, ownerAbilityName)))
					and (not illusion:HasModifier("modifier_arc_warden_tempest_double") and not illusion:HasModifier("modifier_dazzle_nothl_projection_soul_clone"))
                then
                    abilityLevel = 0
                    abilityOnIllusion:SetActivated(false)

                    local modifierName = abilityOnIllusion:GetIntrinsicModifierName()
                    local modifier = illusion:FindModifierByName(modifierName)

                    if modifier then
                        modifier:Destroy()
                    end
                end

                if abilityLevel > 0 then
                    abilityOnIllusion:SetLevel(abilityLevel)
                end

                if abilityOnIllusion:GetAutoCastState() then
                    abilityOnIllusion:ToggleAutoCast()
                end

                if ownerAbility:GetAutoCastState() and (isScepterAbility or isShardAbility) then
                    abilityOnIllusion:ToggleAutoCast()
                end
            end
        end
    end

    self:VerifyAllTalents(illusion)
end

function CAbilityDraftRanked:SendChatCombatMessageTeam(message, team, oppositeTeam, playerID)
    local gameEvent = {}

    local otherTeam = DOTA_TEAM_BADGUYS

    if team == DOTA_TEAM_BADGUYS then
        otherTeam = DOTA_TEAM_GOODGUYS
    end

    gameEvent["player_id"] = playerID
    gameEvent["string_replace_token"] = PlayerResource:GetSelectedHeroName(playerID)
    gameEvent["message"] = message
    gameEvent["teamnumber"] = team

    FireGameEvent( "dota_combat_event_message", gameEvent )

    if oppositeTeam then
        gameEvent["teamnumber"] = otherTeam
        FireGameEvent( "dota_combat_event_message", gameEvent )

        --this seems to work only for both team
        if message == "#DOTA_Ability_Draft_NO_MMR_SAVE" then
            GameRules:SendCustomMessage(message, playerID, 0)
        end
    end

end

function CAbilityDraftRanked:DisconnectAbandonPlayerThink()
    return 1
end

function CAbilityDraftRanked:JungleTreasuresLimitThink()

    local timert = GameRules:GetGameTime()
    if timert > 100 and timert <= 360 then
        self.jungleTreasureLimitIncreasePerInterval = 0
        self.jungleTreasureLimitIncreaseInterval = 120
    elseif timert > 360 and timert <= 800 then
        self.jungleTreasureLimitIncreasePerInterval = 0
        self.jungleTreasureLimitIncreaseInterval = 240
    else
        self.jungleTreasureLimitIncreasePerInterval = 0
        self.jungleTreasureLimitIncreaseInterval = 360
    end

    for team, _ in pairs(self.jungleTreasuresLimit) do
        self.jungleTreasuresLimit[team] = self.jungleTreasuresLimit[team] + self.jungleTreasureLimitIncreasePerInterval

        local currentDrop = 0
        if self.jungleTreasuresDropped[team] then
            currentDrop = self.jungleTreasuresDropped[team]
        end
            
        CustomNetTables:SetTableValue( "jungle_treasures_limit", string.format( "%d", team ), {limit = self.jungleTreasuresLimit[team], dropped = currentDrop})
    end

    return self.jungleTreasureLimitIncreaseInterval
end

function CAbilityDraftRanked:treasurePerMinuteThink()

    local timert = GameRules:GetDOTATime(false, false)
    if (timert) >= 60 * self.adjustedTime then
        self.currentTime = 0
        local allPlayers = self:GetAllPlayersConnectedFromLobby()

        for _, playerID in pairs(allPlayers) do
            if self.playersHeroPicks[playerID] and self.playersHeroPicks[playerID] ~= "" then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero and hero.realPlayerHero then
                    
                    local goldenChest = 0
                    local reroll = 0

                    if (math.random() < 0.35) then
                        self._vPlayerStats[playerID]["reroll_ability_upgrades"] = self._vPlayerStats[playerID]["reroll_ability_upgrades"] + 1
                    end
                    if (math.random() < 0.2) then
                        self._vPlayerStats[playerID]["ability_golden_upgrades"] = self._vPlayerStats[playerID]["ability_golden_upgrades"] + 1
                        self._vPlayerStats[playerID]["ability_golden_upgrades_balance"] = self._vPlayerStats[playerID]["ability_golden_upgrades_balance"] + 1
                    end

                    local reservedChestID = DoUniqueString("chest_player_" .. playerID)

                    self.spellsUpgrade:CreatePlayerRandomSpellUpgrades(hero, true, false, 0, false, 1, false, reservedChestID)
                end
            end
        end
        
        self.adjustedTime =  self.adjustedTime + 1

		if self.balanceShuffleCooldown > 0 then
			self.balanceShuffleCooldown = self.balanceShuffleCooldown - 1
		end
    end

    return self.currentTimer
end

function CAbilityDraftRanked:CreateDummyTarget(playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then
        return
    end

    if hero.dummyTargetIndex then
        local oldDummyTarget = EntIndexToHScript(hero.dummyTargetIndex)
        if oldDummyTarget and not oldDummyTarget:IsNull() then
            UTIL_Remove(oldDummyTarget)
        end
    end

    -- print(GameRules:GetGameModeEntity():GetCustomHeroMaxLevel())

    local team = DOTA_TEAM_GOODGUYS

    if  PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
        team = DOTA_TEAM_BADGUYS
    end

    CreateUnitByNameAsync("npc_dota_hero_target_dummy", hero:GetAbsOrigin(), false, nil, nil, team, function (dummyTarget)
        if dummyTarget then
            dummyTarget.patronOwnerID = playerID
            hero.dummyTargetIndex = dummyTarget:entindex()
            dummyTarget:AddNewModifier(dummyTarget, nil, "modifier_phased", {})
            dummyTarget:AddNewModifier(hero, nil, "modifier_provide_vision", {})
        end
    end)
end
function CAbilityDraftRanked:UpdatePlayerStatsTable(nPlayerID)
end

function CAbilityDraftRanked:DestroyStartSoundEmiter(playerID)
	if self.musicSoundEmitersData[playerID] then
		local emiter = self.musicSoundEmitersData[playerID]["emiter"]
		local musicName = self.musicSoundEmitersData[playerID]["musicName"]

		if emiter and musicName then
			emiter:StopSound(musicName)
			emiter:Destroy()
		end
	end

	self.musicSoundEmitersData[playerID] = {}
end

function CAbilityDraftRanked:ServerReconnect(eventSourceIndex, args)
	if args['player_id'] == nil then
		return
	end

	local playerID = args['player_id']

	if not PlayerResource:IsValidPlayerID(playerID) then
		return
	end

	local player = PlayerResource:GetPlayer(playerID)

	if not self.playersServerReconnectTry[playerID] then
		self.playersServerReconnectTry[playerID] = {
			last_time = 0,
			status = 0,
			attempt = 0,
		}
	end

	local extraInfo = {
		duration = 3.0,
	}

	local currentAttempt = self.playersServerReconnectTry[playerID]["attempt"] or 0
	local currentStatus = self.playersServerReconnectTry[playerID]["status"] or 0

	if currentAttempt >= self.maxAttemptsToServerConnection then
		local text = "Reconnecting Limit Exceeded."

		if currentStatus == 0 then
			text = text .. " <font color='red'>Server Is NOT Responding!</font>"
		end
		
		extraInfo["text"] = text
		CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_info", extraInfo )	

		return	
	end

	if not self:CanPlayerUpdateDataFromServer(playerID) then
		local waitTime = math.floor((self.playersServerReconnectTry[playerID]["last_time"] + self.minIntervalToServerConnection - GameRules:GetGameTime()) * 10)/10
		extraInfo["text"] = "Next Reconnection Attempt Available In: " .. waitTime .. "s"
		
		CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_info", extraInfo )	

		return
	end

	_HTTPConnection:getUserInfo(playerID, true, 1)
	self.playersServerReconnectTry[playerID]["last_time"] = GameRules:GetGameTime()

	if currentAttempt then
		self.playersServerReconnectTry[playerID]["attempt"] = currentAttempt + 1
	end

	local gameBaseInfoTable = CustomNetTables:GetTableValue("global_info", "game_info")
	if not gameBaseInfoTable then
		gameBaseInfoTable = {}
	end

	gameBaseInfoTable["server_reconnecting_status"] = 1
	CustomNetTables:SetTableValue( "global_info", "game_info", gameBaseInfoTable)

	local extraInfo = {
		text = "Reconnecting To Server...",
		duration = 10
	}
	
	local player = PlayerResource:GetPlayer(playerID)
	CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_info", extraInfo )	
end

function CAbilityDraftRanked:CanPlayerUpdateDataFromServer(playerID)
    if not self.playersServerReconnectTry[playerID] then
        self.playersServerReconnectTry[playerID] = {
            last_time = 0,
            status = 0,
        }
    end

    if GameRules:GetGameTime() < self.playersServerReconnectTry[playerID]["last_time"] + self.minIntervalToServerConnection then
        return false
    end

    return true
end