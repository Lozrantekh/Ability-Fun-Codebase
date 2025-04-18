modifier_high_five_custom_search_sb_2023 = class({})

function modifier_high_five_custom_search_sb_2023:IsPurgable()
    return false
end

function modifier_high_five_custom_search_sb_2023:OnCreated(kv)
    if IsServer() then
        if not self:GetAbility() then
            return
        end

        self.ignoredUnits = {
            npc_dota_crate = true,
            npc_dota_vase = true,
            npc_dota_creature_sand_king_friendly = true,
            npc_dota_dummy_wearable = true,
            npc_treasure_chest = true
        }

        self.range = self:GetAbility():GetSpecialValueFor("acknowledge_range")
        self.duration = self:GetAbility():GetSpecialValueFor("request_duration")
        self.speed = self:GetAbility():GetSpecialValueFor("high_five_speed")

        self.overheadParticle = kv.overhead_particle or ""
        self.travelParticle = kv.travel_particle or ""
        self.failSound = kv.fail_sound or ""

        self.parent = self:GetParent()
        self.overheadFX = ParticleManager:CreateParticle(self.overheadParticle, PATTACH_OVERHEAD_FOLLOW, self.parent)

        self:StartIntervalThink(0.25)
    end
end

function modifier_high_five_custom_search_sb_2023:OnDestroy()
    if IsServer() then
        if self.overheadFX then
            ParticleManager:DestroyParticle(self.overheadFX, false)
        end

        if not self.partnerFound then
            self.parent:EmitSound(self.failSound)
        end
    end
end

function modifier_high_five_custom_search_sb_2023:OnIntervalThink()
    if self.partnerFound  then
        return
    end

    local units = FindUnitsInRadius( self.parent:GetTeamNumber(),
        self.parent:GetOrigin(),
        nil,
        self.range,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_CLOSEST,
        false 
    )

    for _, unit in pairs(units) do
        if unit and unit ~= self.parent and unit:HasModifier("modifier_high_five_custom_search_sb_2023") then
            local unitHighFiveModifier = unit:FindModifierByName('modifier_high_five_custom_search_sb_2023')

            if unitHighFiveModifier then
                self.partnerFound = true
                unitHighFiveModifier.partnerFound = true

                self:MakeHighFive(unit)

                self:GetAbility():EndCooldown()

                if unitHighFiveModifier:GetAbility() then
                    unitHighFiveModifier:GetAbility():EndCooldown()
                end

                self:Destroy()
                unitHighFiveModifier:Destroy()

                break
            end
        end
    end

    if self:GetRemainingTime() <= 1 then
        local extraUnits = FindUnitsInRadius( self.parent:GetTeamNumber(),
            self.parent:GetOrigin(),
            nil,
            self.range,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_CLOSEST,
            false 
        )

        for _, unit in pairs(extraUnits) do
            if self:IsValidSubHighFivePartner(unit) then
                self.partnerFound = true
                self:MakeHighFive(unit)
                self:GetAbility():EndCooldown()
                self:Destroy()

                break
            end
        end
    end
end

function modifier_high_five_custom_search_sb_2023:IsValidSubHighFivePartner(unit)
    if not unit or unit:IsNull() or unit == self.parent then
        return false
    end

    if self.parent:GetUnitName() == "npc_dota_hero_meepo" and unit:_IsMeepoClone() then
        return true
    end

    if unit:IsCreature() and not unit:IsControllableByAnyPlayer() and not self.ignoredUnits[unit:GetUnitName()] and 
        unit:GetModelName() ~= "" and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and
        (unit:IsConsideredHero() or unit:IsAncient() or unit:GetTeamNumber() == self.parent:GetTeamNumber()) 
    then
        return true
    end

    return false
end

function modifier_high_five_custom_search_sb_2023:MakeHighFive(unit)
    if not self:GetAbility() then
        return
    end

    if not unit or unit:IsNull() then
        return
    end

    local relivePosToUnit = unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
    local directionToUnit = relivePosToUnit:Normalized()
    directionToUnit.z = 0
    local directionToCaster = -directionToUnit
    local distanceToImpact = relivePosToUnit:Length2D() / 2

    local collisionPos = self:GetParent():GetAbsOrigin() + directionToUnit * distanceToImpact

    local projectileData  = {
		Ability = self:GetAbility(),
        bDeleteOnHit = false,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_NONE,

	    fDistance = distanceToImpact,
	    fStartRadius = 10,
	    fEndRadius = 10,
		vVelocity = directionToUnit * self.speed,

        ExtraData = {
            collisionX = collisionPos.x,
            collisionY = collisionPos.y,
            collisionZ = collisionPos.z,
        }
    }

    projectileData["Source"] = self.parent
    projectileData["vSpawnOrigin"] = self.parent:GetAbsOrigin()
    projectileData["EffectName"] = self.travelParticle
    projectileData["vVelocity"] = directionToUnit * self.speed

	ProjectileManager:CreateLinearProjectile(projectileData)

    projectileData["Source"] = unit
    projectileData["vSpawnOrigin"] = unit:GetAbsOrigin()
    projectileData["vVelocity"] = directionToCaster * self.speed

    --base particles
    local unitParticle = "particles/econ/misc/high_five/aghanim_puppet_2021/high_five_agh_2021_travel.vpcf"

    if unit:IsCreature() or (self.parent:GetUnitName() == "npc_dota_hero_meepo" and unit:_IsMeepoClone()) then
        unitParticle = self.travelParticle

        local cosmeticModifier = self.parent:FindModifierByName("modifier_cosmetic_inventory_sb2023")
        if cosmeticModifier then
            local highFiveData = cosmeticModifier:GetHighFiveCustomEffects()
            if highFiveData and highFiveData["overhead"] and highFiveData["overhead"]["sound"] then
                unit:EmitSound(highFiveData["overhead"]["sound"])
            end
        end
    else
        local cosmeticModifier = unit:FindModifierByName("modifier_cosmetic_inventory_sb2023")
        if cosmeticModifier then
            local highFiveData = cosmeticModifier:GetHighFiveCustomEffects()
            if highFiveData and highFiveData["travel"] and highFiveData["travel"]["particle"] then
                unitParticle =  highFiveData["travel"]["particle"]
            end
        end
    end

    projectileData["EffectName"] = unitParticle

	ProjectileManager:CreateLinearProjectile(projectileData)
end