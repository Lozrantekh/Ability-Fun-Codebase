sniper_assassinate_ad_2023 = class({})

LinkLuaModifier( "modifier_sniper_assassinate_ad_2023", "modifiers/heroes/sniper/modifier_sniper_assassinate_ad_2023", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function sniper_assassinate_ad_2023:GetIntrinsicModifierName()
	return "modifier_sniper_assassinate_ad_2023"
end

function sniper_assassinate_ad_2023:GetCastPoint()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cast_point")
	end

	return self.BaseClass.GetCastPoint( self )
end

function sniper_assassinate_ad_2023:OnAbilityPhaseStart()
	if IsServer() then
		local aim_duration = self:GetSpecialValueFor( "aim_duration" )
		local hTarget = self:GetCursorTarget()
		if hTarget ~= nil then
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_sniper_assassinate", { duration = aim_duration } )
		end

		EmitSoundOn( "Ability.AssassinateLoad", self:GetCaster() )
	end

	return true
end

--------------------------------------------------------------------------------

function sniper_assassinate_ad_2023:OnAbilityPhaseInterrupted()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		if hTarget ~= nil then
			hTarget:RemoveModifierByName( "modifier_sniper_assassinate" )
		end
	end
end

--------------------------------------------------------------------------------

function sniper_assassinate_ad_2023:OnSpellStart(noStunReducedDamage)
	if IsServer() then
		self.bInBuckshot = false
		local hTarget = self:GetCursorTarget()

		local noStun = noStunReducedDamage or false
		local reducedDamage = noStunReducedDamage or false

		print("no stun", reducedDamage)

		if hTarget ~= nil then
			local info = 
			{
				EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf";
				Target = hTarget,
				Source = self:GetCaster(),
				Ability = self,
				iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),

				ExtraData = {
					noStun = noStun,
					reducedDamage = reducedDamage,
				}
			}

			ProjectileManager:CreateTrackingProjectile( info )
			EmitSoundOn( "Ability.Assassinate", self:GetCaster() )
			EmitSoundOn( "Hero_Sniper.AssassinateProjectile", self:GetCaster() )
		end
	end
end

--------------------------------------------------------------------------------

function sniper_assassinate_ad_2023:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if IsServer() then
		if hTarget ~= nil then
			hTarget:RemoveModifierByName( "modifier_sniper_assassinate" )

			-- cancel if linken
			if hTarget:TriggerSpellAbsorb( self ) then return end

			if not hTarget:IsInvulnerable() then
				local damageType = DAMAGE_TYPE_MAGICAL
				local bonusDamage = self:GetSpecialValueFor( "assassinate_damage")
				local attackDamage = self:GetCaster():GetAverageTrueAttackDamage(hTarget)

				local totalDamage = attackDamage + bonusDamage

				local canStun = true
				local reducedDamage = false

				if extraData.noStun and extraData.noStun == 1 then
					canStun = false
				end

				if extraData.reducedDamage and extraData.reducedDamage == 1 then
					reducedDamage = true
				end

				--main target damage
				if self.bInBuckshot == false then
					if self:GetCaster():HasScepter() then
						-- stun the main target
						if canStun then
							hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self:GetSpecialValueFor( "scepter_stun_duration" ) } )
						end
	
						-- damageType = DAMAGE_TYPE_PURE
					end

					
					if reducedDamage then
						totalDamage = totalDamage * 0.5
					end

					local damage = 
					{
						victim = hTarget,
						attacker = self:GetCaster(),
						ability = self,
						damage = totalDamage,
						damage_type = damageType,
					}

					print("damage: ", totalDamage)

					ApplyDamage( damage )
					EmitSoundOn( "Hero_Sniper.AssassinateDamage", hTarget )

					if self:GetCaster():HasModifier("modifier_sniper_assissinate_scatter_dmg_ad_2023") then
						self.bInBuckshot = true
						
						local vToTarget = hTarget:GetOrigin() - self:GetCaster():GetOrigin() 
						vToTarget = vToTarget:Normalized()
	
						local vSideTarget = Vector( vToTarget.y, -vToTarget.x, 0.0 )
						local scatter_range = self:GetSpecialValueFor( "scatter_range" )
						local scatter_width = self:GetSpecialValueFor( "scatter_width" )
	
						local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self:GetCaster(), scatter_range + scatter_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
						if #enemies > 0 then
							for _,enemy in pairs(enemies) do
								if enemy ~= nil and not enemy:IsInvulnerable() then
									local vToPotentialTarget = enemy:GetOrigin() - hTarget:GetOrigin()
									local flSideAmount = math.abs( vToPotentialTarget.x * vSideTarget.x + vToPotentialTarget.y * vSideTarget.y + vToPotentialTarget.z * vSideTarget.z )
									local flLengthAmount = ( vToPotentialTarget.x * vToTarget.x + vToPotentialTarget.y * vToTarget.y + vToPotentialTarget.z * vToTarget.z )
									if ( flSideAmount < scatter_width ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < scatter_range ) then
										local info = 
										{
											EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf";
											Target = enemy,
											Source = hTarget,
											Ability = self,
											iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ) / 2,

											ExtraData = {
												noStun = 1,
												reducedDamage = reducedDamage,
											}
										}
	
										ProjectileManager:CreateTrackingProjectile( info )
										EmitSoundOn( "Hero_Sniper.AssassinateProjectile_Scatter", enemy )
									end
								end
							end
						end
					end

				--scatter damage
				else
					local scatterDmgPct = self:GetSpecialValueFor("scatter_dmg_pct")
					totalDamage = totalDamage * scatterDmgPct/100

					if reducedDamage then
						totalDamage = totalDamage * 0.5
					end

					local damage = 
					{
						victim = hTarget,
						attacker = self:GetCaster(),
						ability = self,
						damage = totalDamage,
						damage_type = damageType,
					}

					ApplyDamage( damage )
					EmitSoundOn( "Hero_Sniper.AssassinateDamage_Scatter", hTarget )
				end
			end
		end
	end

	return true
end
