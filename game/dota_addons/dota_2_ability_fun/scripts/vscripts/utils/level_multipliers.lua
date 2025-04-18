-- It's complicated
function GameRules:GetRoundHealthMultiplier(round)
	round = min(round, 100)

	if GAME_OPTION_LATE_BENCHMARK_MODE then round = 100 end
	if GAME_OPTION_EARLY_BENCHMARK_MODE then round = 40 end

	return -0.5 + max(0, round - 1) / 4 + 1.07 ^ round
end

-- It's complicated
function GameRules:GetRoundDamageMultiplier(round)
	round = min(round, 100)

	if GAME_OPTION_LATE_BENCHMARK_MODE then round = 100 end
	if GAME_OPTION_EARLY_BENCHMARK_MODE then round = 40 end

	return (max(0, round - 1) / 12) ^ 3 + 10 ^ (4 * round / 100)
end

-- Creeps BAT's get reduced 2.5% every 10 rounds, up to 25% at round 100
function GameRules:GetRoundBATMultiplier(round)
	return 1 - min(math.floor(round / 10), 10) * 0.025
end

-- Creeps gain 0.5 armor per round starting round 10
function GameRules:GetRoundArmor(round)
	return max(0, (round - 20) / 2)
end

-- It's complicated
function GameRules:GetRoundMagicResistance(round)
	round = max(0, (round - 20) / 5)

	return 100 * (0.06 * round) / (1 + 0.06 * round)
end

-- Creeps gradually gain 50% reduced status effect duration every 50 rounds
function GameRules:GetRoundStatusResistance(round)
	return 100 - 100 * 0.5 ^ (round / 50)
end

-- Creeps gain 2 attack speed per round, up to a max of +200 (wave 100)
function GameRules:GetRoundAttackSpeed(round)
	return min(round * 2, 200)
end

-- Creeps gradually deal 4x more spell damage every 40 rounds, up to 32x at round 100
function GameRules:GetRoundSpellAmp(round)
	round = min(round, 100)

	if GAME_OPTION_LATE_BENCHMARK_MODE then round = 100 end
	if GAME_OPTION_EARLY_BENCHMARK_MODE then round = 40 end

	return 4 ^ (round/40)
end

-- Creeps gain 15 movespeed every 10 rounds, up to a max of +120 (wave 80)
function GameRules:GetRoundMoveSpeed(round)
	return min(math.floor(round / 10) * 15, 120)
end

-- Creeps gain 1% accuracy per round starting on round 30 and max out at 50%.
function GameRules:GetRoundAccuracy(round)
	return Clamp(round - 30, 0, 50)
end

-- 10x harder every 200 rounds
function GameRules:GetRoundDamageResistance(round)
	return 100 - 100 / 10 ^ (round / 200)
end

--[[
	-- One additional creep per wave has true sight every 15 rounds
	function GameRules:GetRoundTrueSightCount(round)
		return math.floor(round / ROUND_MANAGER_ROUNDS_PER_TRUESIGHT_CREEP)
	end
]]

function GameRules:GetRoundTrueSightCount(round)
	return round < 30 and math.floor(round/10) or 69
end


function GameRules:GetRoundManaMultiplier(round)
	round = min(round, 100)

	return -0.5 + max(0, round - 1) / 4 + 1.07 ^ round
end

GameRules.hero_max_level = 1000
