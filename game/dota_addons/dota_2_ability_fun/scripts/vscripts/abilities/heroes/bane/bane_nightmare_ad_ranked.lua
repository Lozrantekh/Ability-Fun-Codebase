bane_nightmare_ad_ranked = class({})
LinkLuaModifier( "modifier_bane_nightmare_ad_ranked", "modifiers/heroes/bane/modifier_bane_nightmare_ad_ranked", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

--modifiers is table for case if someone has Multicast (Ogre ultimate) to remove modifiers from all affected units
bane_nightmare_ad_ranked.modifiers = {}

-- Ability Start
function bane_nightmare_ad_ranked:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- add modifier
	local modifier = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_bane_nightmare_ad_ranked", -- modifier name
		{ duration = duration } -- kv
	)

	if modifier then
		table.insert(self.modifiers, modifier)
	end

	-- check end ability
	local end_ability = caster:FindAbilityByName( "bane_nightmare_end_ad_ranked" )
	if not end_ability then
		-- stolen
		end_ability = caster:AddAbility( "bane_nightmare_end_ad_ranked" )
		self.add = end_ability
	end

	if end_ability then
		end_ability:SetLevel( 1 )
		end_ability.parent = self
	end

	-- set layout
	self:SetLayout( false )
end

function bane_nightmare_ad_ranked:EndNightmare( forced )
	-- remove modifier
	if forced then
		for _, modifier in ipairs(self.modifiers) do
			if modifier and not modifier:IsNull() then
				modifier:Destroy()
			end
		end
	end

	self.modifiers = {}

	-- reset layout
	self:SetLayout( true )

	-- remove ability if stolen
	if self.add then
		self:GetCaster():RemoveAbility( "bane_nightmare_end_ad_ranked" )
	end
end

bane_nightmare_ad_ranked.layout_main = true
function bane_nightmare_ad_ranked:SetLayout( main )
	-- if different ability is shown, swap
	if self.layout_main~=main then
		local ability_main = "bane_nightmare_ad_ranked"
		local ability_sub = "bane_nightmare_end_ad_ranked"

		-- swap
		self:GetCaster():SwapAbilities( ability_main, ability_sub, main, (not main) )
		self.layout_main = main
	end
end

--------------------------------------------------------------------------------
-- Hero Events
function bane_nightmare_ad_ranked:OnOwnerDied()
	self:EndNightmare( true )
end

--------------------------------------------------------------------------------
-- Helper Ability
bane_nightmare_end_ad_ranked = class({})

function bane_nightmare_end_ad_ranked:OnToggle()
	if self.parent and not self.parent:IsNull() then
		self.parent:EndNightmare( true )
	end
end