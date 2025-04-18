meepo_poof_ad_ranked = class({})

function meepo_poof_ad_ranked:OnAbilityPhaseStart()
	if IsServer() then
        self.startEffectData = self:PlayEffects(true)
	end
end

function meepo_poof_ad_ranked:OnAbilityPhaseInterrupted()
    if IsServer() then
        if self.startEffectData then
            if self.startEffectData.fx_index then
                ParticleManager:DestroyParticle(self.startEffectData.fx_index, true)
            end

            if self.startEffectData.sound then
                self:GetCaster():StopSound(self.startEffectData.sound)
            end
        end
    end
end

function meepo_poof_ad_ranked:OnSpellStart()
	if IsServer() then
        local radius = self:GetSpecialValueFor("radius") or 0
        local range = self:GetSpecialValueFor("AbilityCastRange")
        local damage = self:GetSpecialValueFor("poof_damage") or 0
        local target = self:GetCursorTarget()
        
        local initialOrigin = self:GetCaster():GetAbsOrigin()
        local destinationOrigin = self:GetCaster():GetAbsOrigin()

        if not target then
            local closestTarget = nil
            local parentDirection = self:GetCaster():GetForwardVector()

            -- Find closest friend in the range (hero need to face to friend)
            local friendlyHero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                                                    initialOrigin,
                                                    nil,
                                                    range,
                                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                                    DOTA_UNIT_TARGET_HERO,
                                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                                    FIND_CLOSEST,
                                                    false
            )

            for _, friend in ipairs(friendlyHero) do
                if friend ~= self:GetCaster() then
                    local direction = (friend:GetAbsOrigin() - initialOrigin):Normalized()

                    if parentDirection:Dot(direction) > 0.1 then
                        closestTarget = friend
                        break
                    end 
                end
            end

            if closestTarget then
                destinationOrigin = closestTarget:GetAbsOrigin()
            end
        end
        
        self:GetCaster():SetOrigin( destinationOrigin )
        FindClearSpaceForUnit(  self:GetCaster(), destinationOrigin, true )

         -- Find all nearby enemies in initial position
         local enemiesStart = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                                            initialOrigin,
                                            nil,
                                            radius,
                                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false
        )

        -- Find all nearby enemies in end position
        local enemiesEnd = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                                            destinationOrigin,
                                            nil,
                                            radius,
                                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false
        )

        local allEnemies = TableMerge(enemiesStart, enemiesEnd)

        local damageInfo = {
            -- victim = enemy,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self
        }

        for _,enemy in pairs(allEnemies) do
            if enemy ~= nil and enemy:IsAlive() and not enemy:_HasAppliedState_SB2023(MODIFIER_STATE_DEBUFF_IMMUNE) and not enemy:IsInvulnerable() then
                damageInfo.victim = enemy
                ApplyDamage( damageInfo )
            end
        end

        self:PlayEffects(false)
	end
end

function meepo_poof_ad_ranked:PlayEffects(isStart)
    -- Get Resources
	local particle_cast_start = "particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
	local particle_cast_end = "particles/units/heroes/hero_meepo/meepo_poof_end.vpcf"

    local soundStart = "Hero_Meepo.Poof.Channel"
    local soundEnd = "Hero_Meepo.Poof.End00"

    local particle = particle_cast_start
    local sound = soundStart

    if not isStart then
        particle = particle_cast_end
        sound = soundEnd
    end

	local fxIndex = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

    if isStart then
        ParticleManager:SetParticleControl( fxIndex, 1, self:GetCaster():GetAbsOrigin() )
    end

    self:GetCaster():EmitSound(sound)

    return {fx_index = fxIndex, sound = sound}
end