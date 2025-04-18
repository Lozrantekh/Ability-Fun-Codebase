if  summon_mount == nil then
	summon_mount = class({})
end

LinkLuaModifier( "modifier_summon_mount", "modifiers/mounts/modifier_summon_mount", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_invis_states_2", "modifiers/mounts/modifier_mount_invis_states_2", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function summon_mount:Precache( context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_earth/courier_trail_earth.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/trails/mount_snail_trail.vpcf", context )
	PrecacheResource( "particle", "articles/cosmetic_inventory/mounts/grillhound_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/grillhound_ambient_footprints.vpcf", context )
end

function summon_mount:GetIntrinsicModifierName()
	return "modifier_summon_mount"
end

function summon_mount:IsHiddenAbilityCastable()
	return true
end

--------------------------------------------------------------------------------

function summon_mount:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function summon_mount:IsRefreshable()
	return false
end

--------------------------------------------------------------------------------

function summon_mount:IsStealable()
	return false
end

function summon_mount:GetCastAnimation()
	if self.heroMounted or self:GetCaster():HasModifier("modifier_mounted") then
		return -1
	end

	return ACT_DOTA_GENERIC_CHANNEL_1
end

--------------------------------------------------------------------------------

function summon_mount:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not hCaster then
			return
		end

		--first always try to dismount hero!
		if self.heroMounted or self:GetCaster():HasModifier("modifier_mounted") then
			self.dismountChannelTime = 0
			self.heroMounted = false

			hCaster:RemoveModifierByName("modifier_mounted")
			self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

			return
		else
			self.dismountChannelTime = nil
		end

		if not self.mount then
			self:CreateMount()
		end

		self:GetCaster():EmitSound("Mount.Channeling.Start")
	end
end

function summon_mount:CreateMount()
	local hCaster = self:GetCaster()
	local initPos = hCaster:GetAbsOrigin() + RandomVector(100)
	
	local mount = CreateUnitByName( "npc_dota_base_mount", initPos, true, hCaster, hCaster, hCaster:GetTeamNumber() )
	
	if mount then
		self.mount = mount
		self.mount:AddEffects(EF_NODRAW)
		self.mount:SetOwner(self:GetCaster())
		
		local vPos = self:GetValidPositionForMount()
		if not vPos then
			vPos = self:GetCaster():GetAbsOrigin()
		end

		self.mount:SetAbsOrigin(vPos)
		self.mount:SetForwardVector(self:GetCaster():GetForwardVector())

		FindClearSpaceForUnit(self.mount, vPos, true)

		local passiveAbility = self.mount:FindAbilityByName("mount_moving_passive")
		if passiveAbility then
			passiveAbility:SetLevel(1)
		end
							
		self:GetCaster():_SetPlayerMount_SB2023(self.mount)

		local mountModifier = self.mount:FindModifierByName("modifier_mount_passive")
		if mountModifier then
			mountModifier:UpdateMountModel(self:GetCaster())
		end
	end
end

function summon_mount:OnChannelFinish(bInterrupted)
	if IsServer() then
		if self.dismountChannelTime then
			return
		end

		if bInterrupted then
			self.heroMounted = false

			self:GetCaster():RemoveModifierByName("modifier_mounted")

			if self.mount then
				self.mount:AddEffects(EF_NODRAW)
				self.mount.mountExpired = true

				--set mount movement if available
				local mountAbility = self.mount:FindAbilityByName("modifier_mount_passive")
				if mountAbility then
					local movementModifier = mountAbility:GetMovementModifierName()

					if movementModifier and not self.mount:HasModifier(movementModifier) then
						self.mount:AddNewModifier( self.mount, mountAbility, movementModifier, {} )
					end
				end
			end

			StopSoundOn("Mount.Channeling.Start", self:GetCaster())
		else
			self:EndCooldown()

			if not self.mount or self.mount:IsNull() then
				self:CreateMount()
			end

			if self.mount then
				self.mount:RemoveEffects(EF_NODRAW)

				local vPos = self:GetValidPositionForMount()
				if not vPos then
					vPos = self:GetCaster():GetAbsOrigin()
				end
				
				if not self.mount:IsAlive() then
					self:GetCaster():_RespawnPlayerMount_SB2023(vPos)
				end

				local zPos = GetGroundHeight(vPos, self.mount)
				vPos.z = zPos

				self.mount:SetAbsOrigin(vPos)
				self.mount:SetForwardVector(self:GetCaster():GetForwardVector())

				FindClearSpaceForUnit(self.mount, vPos, true)


				--uncomment for dynamic tests
				-- local passiveModifier = self.mount:FindModifierByName("modifier_mount_passive")

				-- if passiveModifier then
				-- 	passiveModifier:RemoveParticleEffects()
				-- 	passiveModifier:RemoveCosmeticItems()
				-- end
	
				-- self.mount:RemoveAbility("mount_moving_passive")
				-- local ability = self.mount:AddAbility("mount_moving_passive")
				-- ability:SetLevel(1)
				-- ability:RefreshIntrinsicModifier()
	
				--restart passive modifier
				local passiveModifier = self.mount:FindModifierByName("modifier_mount_passive")
				if passiveModifier and passiveModifier.RestartModifier then
					passiveModifier:RestartModifier()
					passiveModifier:MountHero(self:GetCaster())
					self.heroMounted = true
				end
	
				--restart mount movement modifier if exist
				local moveModifier = self.mount:FindModifierByName("modifier_mount_movement")
				if moveModifier and moveModifier.RestartModifier then
					moveModifier:RestartModifier()
				end

				self.mount:AddNewModifier(self.mount, nil, "modifier_phased", {duration = 3})

				--only for view purposes
				self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_phased", {duration = 3})
			end
		end
	end
end

function summon_mount:GetValidPositionForMount()
	local casterPos = self:GetCaster():GetAbsOrigin()	
	GridNav:DestroyTreesAroundPoint( casterPos, 200, false )

	return GetClearSpaceForUnit(self:GetCaster(), casterPos)
	
	-- local vDirection = self:GetCaster():GetForwardVector()
	-- local maxAttempts = 2
	-- local counter = 0

	-- while not GridNav:CanFindPath(casterPos, vPos) or not GridNav:IsTraversable(vPos) or GridNav:IsBlocked(vPos) do
	-- 	if counter > maxAttempts then
	-- 		break
	-- 	end

	-- 	vPos = casterPos + RandomVector(RandomInt(100, 200))
	-- 	counter = counter + 1
	-- end

	-- if GridNav:CanFindPath(casterPos, vPos) and GridNav:IsTraversable(vPos) then
	-- 	return vPos
	-- end
end

function summon_mount:GetChannelTime()
	if self.dismountChannelTime then
		return self.dismountChannelTime
	end

	return self.BaseClass.GetChannelTime(self)
end