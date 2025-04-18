modifier_model_scale_ad_2023 = class({})

--------------------------------------------------------------------------------

function modifier_model_scale_ad_2023:IsHidden()
	return true
end

function modifier_model_scale_ad_2023:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_model_scale_ad_2023:OnCreated( kv )
	if IsServer() then
		self.modelScale = 0

		if self:GetAbility() then
			self.modelScale = self:GetAbility():GetSpecialValueFor("model_scale")
		end

		if kv.model_scale then
			self.modelScale = kv.model_scale
		end

		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_model_scale_ad_2023:OnRefresh(kv)
	if IsServer() then
		self:OnCreated(kv)
	end
end

--------------------------------------------------------------------------------

function modifier_model_scale_ad_2023:AddCustomTransmitterData( )
	return
	{
		modelScale = self.modelScale,
	}
end

--------------------------------------------------------------------------------

function modifier_model_scale_ad_2023:HandleCustomTransmitterData( data )
	data.modelScale = self.modelScale
end


function modifier_model_scale_ad_2023:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

-----------------------------------------------------------------------
function modifier_model_scale_ad_2023:GetModifierModelScale()
	if self.modelScale then
		return self.modelScale
	end

	return 0
end

function modifier_model_scale_ad_2023:OnDestroy()
	if IsServer() then
		local particleFX = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(particleFX)
	end
end