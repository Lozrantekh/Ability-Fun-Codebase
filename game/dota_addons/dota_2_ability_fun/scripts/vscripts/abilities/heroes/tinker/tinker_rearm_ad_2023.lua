tinker_rearm_ad_2023 = class({})

--------------------------------------------------------------------------------
tinker_rearm_ad_2023.itemException = {
	item_aeon_disk = true,
	item_arcane_boots = true,
	item_black_king_bar = true,
	item_hand_of_midas = true,
	item_helm_of_the_dominator = true,
	item_meteor_hammer = true,
	item_necronomicon = true,
	item_necronomicon_2 = true,
	item_necronomicon_3 = true,
	item_refresher = true,
	item_refresher_shard = true,
	item_pipe = true,
	item_sphere = true,
	item_tpscroll = true,
	item_tpscroll = true,
        item_clarity = true,
        item_faerie_fire = true,           
        item_smoke_of_deceit = true,
        item_ward_observer = true,
        item_ward_sentry = true,
        item_enchanted_mango = true,
        item_flask = true,
        item_tango = true,
       	item_blood_grenade = true,
        item_dust = true,
        item_bottle = true,
	item_quelling_blade = true,
	item_infused_raindrop = true,
	item_magic_stick = true,
	item_blink = true,
	item_magic_wand = true,
	item_soul_ring = true,
	item_phase_boots = true,
	item_mask_of_madness = true,
	item_travel_boots = true,
	item_urn_of_shadows = true,
	item_tranquil_boots = true,
	item_mekansm = true,
	item_holy_locket = true,
	item_spirit_vessel = true,
	item_guardian_greaves = true,
	item_devastator = true,
	item_veil_of_discord = true,
	item_glimmer_cape = true,
	item_force_staff = true,
	item_witch_blade = true,
	item_cyclone = true,
	item_rod_of_atos = true,
	item_dagon = true,
	item_orchid = true,
	item_solar_crest = true,
	item_sheepstick = true,
	item_gungir = true,
	item_wind_waker = true,
	item_blade_mail = true,
	item_soul_booster = true,
	item_crimson_guard = true,
	item_hurricane_pike = true,
	item_manta = true,
	item_sphere = true,
	item_shivas_guard = true,
	item_bloodstone = true,
	item_helm_of_the_overlord = true,
	item_meteor_hammer = true,
	item_invis_sword = true,
	item_bfury = true,
	item_ethereal_blade = true,
	item_nullifier = true,
	item_silver_edge = true,
	item_bloodthorn = true,
	item_abyssal_blade = true,
	item_aetherial_halo = true,
	item_echo_sabre = true,
	item_diffusal_blade = true,
	item_phylactery = true,
	item_heavens_halberd = true,
	item_satanic = true,
	item_mjollnir = true,
	item_overwhelming_blink = true,
	item_swift_blink = true,
	item_arcane_blink = true,
	item_harpoon = true,
}

tinker_rearm_ad_2023.abilityException = {
    zuus_thundergods_wrath = true,
    invoker_sun_strike_ad = true,
    furion_wrath_of_nature = true,
    spectre_haunt = true,
}

function tinker_rearm_ad_2023:Precache()
    if IsServer() then
        PrecacheUnitByNameAsync("precache_npc_dota_hero_tinker", function() end)
    end
end

function tinker_rearm_ad_2023:OnSpellStart()
	if IsServer() then
        local sound_cast = "Hero_Tinker.Rearm"
        EmitSoundOn( sound_cast, self:GetCaster() )
    end

end

--------------------------------------------------------------------------------
function tinker_rearm_ad_2023:OnChannelFinish( bInterrupted )
    if IsServer() then
        local caster = self:GetCaster()

        -- stop effects
        local sound_cast = "Hero_Tinker.Rearm"
        StopSoundOn( sound_cast, self:GetCaster() )
    
        if bInterrupted then return end
    
        -- find all refreshable abilities
        for i=0,caster:GetAbilityCount()-1 do
            local ability = caster:GetAbilityByIndex( i )
            if ability and ability:GetAbilityType() ~= DOTA_ABILITY_TYPE_ATTRIBUTES and not ability:IsAttributeBonus() and not self:IsAbilityException(ability) then
                if ability:IsRefreshable() then
                    ability:EndCooldown()
                end

                local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel())

                if maxCharges > 0 then
                    local currentCharges = ability:GetCurrentAbilityCharges()
                    if currentCharges < maxCharges then
                        local needRefresh = (currentCharges + 1 == maxCharges)

                        if needRefresh then
                            ability:RefreshCharges()
                        else
                            ability:SetCurrentAbilityCharges(currentCharges + 1)
                        end
                    end
                end
            end
        end
    
        -- find all refreshable items
        for i = 0, 8 do
            local item = caster:GetItemInSlot(i)

            if item then
                if item:GetPurchaser() == caster and not self:IsItemException( item ) and not item:IsNeutralDrop() and item:IsRefreshable() then
                    item:EndCooldown()
                end
            end
        end
    
        -- effects
        self:PlayEffects()
    end
end

--------------------------------------------------------------------------------
function tinker_rearm_ad_2023:IsItemException( item )
	return self.itemException[item:GetAbilityName()]
end

function tinker_rearm_ad_2023:IsAbilityException( ability )
	return self.abilityException[ability:GetAbilityName()]
end

--------------------------------------------------------------------------------
-- Effects
function tinker_rearm_ad_2023:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
	local sound_cast = "Hero_Tinker.RearmStart"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetCaster() )
end