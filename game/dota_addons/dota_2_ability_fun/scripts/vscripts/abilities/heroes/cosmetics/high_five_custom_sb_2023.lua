high_five_custom_sb_2023 = class({})

LinkLuaModifier("modifier_high_five_custom_search_sb_2023", "modifiers/cosmetics/modifier_high_five_custom_search_sb_2023", LUA_MODIFIER_MOTION_NONE)

function high_five_custom_sb_2023:IsCosmetic(hEntity)
    return true
end

function high_five_custom_sb_2023:IsHiddenAbilityCastable()
    return true
end

function high_five_custom_sb_2023:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        self.effectsData = {}

        local cosmeticInventory = caster:FindModifierByName("modifier_cosmetic_inventory_sb2023")
        if cosmeticInventory then
            local highFiveData = cosmeticInventory:GetHighFiveCustomEffects()
            if highFiveData then
                self.effectsData = highFiveData
            end
        end

        if not self.effectsData["overhead"] then
            self.effectsData["overhead"] = {
                particle = "particles/econ/events/plus/high_five/high_five_lvl1_overhead.vpcf",
                sound = "high_five.cast"
            }
        end

        if not self.effectsData["travel"] then
            self.effectsData["travel"] = {
                particle = "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf",
            }
        end

        if not self.effectsData["impact"] then
            self.effectsData["impact"] = {
                particle = "particles/econ/events/plus/high_five/high_five_impact.vpcf",
                sound = "high_five.impact",
            }
        end

        if not self.effectsData["fail"] then
            self.effectsData["fail"] = {
                sound = "high_five.fail",
            }
        end

        caster:AddNewModifier(caster, self, "modifier_high_five_custom_search_sb_2023", 
            {
                duration = 10, 
                overhead_particle = self.effectsData["overhead"]["particle"],
                travel_particle = self.effectsData["travel"]["particle"],
                fail_sound = self.effectsData["fail"]["sound"],
            }
        )

        caster:EmitSound(self.effectsData["overhead"]["sound"])
    end
end

function high_five_custom_sb_2023:OnProjectileThink_ExtraData(vPos, data)
    if IsServer() then
        if not data then
            return true
        end

        if data["collisionX"] and data["collisionY"] and data["collisionZ"] then
            local collisionPos = Vector(data["collisionX"], data["collisionY"], data["collisionZ"])

            if (vPos - collisionPos):Length2D() <= 25 then
                local particle = ParticleManager:CreateParticle(self.effectsData["impact"]["particle"], PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl( particle, 0, vPos )
                ParticleManager:SetParticleControl(particle, 3, vPos)

                ParticleManager:ReleaseParticleIndex(particle)


                EmitSoundOnLocationWithCaster(vPos, self.effectsData["impact"]["sound"], self:GetCaster())
            end
        end

        return true
    end
end