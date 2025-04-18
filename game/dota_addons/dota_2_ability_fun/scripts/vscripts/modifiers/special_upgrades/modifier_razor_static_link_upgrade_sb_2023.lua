modifier_razor_static_link_upgrade_sb_2023 = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_razor_static_link_upgrade_sb_2023:IsHidden()
	return false
end

function modifier_razor_static_link_upgrade_sb_2023:IsPurgeException()
	return false
end

function modifier_razor_static_link_upgrade_sb_2023:IsPurgable()
	return false
end

function modifier_razor_static_link_upgrade_sb_2023:IsPermanent()
	return true
end

function modifier_razor_static_link_upgrade_sb_2023:GetTexture()
	return "razor_static_link"
end

function modifier_razor_static_link_upgrade_sb_2023:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_razor_static_link_upgrade_sb_2023:OnCreated(kv)
    if IsServer() then
        self.linkedUnits = {}

        self.ignoredUnits = {
            npc_dota_crate = true,
            npc_dota_vase = true,
        }
    end
end

function modifier_razor_static_link_upgrade_sb_2023:OnAbilityFullyCast(params)
    if IsServer() then
        if params.unit == self:GetParent() and params.ability:GetAbilityName() == "razor_static_link" then

            if not self.extraLink then
                local extraLink = self:GetParent():FindAbilityByName("razor_static_link_upgrade")

                if extraLink and extraLink:GetLevel() > 0 then
                    self.extraLink = extraLink
                end
            end

            local staticLinkLevel = params.ability:GetLevel()
            local staticLinkCastRange = params.ability:GetSpecialValueFor("AbilityCastRange")

            self.maxLinkedUnits = 2 * staticLinkLevel
            self.linkedEliteCreeps = 0

            if self.extraLink then
                local validLinkedUnits = {}

                for _, linkedUnit in pairs(self.linkedUnits) do
                    if linkedUnit and not linkedUnit:IsNull() and linkedUnit:IsAlive() then
                        local linkModifier = linkedUnit:FindModifierByNameAndCaster("modifier_razor_static_link_debuff", self:GetParent())

                        --if modifier duration is equel -1, it means razor is still connected to this unit
                        if linkModifier and linkModifier:GetDuration() < 0 then
                            table.insert(validLinkedUnits, linkedUnit)
                        end
                    end
                end

                self.linkedUnits = validLinkedUnits

                if #self.linkedUnits >= self.maxLinkedUnits then
                    return
                end
    
                -- potential Elite creeps to link
                local enemies = FindUnitsInRadius(
                    self:GetParent():GetTeamNumber(), 
                    self:GetParent():GetOrigin(), 
                    nil, 
                    staticLinkCastRange + 50,
                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
                    FIND_CLOSEST, 
                    false 
                )
    
                local enemiesToLink = {
                    elite = {},
                    base = {}
                }
    
                for _, enemy in pairs(enemies) do
                    if enemy and enemy:IsAlive() and not enemy:IsInvulnerable() and 
                        not self.ignoredUnits[enemy:GetUnitName()] and (not params.target or enemy ~= params.target )
                    then
                        local canLinkEnemy = true
    
                        for _, linkedUnit in pairs(self.linkedUnits) do
                            --don't allow to link the same unit many times!
                            if linkedUnit and not linkedUnit:IsNull() and linkedUnit == enemy then
                                canLinkEnemy = false
                                break
                            end
                        end
        
                        if canLinkEnemy then
                            if enemy:IsConsideredHero() or enemy:IsAncient() then
                                table.insert(enemiesToLink["elite"], enemy)
                            else
                                table.insert(enemiesToLink["base"], enemy)
                            end
                        end 
                    end
                end
    
                --first link Elite creeps
                for _, enemy in pairs(enemiesToLink["elite"]) do
                    if #self.linkedUnits >= self.maxLinkedUnits then
                        break
                    end
    
                    self:GetParent():SetCursorCastTarget(enemy)
                    self.extraLink:OnSpellStart()
    
                    table.insert(self.linkedUnits, enemy)
                end
    
                --then try link normal creeps
                if #self.linkedUnits < self.maxLinkedUnits then
                    for _, enemy in pairs(enemiesToLink["base"]) do
                        if #self.linkedUnits >= self.maxLinkedUnits then
                            break
                        end
        
                        self:GetParent():SetCursorCastTarget(enemy)
                        self.extraLink:OnSpellStart()
        
                        table.insert(self.linkedUnits, enemy)
                    end
                end
            end
        end
    end
end