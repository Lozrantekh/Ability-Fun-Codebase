shadow_fiend_shadowraze_ad_2023 = class({})

LinkLuaModifier("modifier_shadow_fiend_shadowraze_ad_2023", "modifiers/heroes/nevermore/modifier_shadow_fiend_shadowraze_ad_2023", LUA_MODIFIER_MOTION_NONE)

function shadow_fiend_shadowraze_ad_2023:GetCastAnimation()
    if IsServer() then
        if self:GetCaster():GetUnitName() == "npc_dota_hero_nevermore" then
            return ACT_DOTA_RAZE_2
        end
    
        return ACT_DOTA_CAST_ABILITY_1
    end
end

function shadow_fiend_shadowraze_ad_2023:OnSpellStart()
    if IsServer() then
        local distance = self:GetSpecialValueFor("shadowraze_range")
        local target_radius = self:GetSpecialValueFor("shadowraze_radius")
        local base_damage = self:GetSpecialValueFor("shadowraze_damage")
        local stack_damage = self:GetSpecialValueFor("stack_bonus_damage")
        local stack_duration = self:GetSpecialValueFor("duration")
        
        local front = self:GetCaster():GetForwardVector():Normalized()
        local target_pos = self:GetCaster():GetOrigin() + front * distance

        -- get affected enemies
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            target_pos,
            nil,
            target_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        -- for each affected enemies
        for _,enemy in pairs(enemies) do
            if enemy and not enemy:IsInvulnerable() then
                -- Get Stack
                local stack = 0

                local modifier = enemy:FindModifierByNameAndCaster("modifier_shadow_fiend_shadowraze_ad_2023", self:GetCaster())
                if modifier then
                    stack = modifier:GetStackCount()
                end
    
                -- Apply damage
                local damageTable = {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    damage = base_damage + stack*stack_damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                }
                ApplyDamage( damageTable )
    
                -- Add stack
                if not modifier then
                    enemy:AddNewModifier(
                        self:GetCaster(),
                        self,
                        "modifier_shadow_fiend_shadowraze_ad_2023",
                        {duration = stack_duration}
                    )
                else
                    modifier:IncrementStackCount()
                    modifier:ForceRefresh()
                end 

                --apply attack with talent
                local procAttack = self:GetSpecialValueFor("procs_attack")
                if procAttack and procAttack == 1 then
                    self:GetCaster():PerformAttack(enemy, true, true, true, false, false, false, false)
                end
            end
        end

        -- Effects
        self:PlayEffects(target_pos, target_radius )
    end
end

function shadow_fiend_shadowraze_ad_2023:PlayEffects( position, radius )
	-- get resources
	local particle_cast = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	local sound_cast = "Hero_Nevermore.Shadowraze"

	-- create particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, 1 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	
	-- create sound
	EmitSoundOnLocationWithCaster( position, sound_cast, self:GetCaster() )
end