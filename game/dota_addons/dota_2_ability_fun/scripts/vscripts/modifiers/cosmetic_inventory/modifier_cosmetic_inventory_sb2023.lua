modifier_cosmetic_inventory_sb2023 = class({})

function modifier_cosmetic_inventory_sb2023:IsHidden()
	return true
end

function modifier_cosmetic_inventory_sb2023:IsPurgeException()
	return false
end

function modifier_cosmetic_inventory_sb2023:IsPurgable()
	return false
end

function modifier_cosmetic_inventory_sb2023:IsPermanent()
	return true
end

function modifier_cosmetic_inventory_sb2023:OnCreated(kv)
    if IsServer() then
        self.supporterLevel = 0
        local playerID = self:GetParent():GetPlayerOwnerID()
        
        if GameRules.AbilityDraftRanked._vPlayerStats[playerID] and GameRules.AbilityDraftRanked._vPlayerStats[playerID]["supporter_level"] then
            self.supporterLevel = GameRules.AbilityDraftRanked._vPlayerStats[playerID]["supporter_level"]
        end

        self.twoAttacksWariantsHero = {
			npc_dota_hero_lina = true,
			npc_dota_hero_lich = true,
			npc_dota_hero_invoker = true,
			npc_dota_hero_ancient_apparition = true,
			npc_dota_hero_nevermore = true,
			npc_dota_hero_death_prophet = true,
			npc_dota_hero_shadow_demon = true,
			npc_dota_hero_shadow_shaman = true,
			npc_dota_hero_storm_spirit = true,
			npc_dota_hero_zuus = true,
			npc_dota_hero_queenofpain = true,
			npc_dota_hero_enigma = true,
			npc_dota_hero_lone_druid = true,
			npc_dota_hero_troll_warlord = true,
            npc_dota_hero_arc_warden = true,
            npc_dota_hero_bane = true,
		}

        self.attacksOutsideHero = {
            npc_dota_hero_hoodwink = true,
            npc_dota_hero_luna = true,
            npc_dota_hero_sniper = true,
            npc_dota_hero_phantom_assassin = true,
        }

        self.abilitiesUsingHeroAttack = {
            phantom_assassin_phantom_strike = true,
            hoodwink_acorn_shot = true,
            luna_moon_glaive = true,
            sniper_assassinate_ad_2023 = true,
            sniper_assassinate_sb_2023 = true,
            sniper_assassinate_dm2017 = true
        }

        self.abilityAllowedAttackEffects = {
            aghsfort_phantom_assassin_stifling_dagger = true,
        }
        
        self.supporterLastHitParticleEffects = {
            ls_effect_1 = true,
            ls_effect_2 = true,
        }

        self.noSoundEffect = {
            npc_dota_crate = true,
            npc_dota_vase = true,
        }

        --last hits
        self.lastHitParticleEffects = nil
        self.lastHitSoundEffects = nil

        --attack modifiers
        self.attackModifierEffect = nil

        --mounts
        self.baseMountModel = "models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl"
        self.mountModel = nil
        self.mountParticleStrength = 0
    end
end

function modifier_cosmetic_inventory_sb2023:OnRefresh(kv)
    if IsServer() then
        self:OnCreated(kv)
    end
end

function modifier_cosmetic_inventory_sb2023:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_cosmetic_inventory_sb2023:OnDeath(params)
	if IsServer() then

        --Last hit effects
		if self:GetParent() == params.attacker then

            if self.lastHitParticleEffects and self.lastHitParticleItemID  and self.supporterLastHitParticleEffects[self.lastHitParticleItemID] then
                self:AddSupporterLastHitParticleEffects(params.unit, self.lastHitParticleEffects)
            end

            if self.lastHitSoundEffects and not self.noSoundEffect[params.unit:GetUnitName()] then
                EmitSoundOn(self.lastHitSoundEffects, params.unit)
            end
		end
	end
end

function modifier_cosmetic_inventory_sb2023:HasCustomLastHitParticleEffect()
    if self.lastHitParticleEffects then
        return true
    end

    return false
end

function modifier_cosmetic_inventory_sb2023:HasCustomLastHitSoundEffect()
    if self.lastHitSoundEffects then
        return true
    end

    return false
end

function modifier_cosmetic_inventory_sb2023:HasCustomAttackModifierEffect()
    if self.attackModifierEffect then
        return true
    end

    return false
end

function modifier_cosmetic_inventory_sb2023:SetLastHitParticleEffects(itemID, isUnEquip)
    local itemData = GameRules.AbilityDraftRanked.cosmeticInventory:GetItemData(itemID, "last_hit_effects")

    if itemData and itemData["particles"] and itemData["particles"]["name"] then
        if isUnEquip then
            self.lastHitParticleEffects = nil
            self.lastHitParticleItemID = nil
        else
            self.lastHitParticleEffects = itemData["particles"]["name"]
            self.lastHitParticleItemID = itemID
        end
    end

    if itemData and itemData["sound"] and itemData["sound"]["name"] then
        if isUnEquip then
            self.lastHitSoundEffects = nil
        else
            self.lastHitSoundEffects = itemData["sound"]["name"]
        end
    end
end

function modifier_cosmetic_inventory_sb2023:AddSupporterLastHitParticleEffects(killedUnit, particleName)
    local maxParticleCount = 40
    local maxParticleRadius = 30
    local minParticleRadius = 8
    local maxHeight = 400

    local approximateHeight = math.min(killedUnit:GetBaseHealthBarOffset(), maxHeight)

    local particleCount = (approximateHeight / maxHeight) * maxParticleCount
    local particleRadius = (approximateHeight / maxHeight) * maxParticleRadius

    particleRadius = math.max(particleRadius, minParticleRadius)

    if killedUnit:IsConsideredHero() or killedUnit:IsAncient() then
        particleCount = particleCount * 1.35
        particleRadius = particleRadius * 1.35
    end

    particleCount = math.min(math.ceil(particleCount), maxParticleCount)
    particleRadius = math.min(math.ceil(particleCount), maxParticleRadius)

    local nPreviewFX = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, killedUnit)
    ParticleManager:SetParticleControl( nPreviewFX, 3, killedUnit:GetAbsOrigin() )
    ParticleManager:SetParticleControl( nPreviewFX, 4, Vector(particleCount, particleRadius, approximateHeight) )
    ParticleManager:ReleaseParticleIndex( nPreviewFX )
end

function modifier_cosmetic_inventory_sb2023:SetEmblemEffect(itemID, isUnEquip)
    if isUnEquip and self.emblemFX then
        ParticleManager:DestroyParticle(self.emblemFX, true)
        self.emblemFX = nil
        self.emblemParticleName = nil

        return
    end

    local itemData = GameRules.AbilityDraftRanked.cosmeticInventory:GetItemData(itemID, "emblems")

    if itemData and itemData["particles"] and itemData["particles"]["supporter_levels"] then

        local particleName = itemData["particles"]["supporter_" .. self.supporterLevel .."_name"]

        if particleName then
            if self.emblemFX then
                ParticleManager:DestroyParticle(self.emblemFX, true)
                self.emblemFX = nil
            end

            self.emblemParticleName = particleName

            if self:GetParent():HasModifier("modifier_mounted") then
                local mount = self:GetParent():_GetPlayerMount_SB2023()
                if mount then
                    self.emblemFX = ParticleManager:CreateParticle(self.emblemParticleName, PATTACH_ABSORIGIN_FOLLOW, mount)
                    self.emblemOnMount = true
                end
            else
                self.emblemFX = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
                self.emblemOnMount = false
            end
        end
    end
end

function modifier_cosmetic_inventory_sb2023:SwitchEmblemEffectWithMount()
    if not self.emblemFX or not self.emblemParticleName then
        return
    end

    if self.emblemOnMount then
        ParticleManager:DestroyParticle(self.emblemFX, true)
        self.emblemFX = ParticleManager:CreateParticle(self.emblemParticleName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self.emblemOnMount = false
    else
        local mount = self:GetParent():_GetPlayerMount_SB2023()
        if mount then
            ParticleManager:DestroyParticle(self.emblemFX, true)
            self.emblemFX = ParticleManager:CreateParticle(self.emblemParticleName, PATTACH_ABSORIGIN_FOLLOW, mount)
            self.emblemOnMount = true
        end
    end
end

function modifier_cosmetic_inventory_sb2023:SetAttackModifierEffect(itemID, isUnEquip)
    if isUnEquip then
        self.attackModifierEffect = nil

        return
    end

    local itemData = GameRules.AbilityDraftRanked.cosmeticInventory:GetItemData(itemID, "attack_modifiers")

    if itemData and itemData["particles"] and not itemData["particles"]["supporter_levels"] and itemData["particles"]["name"] then
        self.attackModifierEffect = itemData["particles"]["name"]
    end
end

function modifier_cosmetic_inventory_sb2023:SetHeroMount(itemID, isUnEquip)
    if isUnEquip then
        self.mountModel = self.baseMountModel
        self.mountParticleStrength = 0
    else
        local itemData = GameRules.AbilityDraftRanked.cosmeticInventory:GetItemData(itemID, "mounts")

        if itemData and itemData["model"] then
            self.mountModel = itemData["model"]
        end
    
        if itemData and itemData["particles"] and itemData["particles"]["supporter_levels"] and itemData["particles"]["particle_strength"] then
            
            local particleStrength = itemData["particles"]["supporter_" .. self.supporterLevel .."_strength"]
    
            if particleStrength then
                self.mountParticleStrength = particleStrength
            end
        end
    end

    local currentMount = self:GetParent():_GetPlayerMount_SB2023()
    if currentMount then
        local mountModifier = currentMount:FindModifierByName("modifier_mount_passive")
        if mountModifier then
            mountModifier:UpdateMountModel(self:GetCaster())
        end
    end
end

function modifier_cosmetic_inventory_sb2023:GetHeroMountModel()
    return self.mountModel
end

function modifier_cosmetic_inventory_sb2023:GetHeroMountParticleStrength()
    return self.mountParticleStrength
end

function modifier_cosmetic_inventory_sb2023:OnAttack(params)
	if IsServer() then
		if params.attacker ~= self:GetParent() then
			return
		end

        if not self.attackModifierEffect then
            return
        end

        if not params.target or params.inflictor then
            return
        end

        --block casting from abilities (unfortunately Medusa split shot also)
        if params.no_attack_cooldown then
            return
        end

        local projectileSpeed = self:GetParent():GetProjectileSpeed()

		if not self:GetParent():IsRangedAttacker() then
			projectileSpeed = 5000
		end

        local forceAttachmentID = nil

        if self:GetParent():GetUnitName() == "npc_dota_hero_muerta" and params.no_attack_cooldown then
            forceAttachmentID = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
        end

        self:StartAttackEffectModifierProjectile(params.target, projectileSpeed, forceAttachmentID)
	end
end

function modifier_cosmetic_inventory_sb2023:StartAttackEffectModifierProjectile(target, projectileSpeed, forceAttachmentID)
    if not self.attackModifierEffect then
        return
    end

    local attackModifierEffect = self.attackModifierEffect
    local attachmentID = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1

    if self.twoAttacksWariantsHero[self:GetParent():GetUnitName()] then
        local attack1 = self:GetParent():ScriptLookupAttachment("attach_attack1")
        local attack1Origin = self:GetParent():GetAttachmentOrigin(attack1)

        local distanceAttach1ToLina = (self:GetParent():GetAbsOrigin() - attack1Origin):Length2D()

        local attack2 = self:GetParent():ScriptLookupAttachment("attach_attack2")	
        local attack2Origin = self:GetParent():GetAttachmentOrigin(attack2)

        local distanceAttach2ToLina = (self:GetParent():GetAbsOrigin() - attack2Origin):Length2D()

        if distanceAttach2ToLina > distanceAttach1ToLina then
            attachmentID = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
        end
    end

    if forceAttachmentID then
        attachmentID = forceAttachmentID
    end

    -- launch projectile
    local info = {
        Target = target,
        Source = self:GetParent(),
        Ability = nil,
        
        EffectName = attackModifierEffect,
        iMoveSpeed = projectileSpeed,
        iSourceAttachment = attachmentID,
        bDodgeable = true,
        bIsAttack = false,
        bProvidesVision = false,
    }

    ProjectileManager:CreateTrackingProjectile(info)
end