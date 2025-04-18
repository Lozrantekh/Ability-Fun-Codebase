modifier_strong_illusion_hoodwink_ult = class({})

function modifier_strong_illusion_hoodwink_ult:IsHidden()
	return false
end

function modifier_strong_illusion_hoodwink_ult:IsPurgable()
	return false
end

function modifier_strong_illusion_hoodwink_ult:OnCreated( kv )
	if IsServer() then
        print("hoodwink illusion")
        self.hoodwinkUltimate = self:GetParent():FindAbilityByName("hoodwink_sharpshooter")

        if not self.hoodwinkUltimate then
            self:Destroy()
            return
        end

        self.range = self.hoodwinkUltimate:GetSpecialValueFor("AbilityCastRange") or 0

        self:OnIntervalThink()
        self:StartIntervalThink(0.5)
	end
end

function modifier_strong_illusion_hoodwink_ult:OnIntervalThink()
    if self.targetFound then
        self:Destroy()
        return
    end

    local enemyHero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
                    self:GetParent():GetAbsOrigin(),
                    nil,
                    self.range,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                    FIND_CLOSEST,
                    false
				)

    for _, enemy in ipairs(enemyHero) do
        if self.hoodwinkUltimate then
            self:GetParent():SetCursorPosition(self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector():Normalized() * 150)
            self.hoodwinkUltimate:OnSpellStart()
        end

        self.targetFound = true
        self:StartIntervalThink(-1)
        break
    end
end