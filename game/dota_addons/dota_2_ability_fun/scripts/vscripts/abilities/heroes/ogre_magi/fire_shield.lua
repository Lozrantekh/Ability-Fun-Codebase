ogre_magi_fire_shield_lua = class({})
LinkLuaModifier("modifier_ogre_magi_fire_shield_lua_buff", "abilities/heroes/ogre_magi/fire_shield.lua", LUA_MODIFIER_MOTION_NONE)

function ogre_magi_fire_shield_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not caster or caster:IsNull() then return end
	if not target or target:IsNull() then return end

	local damage = self:GetSpecialValueFor("damage") or 0
	local duration = self:GetSpecialValueFor("duration") or 0

	self.damage_table = {
		-- victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = self,
	}

	target:AddNewModifier(caster, self, "modifier_ogre_magi_fire_shield_lua_buff", {duration = duration})
end

function ogre_magi_fire_shield_lua:OnProjectileHit(target, vLocation)
	if not self or self:IsNull() then return end
	if not target or target:IsNull() or not target:IsAlive() or target:IsInvulnerable() then return end

	self.damage_table.victim = target
	ApplyDamage(self.damage_table)
	target:EmitSound("Hero_OgreMagi.FireShield.Damage")
end


-------------------------------------------------------------------------------------------------------------------------------------------------


modifier_ogre_magi_fire_shield_lua_buff = class({})

function modifier_ogre_magi_fire_shield_lua_buff:IsHidden() return false end
function modifier_ogre_magi_fire_shield_lua_buff:IsDebuff() return false end
function modifier_ogre_magi_fire_shield_lua_buff:IsPurgable() return true end

function modifier_ogre_magi_fire_shield_lua_buff:OnCreated(keys)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if not self.caster or self.caster:IsNull() then return end
	if not self.parent or self.parent:IsNull() then return end
	if not self.ability or self.ability:IsNull() then return end

	local attacks = self.ability:GetSpecialValueFor("attacks") or 0
	self.damage_absorb_pct = self.ability:GetSpecialValueFor("damage_absorb_pct") or 0
	local projectile_speed = self.ability:GetSpecialValueFor("projectile_speed") or 0

	if not IsServer() then return end

	self:SetStackCount(attacks)
	
	if self.is_refresh then
		if self.particle then
			ParticleManager:SetParticleControl(self.particle, 9, Vector(1,0,0))
			ParticleManager:SetParticleControl(self.particle, 10, Vector(1,0,0))
			ParticleManager:SetParticleControl(self.particle, 11, Vector(1,0,0))
		end
	else
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_CENTER_FOLLOW , self.parent)
		self:AddParticle(self.particle, false, false, -1, false, false)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_CENTER_FOLLOW , nil, self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(3,0,0))
		ParticleManager:SetParticleControl(self.particle, 9, Vector(1,0,0))
		ParticleManager:SetParticleControl(self.particle, 10, Vector(1,0,0))
		ParticleManager:SetParticleControl(self.particle, 11, Vector(1,0,0))
	
		self.projectile_info = {
			--Target = target,
			Source = self.parent,
			Ability = self.ability,
			EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_projectile.vpcf",
			iMoveSpeed = projectile_speed,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = 50,
			iVisionTeamNumber = self.caster:GetTeamNumber(),
			bDodgeable = true,
		}
	end
end

function modifier_ogre_magi_fire_shield_lua_buff:OnRefresh(keys)
	if not IsServer() then return end
	self.is_refresh = true
	self:OnCreated(keys)
end

function modifier_ogre_magi_fire_shield_lua_buff:OnStackCountChanged()
	if not IsServer() then return end

	if self:GetStackCount() <= 2 then
		ParticleManager:SetParticleControl(self.particle, 9, Vector(0,0,0))
	end

	if self:GetStackCount() <= 1 then
		ParticleManager:SetParticleControl(self.particle, 10, Vector(0,0,0))
	end

	if self:GetStackCount() > 0 then return end
	self:Destroy()
end

function modifier_ogre_magi_fire_shield_lua_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ogre_magi_fire_shield_lua_buff:GetModifierIncomingDamage_Percentage(event)
	if event.target ~= self.parent then return 0 end
	if IsBitSet(event.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then return 0 end
	if event.damage_category and event.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then return 0 end
	if event.damage <= 0 then return 0 end
	if event.attacker:IsIllusion() then return 0 end
	
	self.projectile_info.Target = event.attacker
	ProjectileManager:CreateTrackingProjectile(self.projectile_info)
	self:DecrementStackCount()

	return -self.damage_absorb_pct
end
