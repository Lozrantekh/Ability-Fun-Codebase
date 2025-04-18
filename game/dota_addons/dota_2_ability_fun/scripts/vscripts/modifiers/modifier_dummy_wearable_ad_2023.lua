
modifier_dummy_wearable_ad_2023 = class({})

------------------------------------------------------------------------------

function modifier_dummy_wearable_ad_2023:IsPurgable()
	return false
end

function modifier_dummy_wearable_ad_2023:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

------------------------------------------------------------------------------

function modifier_dummy_wearable_ad_2023:OnCreated( kv )
    if IsServer() then
		self.invisImmune = false
		self.invis = false
		
		self.extraZOffset = 0
		self.extraXOffset = 0
		self.extraYAngleOffset = 0

		self.particles = {}

		self.ambientParticles = {}

		self.modelNamesPrefix = {
			lc_fallen_legion = "models/items/legion_commander/legacy_of_the_fallen_legion/legacy_of_the_fallen_legion.vmdl",
			zuus_thunderbolt = "models/items/zeus/lightning_weapon/zuus_lightning_weapon.vmdl",
			sven_ti7_sword = "models/items/sven/sven_ti7_immortal_sword/sven_ti7_immortal_sword.vmdl",
			sniper_scifi_gun = "models/items/sniper/scifi_sniper_test_gun/scifi_sniper_test_gun.vmdl",
			am_ti7_armor = "models/items/antimage/ti7_antimage_immortal/ti7_immortal_armor.vmdl",
			am_gold_basher = "models/items/antimage/skullbasher/skullbasher_gold.vmdl",
			am_gold_basher_offhand = "models/items/antimage/skullbasher/skullbasher_gold_offhand.vmdl",
			mirana_nukumo = "models/items/mirana/nukumo/nukumo.vmdl",
			muerta_space_gun = "models/items/muerta/muerta_space_gun/muerta_space_gun.vmdl",
			dazzle_darkclaw = "models/items/dazzle/darkclaw_acolyte_weapon/darkclaw_acolyte_weapon.vmdl",
			io_soccer_ball = "models/props_gameplay/soccer_ball.vmdl",
			green_axe_hair = "models/cosmetics/green_axe/green_axe_hair.vmdl",
			green_axe_pants = "models/cosmetics/green_axe/green_axe_pants.vmdl",
			dk_wings = "models/items/dragon_knight/dragon_immortal_1/dragon_immortal_fx.vmdl"
		}

		ListenToGameEvent( "dota_player_used_ability", Dynamic_Wrap( modifier_dummy_wearable_ad_2023, "OnAbilityForceExecuted" ), self )

		self:StartIntervalThink(0.25)
    end
end

function modifier_dummy_wearable_ad_2023:AttachWearableToHeroByMotions()
	if self.modelNamesPrefix["io_soccer_ball"] == self:GetParent():GetModelName() then
		DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", "0.08", 0, nil, nil )
	end

	if self.modelNamesPrefix["dk_wings"] == self:GetParent():GetModelName() then
		self:GetParent():AddEffects(EF_NODRAW)
		DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", "1.25", 0, nil, nil )
	end

	if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
		self:Destroy()
		return
	end
end

function modifier_dummy_wearable_ad_2023:UpdateHorizontalMotion( me, dt )
	if not IsServer() or not self:GetParent() then return end

	if self.hPlayerHero then
		local origin = self.hPlayerHero:GetAbsOrigin()
		origin.z = 0.0

		local attachment = self.hPlayerHero:ScriptLookupAttachment("attach_hitloc")

		if attachment then
			local attachmentOrigin = self.hPlayerHero:GetAttachmentOrigin(attachment)

			if attachmentOrigin then
				origin = attachmentOrigin
				origin.z = 0.0
			end
		end

		local angles = self.hPlayerHero:GetAngles()
		angles = QAngle(angles.x, angles.y + self.extraYAngleOffset, angles.z)
		me:SetLocalAngles(angles.x, angles.y, angles.z)
		me:SetOrigin(origin)

		local deltaPos = RotatePosition( Vector(0,0,0), angles, Vector(self.extraXOffset,0,0))
		origin = origin + deltaPos
		me:SetOrigin(origin)
	end
end

function modifier_dummy_wearable_ad_2023:UpdateVerticalMotion(me, dt)
	if not IsServer() or not self:GetParent() then return end

	if self.hPlayerHero then
		local vMyPos = me:GetOrigin()
		vMyPos.z = self.hPlayerHero:GetAbsOrigin().z

		local attachment = self.hPlayerHero:ScriptLookupAttachment("attach_hitloc")

		if attachment then
			local attachmentOrigin = self.hPlayerHero:GetAttachmentOrigin(attachment)
			if attachmentOrigin then
				vMyPos = attachmentOrigin
				vMyPos.z = vMyPos.z - 50 + self.extraZOffset
			end
		end

		me:SetOrigin(vMyPos)
	end
end


function modifier_dummy_wearable_ad_2023:OnAbilityForceExecuted(data)
	if not self or self:IsNull() then
		return
	end

	if not self:GetParent():IsAlive() then
		return
	end

	if not self.hPlayerHero then
		self.hPlayerHero = self:GetParent().hPlayer
	end

	if self:GetParent().isUnequipped then
		return
	end

	local playerID = data.PlayerID

	if self.hPlayerHero and playerID and self.hPlayerHero:GetPlayerOwnerID() == playerID then
		if self.modelNamesPrefix["lc_fallen_legion"] == self:GetParent():GetModelName() then
			local abilityName = data.abilityname

			if abilityName and abilityName == "legion_commander_press_the_attack" then
				self:AddLegionSelfPressTheAttackParticles()
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,

		[MODIFIER_STATE_FROZEN] = false,

		--stack count == 1 - invis
		--stack count == 2 - invis + truesight immune
		--problem with models that have status -> out of game + invis -> make models total invisible (without invis effect)
		[MODIFIER_STATE_INVISIBLE] = self:GetStackCount() > 0,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = self:GetStackCount() > 1,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_dummy_wearable_ad_2023:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_MODEL_CHANGED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_RESPAWN,
	}

	return funcs
end

function modifier_dummy_wearable_ad_2023:OnDeath(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end

		if self:GetParent().isMount then
			return
		end

		if self.hPlayerHero and self.hPlayerHero == params.unit then
			if self.modelNamesPrefix["io_soccer_ball"] == self:GetParent():GetModelName() then
				local animations = {
					"soccer_ball_deflect_01",
					"soccer_ball_deflect_02",
					"soccer_ball_deflect_03",
					"soccer_ball_deflect_04",
				}

				self:GetParent():SetSequence(animations[RandomInt(1, #animations)])
				self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:OnRespawn(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end

		if self:GetParent().isMount then
			return
		end

		if self.hPlayerHero and self.hPlayerHero == params.unit then
			if self.modelNamesPrefix["io_soccer_ball"] == self:GetParent():GetModelName() then
				self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_4_END)
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:OnModelChanged(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end

		if self:GetParent().isMount then
			return
		end

		if params.attacker and self.hPlayerHero and params.attacker == self.hPlayerHero and self.hPlayerHero.originalModel then
			local newModelName = params.attacker:GetModelName()
			local ignoreModelChanged = false

			if self.hPlayerHero:GetUnitName() == "npc_dota_hero_muerta" and newModelName == "models/heroes/muerta/muerta_ult.vmdl" then
				ignoreModelChanged = true
			end

			if newModelName == "models/items/axe/ti9_jungle_axe/axe_bare.vmdl" and 
				(self.modelNamesPrefix["green_axe_hair"] == self:GetParent():GetModelName() or self.modelNamesPrefix["green_axe_pants"] == self:GetParent():GetModelName())
			then
				ignoreModelChanged = true
			end

			if newModelName ~= self.hPlayerHero.originalModel and not ignoreModelChanged then
				self:SetWearableHidden(true)
			else
				self:SetWearableHidden(false)
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:GetModifierIncomingDamage_Percentage(params)
	return -100
end

function modifier_dummy_wearable_ad_2023:OnAttack(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped or self.hidden then
			return
		end

		if self.hPlayerHero and params.attacker == self.hPlayerHero then
			local currentAttackSeq = self.hPlayerHero:GetSequence()

			if self.modelNamesPrefix["sven_ti7_sword"] == self:GetParent():GetModelName() then

				if not self.hPlayerHero:PassivesDisabled() then
					local cleaveAbility = self.hPlayerHero:FindAbilityByName("sven_great_cleave")
					local bfuryItem = self.hPlayerHero:FindItemInInventory("item_bfury")

					if (cleaveAbility and cleaveAbility:GetLevel() > 0 ) or (bfuryItem and not bfuryItem:IsInBackpack()) then
						local particleCleaveName = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf"

						if self.svenTI7SwordUltimate then
							particleCleaveName = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"
						end
		
						ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle( particleCleaveName, PATTACH_ABSORIGIN, self.hPlayerHero ))

						self.hPlayerHero:EmitSound("Hero_Sven.GreatCleave.ti7")
					end
				end
				 
				local particleBlur = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_attack_blur.vpcf"

				if currentAttackSeq and currentAttackSeq == "attack02_anim" then
					particleBlur = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_attack_blur_2.vpcf"
				end

				ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle( particleBlur, PATTACH_ABSORIGIN, self.hPlayerHero ))
			end

			if self.modelNamesPrefix["sniper_scifi_gun"] == self:GetParent():GetModelName() then

				if self.hPlayerHero then
					local projectileSpeed = self.hPlayerHero:GetProjectileSpeed()

					-- launch projectile
					local info = {
						Target = params.target,
						Source = self.hPlayerHero,
						Ability = nil,
						
						EffectName = "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_base_attack.vpcf",
						iMoveSpeed = projectileSpeed,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
						bDodgeable = true,
						bIsAttack = false,
						bProvidesVision = false,
					}
				
					ProjectileManager:CreateTrackingProjectile(info)

					self.hPlayerHero:EmitSound("Hero_Sniper.Attack.DT20")
				end
			end

			if self.modelNamesPrefix["am_gold_basher"] == self:GetParent():GetModelName() then
				local unitPos = params.target:GetAbsOrigin()

				if unitPos then
					local particleName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_blade_hit_basher_ti_5_gold.vpcf"
					local particleFX = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )

					ParticleManager:ReleaseParticleIndex(particleFX)
				end
			end

			if self.modelNamesPrefix["muerta_space_gun"] == self:GetParent():GetModelName() then
				local particle_cast = "particles/items/muerta/muerta_space_gun_attack_projectile_tinker_laser.vpcf"

				if self:GetParent().newItemStyle and self:GetParent().newItemStyle == "blue" then
					particle_cast = "particles/items/muerta/muerta_space_gun_attack_projectile_v2_tinker_laser.vpcf"
				end

				self.hPlayerHero:EmitSound("Hero_Muerta.Attack.SpaceGun")

				-- Create Particle
				local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )

				local attach = "attach_attack1"

				local muertaAttack2Animation = {
					attack_alt = true,
					muerta_attack_alt_d = true,
					attack_alt_spin = true,
					attack_alt_fast = true,
					muerta_attack_alt_d_fast = true,
					attack_alt_faster = true,
					attack_alt_fastest = true,

					--ult model
					muerta_ult_attack2 = true,
				}
				
				local muertaDoubleShotAnimation = {
					double_shot_blend_faster = true,
					double_shot_blend_fastest = true,

					--ult model
					ult_double_shot_blend = true,
				}

				if currentAttackSeq and muertaAttack2Animation[currentAttackSeq] then
					attach = "attach_attack2"
				end

				if currentAttackSeq and muertaDoubleShotAnimation[currentAttackSeq] then
					if params.no_attack_cooldown then
						attach = "attach_attack2"
					else
						attach = "attach_attack1"
					end
				end

				ParticleManager:SetParticleControlEnt(
					effect_cast,
					9,
					self.hPlayerHero,
					PATTACH_POINT_FOLLOW,
					attach,
					Vector(0,0,0), -- unknown
					true -- unknown, true
				)

				ParticleManager:SetParticleControlEnt(
					effect_cast,
					1,
					params.target,
					PATTACH_POINT_FOLLOW,
					"attach_hitloc",
					Vector(0,0,0), -- unknown
					true -- unknown, true
				)

				ParticleManager:ReleaseParticleIndex( effect_cast )
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:OnTakeDamage(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end

		if self.hPlayerHero and params.attacker == self.hPlayerHero then

			if self.modelNamesPrefix["zuus_thunderbolt"] == self:GetParent():GetModelName() then
				if not params.inflictor or params.inflictor:GetAbilityName() ~= "zuus_lightning_bolt" then
					return
				end

				local unitPos = params.unit:GetAbsOrigin()

				if unitPos then
					local particleName = "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf"
					local thunderboltFx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, nil )
					ParticleManager:SetParticleControl( thunderboltFx, 1, unitPos )
					ParticleManager:ReleaseParticleIndex(thunderboltFx)

					if self.zuusThunderboltFx then
						ParticleManager:DestroyParticle(self.zuusThunderboltFx, true)
					end

					if not self.zuusThunderboltSoundLastEmit or GameRules:GetGameTime() >= self.zuusThunderboltSoundLastEmit + 0.5 then
						EmitSoundOnLocationWithCaster(unitPos, "Hero_Zuus.LightningBolt.Cast.Righteous", self.hPlayerHero)

						self.zuusThunderboltSoundLastEmit = GameRules:GetGameTime()
					end
				end
			end

			if self.modelNamesPrefix["am_gold_basher"] == self:GetParent():GetModelName() then
				if not self.manaBurnExist then
					local manaBurn = self.hPlayerHero:FindAbilityByName("antimage_mana_break")
					
					if manaBurn and manaBurn:GetLevel() > 0 then
						self.manaBurnExist = true
					end
				end

				if self.manaBurnExist then
					local unitPos = params.unit:GetAbsOrigin()

					if unitPos then
						local particleName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf"
						local particleFX = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, params.unit )

						ParticleManager:ReleaseParticleIndex(particleFX)

						if params.unit:HasModifier("modifier_bashed") then
							local bashModifier = params.unit:FindModifierByName("modifier_bashed")
							if bashModifier then
								local modifierDuration = bashModifier:GetDuration()
								local remainingTime = bashModifier:GetRemainingTime()
								local caster = bashModifier:GetCaster()

								if caster and caster == self.hPlayerHero and remainingTime >= modifierDuration - 0.1 then
									local particleBashName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_gold.vpcf"
									local particleBashFX = ParticleManager:CreateParticle( particleBashName, PATTACH_ABSORIGIN, params.unit )

									ParticleManager:SetParticleControlEnt(particleBashFX, 0, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetOrigin(), true );
									ParticleManager:SetParticleControlEnt(particleBashFX, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hPlayerHero:GetOrigin(), true );
									ParticleManager:SetParticleControlEnt(particleBashFX, 2, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetOrigin(), true );
									ParticleManager:SetParticleControlEnt(particleBashFX, 3, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetOrigin(), true );

									ParticleManager:ReleaseParticleIndex(particleBashFX );
								end
							end
						end
					end
				end
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:OnAbilityExecuted(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end

		local abilityName = params.ability:GetAbilityName()

		if self.hPlayerHero and self.hPlayerHero == params.unit then
			if self.modelNamesPrefix["lc_fallen_legion"] == self:GetParent():GetModelName() then
				if abilityName == "legion_commander_press_the_attack" then
					local targetParticleName = "particles/econ/items/legion/legion_fallen/legion_fallen_press.vpcf"

					local addSelfParticles = false
					local searchAOEvPos = nil

					if params.target then
						if params.target == self.hPlayerHero then
							addSelfParticles = true
						else
							local pressAttackOtherFx = ParticleManager:CreateParticle( targetParticleName, PATTACH_ABSORIGIN_FOLLOW, params.target )

							self.particles[pressAttackOtherFx] = {
								on_modifier_lost = "modifier_legion_commander_press_the_attack",
								other_target = params.target
							}
						end

						searchAOEvPos = params.target:GetAbsOrigin()
					end

					if self.hPlayerHero:HasLearnedTalent("special_bonus_unique_legion_commander_5") then
						if not searchAOEvPos then
							searchAOEvPos = params.ability:GetCursorPosition()
						end

						if searchAOEvPos then
							local friendlies = FindUnitsInRadius( 
								self.hPlayerHero:GetTeamNumber(), 
								searchAOEvPos, 
								nil,
								250,
								DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
								DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
								0, 
								0, 
								false 
							)
	
							for _, friend in pairs(friendlies) do
								if friend and friend:IsAlive() then
									if friend == self.hPlayerHero then
										addSelfParticles = true
									elseif not params.target or params.target ~= friend then
										local pressAttackOtherFx = ParticleManager:CreateParticle( targetParticleName, PATTACH_ABSORIGIN_FOLLOW, friend )
	
										self.particles[pressAttackOtherFx] = {
											on_modifier_lost = "modifier_legion_commander_press_the_attack",
											other_target = friend
										}
									end
								end
							end
						end
					end

					if addSelfParticles then
						self:AddLegionSelfPressTheAttackParticles()
					end
				end
			end

			if self.modelNamesPrefix["zuus_thunderbolt"] == self:GetParent():GetModelName() then
				if abilityName == "zuus_lightning_bolt" then
					local cursorPos = params.ability:GetCursorPosition()

					if cursorPos then
						local particleName = "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf"
						self.zuusThunderboltFx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, nil )
						ParticleManager:SetParticleControl( self.zuusThunderboltFx, 1, cursorPos )

						EmitSoundOnLocationWithCaster(cursorPos, "Hero_Zuus.LightningBolt.Cast.Righteous", self.hPlayerHero)
						self.zuusThunderboltSoundLastEmit = GameRules:GetGameTime()
					end

				end
			end

			if self.modelNamesPrefix["sven_ti7_sword"] == self:GetParent():GetModelName() then
				if abilityName == "sven_gods_strength" then
					local duration = params.ability:GetDuration()
					self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_sven_ti7_sword_status_effect_custom", {duration = duration })

					self.svenTI7SwordUltimate = true
					self:AddWearableEffects()
				end
			end

			if self.modelNamesPrefix["am_ti7_armor"] == self:GetParent():GetModelName() then
				if abilityName == "antimage_blink" then
					local position = params.unit:GetAbsOrigin()
					local particleName = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf"

					local particleFX = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, nil )
					ParticleManager:SetParticleControl( particleFX, 0, position )

					ParticleManager:ReleaseParticleIndex(particleFX)

					local particleNameEnd = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf"

					local particleEndFX = ParticleManager:CreateParticle( particleNameEnd, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )
					ParticleManager:ReleaseParticleIndex(particleEndFX)
				end
			end

			if self.modelNamesPrefix["am_gold_basher"] == self:GetParent():GetModelName() then
				if abilityName == "antimage_mana_void" and params.target then

					local particleName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_ti_5_gold.vpcf"
					local radius = params.ability:GetSpecialValueFor("mana_void_aoe_radius")

					local particleFX = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, nil )

					ParticleManager:SetParticleControlEnt(particleFX, 0, params.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
					ParticleManager:SetParticleControl(particleFX, 1, Vector(radius, 0, 0))

					ParticleManager:ReleaseParticleIndex(particleFX)
				end
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:AddLegionSelfPressTheAttackParticles()
	local pressTheAttackParticleName = "particles/econ/items/legion/legion_fallen/legion_fallen_press_owner.vpcf"

	if self:GetParent().newItemStyle and self:GetParent().newItemStyle == "1" then
		pressTheAttackParticleName = "particles/econ/items/legion/legion_fallen/legion_fallen_press_owner_alt.vpcf"
	end
	
	local pressTheAttackFX = ParticleManager:CreateParticle( pressTheAttackParticleName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	
	self.particles[pressTheAttackFX] = {
		on_modifier_lost = "modifier_legion_commander_press_the_attack"
	}

	self.hPlayerHero:StartGesture(ACT_SCRIPT_CUSTOM_0)

	--talent break the effect, need to apply gesture one more time with delay
	if self.hPlayerHero:HasLearnedTalent("special_bonus_unique_legion_commander_8") then
		local hero = self.hPlayerHero
		
		Timers:CreateTimer(0.2, function ()
			if hero and not hero:IsNull() and hero:IsAlive() and hero:HasModifier("modifier_legion_commander_press_the_attack") then
				hero:StartGesture(ACT_SCRIPT_CUSTOM_0)
			end
		end)
	end
end

function modifier_dummy_wearable_ad_2023:OnStateChanged(params)
	if IsServer() then
		if not self:GetParent():IsAlive() then
			return
		end

		if not self.hPlayerHero then
			self.hPlayerHero = self:GetParent().hPlayer
		end

		if self:GetParent().isUnequipped then
			return
		end
		
		if self.hPlayerHero and not self.hPlayerHero:IsNull() and self.hPlayerHero == params.unit then
			if self.hPlayerHero:_HasAppliedState_SB2023(MODIFIER_STATE_INVISIBLE) then
				self.invis = true

				if self.hPlayerHero:_HasAppliedState_SB2023(MODIFIER_STATE_TRUESIGHT_IMMUNE) then
					self.invisImmune = true
				else
					self.invisImmune = false
				end

				self:SetWearableInvisible(true, self.invisImmune, false)
			elseif self.invis then
				self.invis = false
				self:SetWearableInvisible(false, false, false)
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:SetWearableHidden(isHidden)
	if isHidden then
		if self.hidden then
			return
		end

		self.hidden = true
		self:GetParent():AddEffects(EF_NODRAW)
		self:RemoveParticles()
	else
		if not self.hidden then
			return
		end

		self.hidden = false
		self:GetParent():RemoveEffects(EF_NODRAW)

		Timers:CreateTimer(0.25, function ()
			self:AddWearableEffects()
		end)
	end
end

function modifier_dummy_wearable_ad_2023:SetWearableInvisible(invis, trueSightImmune, forceInvisEffect)
	if invis then
		local invisStatus = 1

		if trueSightImmune then
			invisStatus = 2
		end

		self:SetStackCount(invisStatus)

		if not self:GetParent():HasModifier("modifier_dummy_wearable_invis_states_ad_2023") then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_dummy_wearable_invis_states_ad_2023", {})
		end
	else
		self:SetStackCount(0)

		if not forceInvisEffect then
			self:GetParent():RemoveModifierByName("modifier_dummy_wearable_invis_states_ad_2023")
		end
	end
end

function modifier_dummy_wearable_ad_2023:OnIntervalThink()
	if not self:GetParent():IsAlive() then
		return
	end
	
	if not self.hPlayerHero then
		self.hPlayerHero = self:GetParent().hPlayer
	end

	if self:GetParent().isUnequipped then
		return
	end

	if self.hPlayerHero and not self.hPlayerHero:IsNull() and self.invis then
		if self.hPlayerHero:CanBeSeenByAnyOpposingTeam() then
			self:SetWearableInvisible(false, false, true)
		else
			self:SetWearableInvisible(self.invis, self.invisImmune, false)
		end
	end

	for particleID, data in pairs(self.particles) do
		if data["on_modifier_lost"] then
			local canDestryParticle = false

			if data["other_target"] then
				local target = data["other_target"]

				if not target or target:IsNull() or not target:HasModifier(data["on_modifier_lost"]) or not target:IsAlive() then
					canDestryParticle = true
				end
			elseif not self.hPlayerHero:HasModifier(data["on_modifier_lost"]) or not self.hPlayerHero:IsAlive() then
				canDestryParticle = true
			end

			if canDestryParticle then
				ParticleManager:DestroyParticle(particleID, false)
				self.particles[particleID] = nil
			end
		end
	end

	if self.svenTI7SwordUltimate and self.modelNamesPrefix["sven_ti7_sword"] == self:GetParent():GetModelName() then
		if not self.hPlayerHero:HasModifier("modifier_sven_gods_strength") then
			self.svenTI7SwordUltimate = false
			self:GetParent():RemoveModifierByName("modifier_sven_ti7_sword_status_effect_custom")
			self:AddWearableEffects()
		end
	end

	if self.modelNamesPrefix["io_soccer_ball"] == self:GetParent():GetModelName() then
		if self.hPlayerHero then
			if self.hPlayerHero:IsMoving() then
				local moveSpeed = self.hPlayerHero:GetIdealSpeed()
				local playbackRate = math.min(0.3 * moveSpeed/550, 0.3)

				DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", tostring(playbackRate), 0, nil, nil )
			else
				DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", "0.08", 0, nil, nil )
			end

			if self.hPlayerHero:HasModifier("modifier_mounted") then
				local mountModifier = self.hPlayerHero:FindModifierByName("modifier_mounted")
				if mountModifier and mountModifier.heroOffset then
					self.extraZOffset = mountModifier.heroOffset
				end
			else
				self.extraZOffset = 0
			end
		end
	end

	if self.modelNamesPrefix["dk_wings"] == self:GetParent():GetModelName() then
		self:GetParent():RemoveEffects(EF_NODRAW)

		if self.hPlayerHero then
			if self.hPlayerHero:IsMoving() then
				DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", "1.25", 0, nil, nil )
			else
				DoEntFireByInstanceHandle( self:GetParent(), "SetPlaybackRate", "0.65", 0, nil, nil )
			end
		end
	end
end

function modifier_dummy_wearable_ad_2023:AddWearableEffects()
	if not self.hPlayerHero then
		self.hPlayerHero = self:GetParent().hPlayer
	end

	if self.modelNamesPrefix["lc_fallen_legion"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["lc_fallen_legion"] then
			self.ambientParticles["lc_fallen_legion"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["lc_fallen_legion"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["lc_fallen_legion"] = {}

		local ambientParticle = "particles/econ/items/legion/legion_fallen/legion_fallen_ambient.vpcf"

		if self:GetParent().newItemStyle and self:GetParent().newItemStyle == "1" then
			ambientParticle = "particles/econ/items/legion/legion_fallen/legion_fallen_ambient_alt.vpcf"
		end

		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	
		table.insert(self.ambientParticles["lc_fallen_legion"], ambientFX)
	end

	if self.modelNamesPrefix["zuus_thunderbolt"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["zuus_thunderbolt"] then
			self.ambientParticles["zuus_thunderbolt"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["zuus_thunderbolt"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["zuus_thunderbolt"] = {}

		if self.hPlayerHero then
			local ambientParticle = "particles/econ/items/zeus/lightning_weapon_fx/zues_immortal_lightning_weapon.vpcf"
	
			local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt(ambientFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		
			table.insert(self.ambientParticles["zuus_thunderbolt"], ambientFX)
		end
	end

	if self.modelNamesPrefix["sven_ti7_sword"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["sven_ti7_sword"] then
			self.ambientParticles["sven_ti7_sword"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["sven_ti7_sword"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["sven_ti7_sword"] = {}

		local ambientParticle = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_ambient.vpcf"

		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

		local controlPoint1 = Vector(58, 118, 255)
		local controlPoint2 = Vector(0, 0, 0)

		if (self.hPlayerHero and self.hPlayerHero:HasModifier("modifier_sven_gods_strength")) or self.svenTI7SwordUltimate then
			controlPoint1 = Vector(255, 50, 10)
			controlPoint2 = Vector(1, 0, 0)

			self.svenTI7SwordUltimate = true
		end
		
		ParticleManager:SetParticleControl(ambientFX, 1, controlPoint1)
		ParticleManager:SetParticleControl(ambientFX, 2, controlPoint2)
	
		table.insert(self.ambientParticles["sven_ti7_sword"], ambientFX)

		if self.hPlayerHero and self.hPlayerHero:HasModifier("modifier_sven_gods_strength") then
			local modifier = self.hPlayerHero:FindModifierByName("modifier_sven_gods_strength")
			if modifier then
				local duration = modifier:GetRemainingTime()

				if duration > 0 then
					self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_sven_ti7_sword_status_effect_custom", {duration = duration })
					self.svenTI7SwordUltimate = true
				end
			end
		end
	end

	if self.modelNamesPrefix["sniper_scifi_gun"] == self:GetParent():GetModelName() then
		if self.hPlayerHero then
			self.hPlayerHero.sciFiWeapon = self:GetParent()
		end

		if not self.ambientParticles["sniper_scifi_gun"] then
			self.ambientParticles["sniper_scifi_gun"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["sniper_scifi_gun"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["sniper_scifi_gun"] = {}

		local ambientParticle = "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_weapon_ambient.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

		ParticleManager:SetParticleControlEnt(ambientFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_end_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_center_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_center_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_top_r_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_top_r_02_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 7, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_top_l_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 8, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_top_l_02_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 9, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_bot_l_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 10, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_bot_l_02_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 11, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_bot_r_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 12, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gun_barrel_bot_r_02_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 13, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_center_fx", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 14, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_base_fx", Vector(0,0,0), true)

		table.insert(self.ambientParticles["sniper_scifi_gun"], ambientFX)
	end

	if self.modelNamesPrefix["am_ti7_armor"] == self:GetParent():GetModelName() then
		self:GetParent():SetMaterialGroup("1")

		if not self.ambientParticles["am_ti7_armor"] then
			self.ambientParticles["am_ti7_armor"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["am_ti7_armor"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["am_ti7_armor"] = {}

		local ambientParticle = "particles/econ/items/antimage/antimage_ti7_golden/antimage_ti7_golden_ambient.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

		ParticleManager:SetParticleControlEnt(ambientFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_gem", Vector(0,0,0), true)

		table.insert(self.ambientParticles["am_ti7_armor"], ambientFX)
	end

	if self.modelNamesPrefix["am_gold_basher"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["am_gold_basher"] then
			self.ambientParticles["am_gold_basher"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["am_gold_basher"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["am_gold_basher"] = {}

		local ambientParticle = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_gold.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )

		ParticleManager:SetParticleControlEnt(ambientFX, 0, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack1", self.hPlayerHero:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack1", self.hPlayerHero:GetAbsOrigin(), true)

		table.insert(self.ambientParticles["am_gold_basher"], ambientFX)
	end

	if self.modelNamesPrefix["am_gold_basher_offhand"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["am_gold_basher_offhand"] then
			self.ambientParticles["am_gold_basher_offhand"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["am_gold_basher_offhand"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["am_gold_basher_offhand"] = {}

		local ambientParticle = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_offhand_gold.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )

		ParticleManager:SetParticleControlEnt(ambientFX, 0, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack2", self.hPlayerHero:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack2", self.hPlayerHero:GetAbsOrigin(), true)

		table.insert(self.ambientParticles["am_gold_basher_offhand"], ambientFX)
	end

	if self.modelNamesPrefix["mirana_nukumo"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["mirana_nukumo"] then
			self.ambientParticles["mirana_nukumo"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["mirana_nukumo"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["mirana_nukumo"] = {}

		local ambientParticle = "particles/econ/items/mirana/mirana_tsukumo/mirana_tsukumo_ambient_alt.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

		ParticleManager:SetParticleControlEnt(ambientFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_mane_front", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_ear_l", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_ear_r", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_mane_mid", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(ambientFX, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_tail", Vector(0,0,0), true)

		table.insert(self.ambientParticles["mirana_nukumo"], ambientFX)
	end

	if self.modelNamesPrefix["muerta_space_gun"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["muerta_space_gun"] then
			self.ambientParticles["muerta_space_gun"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["muerta_space_gun"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["muerta_space_gun"] = {}

		local ambientParticle = "particles/items/muerta/muerta_space_gun_mbient.vpcf"

		if self:GetParent().newItemStyle and self:GetParent().newItemStyle == "blue" then
			ambientParticle = "particles/items/muerta/muerta_space_gun_mbient_v2.vpcf"
		end

		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )
		ParticleManager:SetParticleControlEnt(ambientFX, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack1", self.hPlayerHero:GetAbsOrigin(), true)

		local ambientFX2 = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )
		ParticleManager:SetParticleControlEnt(ambientFX2, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_attack2", self.hPlayerHero:GetAbsOrigin(), true)

		table.insert(self.ambientParticles["muerta_space_gun"], ambientFX)
		table.insert(self.ambientParticles["muerta_space_gun"], ambientFX2)
	end

	if self.modelNamesPrefix["dazzle_darkclaw"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["dazzle_darkclaw"] then
			self.ambientParticles["dazzle_darkclaw"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["dazzle_darkclaw"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["dazzle_darkclaw"] = {}

		if self.hPlayerHero then
			local ambientParticle = "particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_ambient.vpcf"
	
			local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt(ambientFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetParent():GetAbsOrigin(), true)
		
			table.insert(self.ambientParticles["dazzle_darkclaw"], ambientFX)

			self.hPlayerHero.darkClawStaff = true
		end
	end

	if self.modelNamesPrefix["green_axe_hair"] == self:GetParent():GetModelName() then
		if not self.ambientParticles["green_axe_hair"] then
			self.ambientParticles["green_axe_hair"] = {}
		end

		for _, particleID in pairs(self.ambientParticles["green_axe_hair"]) do
			ParticleManager:DestroyParticle(particleID, true)
		end

		self.ambientParticles["green_axe_hair"] = {}

		local ambientParticle = "particles/cosmetic_inventory/axe/green_axe/green_axe_ambient_effect.vpcf"
		local ambientFX = ParticleManager:CreateParticle( ambientParticle, PATTACH_ABSORIGIN_FOLLOW, self.hPlayerHero )

		ParticleManager:SetParticleControlEnt(ambientFX, 1, self.hPlayerHero, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hPlayerHero:GetAbsOrigin(), true)

		table.insert(self.ambientParticles["green_axe_hair"], ambientFX)

		self.hPlayerHero.greenAxe = true
	end
end

function modifier_dummy_wearable_ad_2023:RemoveParticles()
	for particleID, _ in pairs(self.particles) do
		ParticleManager:DestroyParticle(particleID, true)
	end

	for _, data in pairs(self.ambientParticles) do
		for _, particleID in pairs(data) do
			ParticleManager:DestroyParticle(particleID, true)
		end
	end

	if self.hPlayerHero and self.modelNamesPrefix["dazzle_darkclaw"] == self:GetParent():GetModelName() then
		self.hPlayerHero.darkClawStaff = false
	end	

	if self.hPlayerHero and self.modelNamesPrefix["green_axe_hair"] == self:GetParent():GetModelName() then
		self.hPlayerHero.greenAxe = false
	end	
end

function modifier_dummy_wearable_ad_2023:VerifyHiddenStatus()
	if self.hidden and self.hPlayerHero then
		local canShowItem = true

		if self.hPlayerHero:IsHexed() then
			canShowItem = false
		end

		if self.hPlayerHero.originalModel and self.hPlayerHero.originalModel ~= self.hPlayerHero:GetModelName() then
			canShowItem = false
		end

		if canShowItem then
			self:SetWearableHidden(false)
		end
	end
end