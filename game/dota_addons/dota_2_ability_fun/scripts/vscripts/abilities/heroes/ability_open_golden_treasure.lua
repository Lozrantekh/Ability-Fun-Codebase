ability_open_golden_treasure = class({})

LinkLuaModifier( "modifier_ability_open_golden_treasure", "modifiers/heroes/modifier_ability_open_golden_treasure", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ability_open_golden_treasure:Precache( context )
	PrecacheResource( "particle", "particles/golden_treasure/golden_treasure_opening_give.vpcf", context )

    PrecacheUnitByNameAsync( "precache_npc_dota_hero_pugna", function () end)
end

function ability_open_golden_treasure:IsHiddenAbilityCastable()
    return true
end

function ability_open_golden_treasure:GetIntrinsicModifierName()
	return "modifier_ability_open_golden_treasure"
end

function ability_open_golden_treasure:CastFilterResultTarget(hTarget)
	if hTarget and hTarget:GetUnitName() == "npc_treasure_chest"  then
        return UF_SUCCESS
	end
    
    return UF_FAIL_OTHER
end

-- Ability Start
function ability_open_golden_treasure:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        if not self.target or self.target:IsNull() or self.target.treasureOpened then
            return
        end

        self.creepTreasureChannelTime = 0
        
        if self.target.droppedByTower then
            --base channel time is mutliplied by 100 to set modifier counter (need to be integer)
            self.creepTreasureChannelTime = 0.5 * 100
	else 
		self.creepTreasureChannelTime = 0.1 * 50
        end

        self.accumulatedTime = 0
        self.channelBooster = 0
        self:ResetChannelTime()

        -- Play effects
        local sound_cast = "Hero_Pugna.LifeDrain.Cast"
        EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster)

        self.particle_drain_fx = ParticleManager:CreateParticle("particles/golden_treasure/golden_treasure_opening_give.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    end
end

function ability_open_golden_treasure:ResetChannelTime()
    local modifier = self:GetCaster():FindModifierByName("modifier_ability_open_golden_treasure")
        
    if modifier then
        local channelTimeChange = 0

        if self.creepTreasureChannelTime and self.creepTreasureChannelTime > 0 then
            channelTimeChange = self.creepTreasureChannelTime
        end

        modifier:SetStackCount(channelTimeChange)
    end
end

--------------------------------------------------------------------------------
function ability_open_golden_treasure:OnChannelFinish( bInterrupted )
    if self.particle_drain_fx then
        ParticleManager:DestroyParticle(self.particle_drain_fx, false)
        ParticleManager:ReleaseParticleIndex(self.particle_drain_fx)

        self.particle_drain_fx = nil
    end

    self.channelBooster = 0
    self:ResetChannelTime()

    if not bInterrupted and self.target and not self.target:IsNull() then
        local treasureModifier = self.target:FindModifierByName("modifier_golden_treasure_chest_ad_2023")
        if treasureModifier then
            treasureModifier:RandomTreasureReward(self:GetCaster())
        end
    end
end

function ability_open_golden_treasure:OnChannelThink( interval )
    if IsServer() then
        local currentChannelTime = self:GetChannelTime()

        if GameRules:GetGameTime() - self:GetChannelStartTime() >= currentChannelTime then
            self:EndChannel(false)

            return
        end

        if self.channelBooster then
            self.accumulatedTime = self.accumulatedTime + interval

            if self.accumulatedTime >= 0.1 then
                self:UpdateCurrentChannelTime(self.channelBooster)
                self.accumulatedTime = 0
            end 
        end
    end
end

function ability_open_golden_treasure:UpdateCurrentChannelTime(value)
    local currentChannelTime = self:GetChannelTime()
    currentChannelTime = math.max(currentChannelTime + value, 0.1)

    local modifier = self:GetCaster():FindModifierByName("modifier_ability_open_golden_treasure")
    
    if modifier then
        modifier:SetStackCount(math.floor(currentChannelTime * 100))
    end
end

function ability_open_golden_treasure:UpdateChannelRateValue(value)
    if value then
        self.channelBooster = value
    end
end

function ability_open_golden_treasure:UpdateInitialChannelTime(value)
    local modifier = self:GetCaster():FindModifierByName("modifier_ability_open_golden_treasure")
    
    if modifier then
        local startChannelTime = math.max(value, 0.1)
        modifier:SetStackCount(math.floor(startChannelTime * 100))
    end
end