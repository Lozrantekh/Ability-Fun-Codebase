modifier_ogre_magi_multicast_ad_ranked = class({})

modifier_ogre_magi_multicast_ad_ranked.singleTarget = {
	ogre_magi_fireblast = true,
	ogre_magi_unrefined_fireblast = true,
}

modifier_ogre_magi_multicast_ad_ranked.excludedAbilities = {
	riki_blink_strike = true,
	phantom_assassin_phantom_strike = true,
	pugna_decrepify = true,
	keeper_of_the_light_recall = true,
	earth_spirit_petrify = true,
	snapfire_gobble_up = true,
	clinkz_death_pact = true,
	wisp_tether = true,
	shadow_demon_disruption = true,
	bane_nightmare = true,
	meepo_poof_ad_ranked = true,
	vengefulspirit_nether_swap = true,
	chen_holy_persuasion = true,
	spirit_breaker_charge_of_darkness = true,
}

local noMulticast = {
    {name = "bane_nightmare"}, 
    {name = "bane_nightmare_end"},
    {name = "crystal_maiden_freezing_field"},
    {name = "crystal_maiden_freezing_field_stop"},
    {name = "morphling_morph_agi"},
    {name = "morphling_morph_str"},
    {name = "pudge_dismember"}, 
    {name = "pudge_eject"},
    {name = "tiny_tree_grab"},
    {name = "tiny_toss_tree"},
    {name = "tiny_tree_channel"},
    {name = "kunkka_x_marks_the_spot"},
    {name = "kunkka_return"},
    {name = "witch_doctor_voodoo_switcheroo"},
    {name = "faceless_void_time_walk"}, 
    {name = "faceless_void_time_walk_reverse"},
    {name = "dragon_knight_elder_dragon_form"},
    {name = "life_stealer_infest"}, 
    {name = "life_stealer_consume"},
    {name = "ancient_apparition_ice_blast"},
    {name = "ancient_apparition_ice_blast_release"},
    {name = "brewmaster_primal_split"},
    {name = "ogre_magi_fireblast"},
    {name = "ogre_magi_unrefined_fireblast"},
    {name = "ogre_magi_ignite"},
    {name = "ogre_magi_bloodlust"},
    {name = "rubick_telekinesis"}, 
    {name = "rubick_telekinesis_land"},
    {name = "rubick_telekinesis_land_self"},
    {name = "nyx_assassin_vendetta"}, 
    {name = "nyx_assassin_burrow"}, 
    {name = "nyx_assassin_unburrow"},
    {name = "naga_siren_song_of_the_siren"}, 
    {name = "naga_siren_song_of_the_siren_cancel"},
    {name = "keeper_of_the_light_illuminate"}, 
    {name = "keeper_of_the_light_illuminate_end"}, 
    {name = "keeper_of_the_light_spirit_form_illuminate"}, 
    {name = "keeper_of_the_light_spirit_form_illuminate_end"},
    {name = "wisp_tether"},
    {name = "wisp_tether_break"},
    {name = "wisp_relocate"},
    {name = "troll_warlord_berserkers_rage"},
    {name = "shredder_chakram"},
    {name = "shredder_return_chakram"},
    {name = "tusk_snowball"}, 
    {name = "tusk_launch_snowball"},
    {name = "elder_titan_ancestral_spirit"},
    {name = "elder_titan_move_spirit"},
    {name = "elder_titan_return_spirit"},
    {name = "ember_spirit_fire_remnant"},
    {name = "ember_spirit_activate_fire_remnant"},
    {name = "phoenix_icarus_dive"}, 
    {name = "phoenix_icarus_dive_stop"},
    {name = "phoenix_fire_spirits"},
    {name = "phoenix_launch_fire_spirit"},
    {name = "phoenix_sun_ray"}, 
    {name = "phoenix_sun_ray_toggle_move"},
    {name = "phoenix_sun_ray_stop"},
    {name = "phoenix_supernova"},
    {name = "techies_reactive_tazer"},
    {name = "techies_reactive_tazer_stop"},
    {name = "winter_wyvern_arctic_burn"},
    {name = "arc_warden_tempest_double"},
    {name = "monkey_king_tree_dance"},
    {name = "pangolier_gyroshell"},
    {name = "pangolier_gyroshell_stop"}, 
    {name = "pangolier_rollup"}, 
    {name = "pangolier_rollup_stop"},
    {name = "grimstroke_spirit_walk"},
    {name = "grimstroke_return"},
    {name = "mars_bulwark"},
    {name = "hoodwink_sharpshooter"},
    {name = "hoodwink_sharpshooter_release"},
    {name = "hoodwink_decoy"},
    {name = "hoodwink_hunters_boomerang"},
    {name = "dawnbreaker_celestial_hammer"},
    {name = "dawnbreaker_converge"},
    {name = "dawnbreaker_solar_guardian"},
    {name = "dawnbreaker_land"},
    {name = "primal_beast_onslaught"},
    {name = "primal_beast_onslaught_release"},
    {name = "enraged_wildkin_tornado"},
    {name = "item_ancient_janggo"},
    {name = "item_black_king_bar"},
    {name = "item_courier"},
    {name = "item_diffusal_blade"},
    {name = "item_diffusal_blade_2"},
    {name = "item_power_treads"},
    {name = "item_slippers_of_halcyon"},
    {name = "item_tpscroll"},
    {name = "item_travel_boots"},
    {name = "item_travel_boots_2"},
    {name = "item_urn_of_shadows"},
    {name = "lich_dark_ritual"},
    {name = "phoenix_sun_ray"},
    {name = "shredder_chakram"},
    {name = "shredder_chakram_2"},
    {name = "shredder_return_chakram"},
    {name = "shredder_return_chakram_2"},
    {name = "shredder_timber_chain"},
    --{name = "witch_doctor_death_ward"},
    {name = "phantom_assassin_phantom_strike"},
    {name = "life_stealer_infest"},
	{name = "pudge_meat_hook"},
    {name = "nyx_assassin_burrow"},
    {name = "nyx_assassin_unburrow"},

        -- Items
    {name = "item_smoke_of_deceit"},
    {name = "item_tango"},
    {name = "item_clarity"},
    {name = "item_enchanted_mango"},
    {name = "item_flask"},
    {name = "item_dust"},
    {name = "item_ward_dispenser"},
    {name = "item_tango_single"},
    {name = "item_ward_observer"},
    {name = "item_ward_sentry"},
    {name = "item_bottle"},
    {name = "item_moon_shard"},

        -- Courier stuff
    {name = "courier_return_to_base"},
    {name = "courier_go_to_secretshop"},
    {name = "courier_transfer_items"},
    {name = "courier_return_stash_items"},
    {name = "courier_take_stash_items"},
    {name = "courier_take_stash_and_transfer_items"},
    {name = "courier_shield"},
    {name = "courier_burst"},
    {name = "courier_morph"},
}

-- Function to work out if we can multicast with a given spell or not
function modifier_ogre_magi_multicast_ad_ranked:canMulticast(skillName)
    -- No banned multicast spells
    if noMulticast[skillName] then
        return false
    end

    -- Must be a valid spell
    return true
end

--------------------------------------------------------------------------------
function modifier_ogre_magi_multicast_ad_ranked:IsHidden()
	return true
end

function modifier_ogre_magi_multicast_ad_ranked:IsDebuff()
	return false
end

function modifier_ogre_magi_multicast_ad_ranked:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_ogre_magi_multicast_ad_ranked:OnCreated( kv )
	self.chance_2 = self:GetAbility():GetSpecialValueFor( "multicast_2_times" )
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "multicast_3_times" )
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "multicast_4_times" )

	self.buffRange = self:GetAbility():GetSpecialValueFor( "buff_range" )
	self.buffRange = self:GetAbility():GetSpecialValueFor( "multicast_delay" )
end

function modifier_ogre_magi_multicast_ad_ranked:OnRefresh( kv )
	self.chance_2 = self:GetAbility():GetSpecialValueFor( "multicast_2_times" )
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "multicast_3_times" )
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "multicast_4_times" )

	self.buffRange = self:GetAbility():GetSpecialValueFor( "buff_range" )
	self.delay = self:GetAbility():GetSpecialValueFor( "multicast_delay" ) + 0.08
end

--------------------------------------------------------------------------------
function modifier_ogre_magi_multicast_ad_ranked:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}

	return funcs
end

function modifier_ogre_magi_multicast_ad_ranked:OnAbilityFullyCast( params )
	if not IsServer() then
		return
	end

	if params.unit ~= self:GetParent() then return end
	if params.ability == self:GetAbility() then return end

	if self.excludedAbilities[params.ability:GetAbilityName()] then
		return
	end
	
	if not self:canMulticast(params.ability:GetAbilityName()) then
		return
	end

	if self:GetCaster():PassivesDisabled() then return end

	-- only spells that have target
	--if not params.target then return end

	-- if the spell can do both target and point, it should not trigger
	-- if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then return end
	-- if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET ) ~= 0 then return end

	-- roll multicasts
	local multiCasts = 0

	local dumbLuck = self:GetParent():FindAbilityByName("ogre_magi_dumb_luck")
	local chanceIncrease = 0

	local chance_2 = self.chance_2
	local chance_3 = self.chance_3
	local chance_4 = self.chance_4

	if dumbLuck and dumbLuck:GetLevel() > 0 and self:GetParent():IsRealHero() then
		local str = self:GetParent():GetStrength() or 0

		if str and str >= 20 then
			chanceIncrease = math.floor((str/20) * 100) / 100
		end

		if chanceIncrease > 0 then
			chance_2 = chance_2 + chanceIncrease
			chance_3 = chance_3 + chanceIncrease
			chance_4 = chance_4 + chanceIncrease
		end
	end

	if RollPseudoRandomPercentage(chance_4, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetParent()) then
		multiCasts = 3
	elseif RollPseudoRandomPercentage(chance_2, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetParent()) then
		multiCasts = 2
	elseif RollPseudoRandomPercentage(chance_3, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetParent()) then
		multiCasts = 1
	end

    if multiCasts == 0 then
        return
    end

	--currently all abilities can be singleTarget (not only ogre stun)
	-- local singleTarget = self.singleTarget[params.ability:GetAbilityName()] or false

	-- multicast
	if params.target then
	self:GetCaster():AddNewModifier(
		self:GetCaster(), -- player source
		self:GetAbility(), -- ability source
		"modifier_ogre_magi_multicast_proc_ad_ranked", -- modifier name
			{
				ability = params.ability:entindex(),
				target = params.target:entindex(),
				multi_casts = multiCasts,
				single_target = true,
				delay = self.delay,
				buff_range = self.buffRange,
			} -- kv
	)
	else
	self:GetCaster():AddNewModifier(
		self:GetCaster(), -- player source
		self:GetAbility(), -- ability source
		"modifier_ogre_magi_multicast_proc_ad_ranked", -- modifier name
			{
				ability = params.ability:entindex(),
				multi_casts = multiCasts,
				single_target = true,
				delay = self.delay,
				buff_range = self.buffRange,
			} -- kv
	)
	end
end