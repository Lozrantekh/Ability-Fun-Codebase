modifier_bane_nightmare_ad_ranked = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bane_nightmare_ad_ranked:IsHidden()
	return false
end

function modifier_bane_nightmare_ad_ranked:IsDebuff()
	return true
end

function modifier_bane_nightmare_ad_ranked:IsStunDebuff()
	return false
end

function modifier_bane_nightmare_ad_ranked:IsPurgable()
	return true
end

--using to stop creeps autoattack nightmared units (also used for Monkey King Mischief)
function modifier_bane_nightmare_ad_ranked:CanParentBeAutoAttacked()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_bane_nightmare_ad_ranked:OnCreated( kv )
	-- references
	local inv_time = self:GetAbility():GetSpecialValueFor( "nightmare_invuln_time" )
	self.anim_rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )

	if IsServer() then
		self.invulnerable = true
		self:StartIntervalThink( inv_time )

		-- play sound
		local sound_cast = "Hero_Bane.Nightmare"
		local sound_loop = "Hero_Bane.Nightmare.Loop"
		EmitSoundOn( sound_cast, self:GetParent() )
		EmitSoundOn( sound_loop, self:GetParent() )
	end
end

function modifier_bane_nightmare_ad_ranked:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_loop = "Hero_Bane.Nightmare.Loop"
	StopSoundOn( sound_loop, self:GetParent() )

	if not self.transfer then
		-- play end sound
		local sound_stop = "Hero_Bane.Nightmare.End"
		EmitSoundOn( sound_stop, self:GetParent() )
		
		-- end
		self:GetAbility():EndNightmare( false )
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_bane_nightmare_ad_ranked:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,

		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_bane_nightmare_ad_ranked:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_bane_nightmare_ad_ranked:GetOverrideAnimationRate()
	return self.anim_rate
end

function modifier_bane_nightmare_ad_ranked:OnAttackStart( params )
	if not IsServer() then return end
	if params.target~=self:GetParent() then return end

    if (params.attacker == self:GetCaster() or params.attacker:GetUnitName() == "npc_dota_hero_bane") and 
		params.attacker:GetTeamNumber() ~= params.target:GetTeamNumber() then
        return
    end

	self:TransferModifier(params.attacker)
end

function modifier_bane_nightmare_ad_ranked:TransferModifier(attacker)
	if not attacker or attacker:IsNull() or not attacker:IsAlive() then
		return
	end

	if not attacker:IsMagicImmune() then
		-- transfer
		local modifier = attacker:AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_bane_nightmare_ad_ranked", -- modifier name
			{ duration = self:GetDuration() } -- kv
		)

        if modifier then
			if self:GetAbility().modifiers then
				table.insert(self:GetAbility().modifiers, modifier)
			end
            self.transfer = true
        end
	end

	self:Destroy()
end

function modifier_bane_nightmare_ad_ranked:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end
	if params.damage_category==DOTA_DAMAGE_CATEGORY_SPELL then
		self:Destroy()
	end
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_bane_nightmare_ad_ranked:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = self.invulnerable,
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_bane_nightmare_ad_ranked:OnIntervalThink()
	self.invulnerable = false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_bane_nightmare_ad_ranked:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function modifier_bane_nightmare_ad_ranked:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end