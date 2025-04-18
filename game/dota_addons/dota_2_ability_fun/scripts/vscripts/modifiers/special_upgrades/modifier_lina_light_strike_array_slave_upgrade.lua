modifier_lina_light_strike_array_slave_upgrade = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_lina_light_strike_array_slave_upgrade:IsHidden()
	return false
end

function modifier_lina_light_strike_array_slave_upgrade:IsPurgeException()
	return false
end

function modifier_lina_light_strike_array_slave_upgrade:IsPurgable()
	return false
end

function modifier_lina_light_strike_array_slave_upgrade:IsPermanent()
	return true
end

function modifier_lina_light_strike_array_slave_upgrade:GetTexture()
	return "lina_dragon_slave"
end

function modifier_lina_light_strike_array_slave_upgrade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_lina_light_strike_array_slave_upgrade:OnCreated(kv)
    if IsServer() then
    end
end

function modifier_lina_light_strike_array_slave_upgrade:OnAbilityFullyCast(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self:GetParent() then
        return
    end

    if params.ability:GetAbilityName() ~= "lina_dragon_slave" then
        return
    end

    local unit = self:GetParent()

    self.dragonSlave = unit:FindAbilityByName("lina_dragon_slave")

    if not self.dragonSlave or self.dragonSlave:GetLevel() == 0 then
        return
    end
    
    local cursorPos = params.ability:GetCursorPosition()
    local casterPos = self:GetParent():GetAbsOrigin()

    --1st Dragon Slave in 45deg in left
    local newVector1 = RotatePosition(casterPos, QAngle(0, 45, 0), cursorPos)
    local direction1 = (newVector1 - casterPos):Normalized()

    local newPos1 = casterPos + direction1 * 350
    self:GetParent():SetCursorCastTarget(nil)
    self:GetParent():SetCursorPosition(newPos1)
    self.dragonSlave:OnSpellStart()

    --2nd Dragon Slave in 45deg in right
    local newVector2 = RotatePosition(casterPos, QAngle(0, -45, 0), cursorPos)
    local direction2 = (newVector2 - casterPos):Normalized()

    local newPos2 = casterPos + direction2 * 350
    self:GetParent():SetCursorCastTarget(nil)
    self:GetParent():SetCursorPosition(newPos2)
    self.dragonSlave:OnSpellStart()
end