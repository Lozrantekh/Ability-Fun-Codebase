modifier_bane_fiends_grip_lua = class({})

function modifier_bane_fiends_grip_lua:IsPurgable() return false end
function modifier_bane_fiends_grip_lua:IsPurgeException() return true end
function modifier_bane_fiends_grip_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_bane_fiends_grip_lua:GetEffectName() return "particles/units/heroes/hero_bane/bane_fiends_grip.vpcf" end
function modifier_bane_fiends_grip_lua:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_bane_fiends_grip_lua:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_bane_fiends_grip_lua:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]	= true,
		[MODIFIER_STATE_INVISIBLE]	= false
	}
end

function modifier_bane_fiends_grip_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end


function modifier_bane_fiends_grip_lua:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	self.fiend_grip_mana_drain		= self.ability:GetSpecialValueFor("fiend_grip_mana_drain") * (kv.multicast or 1)
	local fiend_grip_damage			= self.ability:GetSpecialValueFor("fiend_grip_damage") * (kv.multicast or 1)

	local fiend_grip_tick_interval	= self.ability:GetSpecialValueFor("fiend_grip_tick_interval")
	self.mana_drain_per_tick		= self.fiend_grip_mana_drain * fiend_grip_tick_interval 
	self.damage_per_tick			= fiend_grip_damage * fiend_grip_tick_interval 

	if IsClient() then return end

	self.damage_table = {
		victim      = self.parent,
		attacker    = self.caster,
		damage      = self.damage_per_tick,
		damage_type = self.ability:GetAbilityDamageType(),
		ability     = self.ability
	}

	-- Illusion modifiers waiting before original hero stop casting to do damage/mana drain
	if self.caster:IsIllusion() then
		self.disabled = true
	end

	self.caster:EmitSound("Hero_Bane.FiendsGrip.Cast")
	self.parent:EmitSound("Hero_Bane.Fiends_Grip")

	self:StartIntervalThink(fiend_grip_tick_interval)

	self.parent:RemoveModifierByName("modifier_bane_nightmare")
end

function modifier_bane_fiends_grip_lua:OnIntervalThink()
	if not IsValidEntity(self.ability) or not IsValidEntity(self.caster) then
		self:Destroy()
	end

	if self.disabled then return end

	ApplyDamage(self.damage_table)

	self.mana_drained = math.min(self.parent:GetMaxMana() * self.mana_drain_per_tick / 100, self.parent:GetMana())
	self.parent:Script_ReduceMana(self.mana_drained, self.ability)
	self.caster:GiveMana(self.mana_drained)
end

function modifier_bane_fiends_grip_lua:OnAbilityEndChannel(event)
	if event.ability == self.ability then self:Destroy() end
end

function modifier_bane_fiends_grip_lua:OnDestroy()
	if IsClient() then return end

	self.caster:StopSound("Hero_Bane.FiendsGrip.Cast")

	if IsValidEntity(self.ability) and self.ability:IsChanneling() and self.parent == self.ability:GetCursorTarget() then
		self.caster:InterruptChannel()
	end

	if IsValidEntity(self.parent) and not self.disabled then
		local modifiers = self.parent:FindAllModifiersByName("modifier_bane_fiends_grip_lua")

		for _, modifier in pairs(modifiers) do
			local modifier_caster = modifier:GetCaster()

			if modifier_caster and modifier_caster:IsIllusion() and modifier_caster:GetPlayerOwnerID() == self.caster:GetPlayerOwnerID() then
				modifier.disabled = nil
				break
			end
		end
	end
end

function modifier_bane_fiends_grip_lua:OnTooltip(event)
	return self.fiend_grip_mana_drain
end
