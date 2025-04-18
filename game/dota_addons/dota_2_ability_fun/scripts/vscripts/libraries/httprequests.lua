
-- local PROD_API_URL = "http://127.0.0.1/keymillo_arcade/"
local PROD_API_URL = "http://3.74.100.150"

if _HTTPConnection == nil then
	_HTTPConnection = {}
end

_HTTPConnection.maxServerAttempts = 5

function _HTTPConnection:getUserInfo(nPlayerID, isReconnect, attemptCounter)

	if attemptCounter > MAX_ATTEMPTS then
		local gameEvent = {}
		gameEvent["player_id"] = nPlayerID
		gameEvent["teamnumber"] = PlayerResource:GetTeam(nPlayerID)
		gameEvent["locstring_value"] = "Connection To Server Failed - Please Use Reconnect Button!"
		gameEvent["message"] = "#DOTA_AD_2023_ErrorDatabase"

		FireGameEvent( "dota_combat_event_message", gameEvent )

		local extraInfo = {
			text = "Your Data Was Not Fetched From Server - Please Use Reconnect Button!",
			duration = 10,
			error = true
		}
		
		local player = PlayerResource:GetPlayer(nPlayerID)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_info", extraInfo )	

		if isReconnect then
			if GameRules.AbilityDraftRanked.playersServerReconnectTry[nPlayerID] then
				GameRules.AbilityDraftRanked.playersServerReconnectTry[nPlayerID]["status"] = 0
			end

			local gameBaseInfoTable = CustomNetTables:GetTableValue("global_info", "game_info")
			if not gameBaseInfoTable then
				gameBaseInfoTable = {}
			end
	
			gameBaseInfoTable["server_reconnecting_status"] = 0
			CustomNetTables:SetTableValue( "global_info", "game_info", gameBaseInfoTable)
		end

		--end 
		return
	end

	local request = CreateHTTPRequestScriptVM( "GET", PROD_API_URL)
	request:SetHTTPRequestGetOrPostParameter("steam_id", tostring(PlayerResource:GetSteamAccountID(nPlayerID)))
	request:SetHTTPRequestGetOrPostParameter("action", "ad_user_info")
	request:SetHTTPRequestGetOrPostParameter("auth_key", _serverToken)
	-- request:SetHTTPRequestGetOrPostParameter("XDEBUG_SESSION_START", "PHPSTORM")

	request:Send(
		function(result)
			if result.StatusCode ~= 200 then
				Timers:CreateTimer(0.5 + attemptCounter * 0.25, function ()
					self:getUserInfo(nPlayerID, isReconnect, attemptCounter + 1)
				end)
			else
				if result.Body == "" then
					return
				end
	
				local jsonTable = json.parse(result.Body)
	
				if not jsonTable or type ( jsonTable) ~= "table" then
					return
				end
	
				--update player info
				if GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID] then
					local mmr = jsonTable["ad_mmr"] or 0
					local patronLevel = jsonTable["supporter_level"] or 0
	
					--new players has set mmr to -1 in database to recognize from players who have fallen to 0 (0 is min value).
					if mmr == -1 then
						mmr = GameRules.AbilityDraftRanked.basePlayerMMR
					end
	
					GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["mmr"] = mmr
					GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["supporter_level"] = patronLevel
	
					--currently no extra bonuses for supporters
					-- if patronLevel > 0 and GameRules.AbilityDraftRanked.patronBonuses[patronLevel] then
					-- 	GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["hero_rerolls"] = GameRules.AbilityDraftRanked.patronBonuses[patronLevel]["hero_rerolls"] or 0
					-- 	GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["talent_rerolls"] = GameRules.AbilityDraftRanked.patronBonuses[patronLevel]["talent_rerolls"] or 0
					-- end
	
					--update players base stats
					GameRules.AbilityDraftRanked:UpdatePlayerStatsTable(nPlayerID, false, isReconnect)
				end

				if isReconnect then
					if GameRules.AbilityDraftRanked.playersServerReconnectTry[nPlayerID] then
						GameRules.AbilityDraftRanked.playersServerReconnectTry[nPlayerID]["status"] = 1
					end

					local extraInfo = {
						text = "Player Data Fetched From Server Successfully!",
						duration = 2.5,
						color = "lime"
					}
					
					local player = PlayerResource:GetPlayer(nPlayerID)
					CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_info", extraInfo )	

					local gameBaseInfoTable = CustomNetTables:GetTableValue("global_info", "game_info")
					if not gameBaseInfoTable then
						gameBaseInfoTable = {}
					end
			
					gameBaseInfoTable["server_reconnecting_status"] = 0
					CustomNetTables:SetTableValue( "global_info", "game_info", gameBaseInfoTable)
				end
			end
		end
	)
end

function _HTTPConnection:getManyUsersInfo(usersData, attemptNumber)
	if not attemptNumber or not tonumber(attemptNumber) then
		return
	end

	if attemptNumber > self.maxServerAttempts then
		return
	end

	local jsonData = json.stringify(usersData)

	local request = CreateHTTPRequestScriptVM( "POST", PROD_API_URL)
	request:SetHTTPRequestGetOrPostParameter("users_steam_id", jsonData)
	request:SetHTTPRequestGetOrPostParameter("action", "ad_many_users_info")
	request:SetHTTPRequestGetOrPostParameter("auth_key", _serverToken)
	-- request:SetHTTPRequestGetOrPostParameter("XDEBUG_SESSION_START", "PHPSTORM")

	local steamIdToPlayerId = {}

	for _, userData in pairs(usersData) do
		if userData["steam_id"] and userData["player_id"] then
			steamIdToPlayerId["id_" .. userData["steam_id"]] = userData["player_id"]
		end
	end

	request:Send(
		function(result)
			if result.StatusCode ~= 200 or not result.Body or result.Body == "" then
				Timers:CreateTimer(0.5 * (attemptNumber + 1), function ()
					self:getManyUsersInfo(usersData, attemptNumber + 1)
				end)

				return
			end

			local jsonTable = json.parse(result.Body)

			if not jsonTable or type ( jsonTable) ~= "table" then
				return
			end

			--update players info
			for _, playerData in pairs(jsonTable) do
				if playerData["steam_id"] and steamIdToPlayerId["id_" .. playerData["steam_id"]] then
					local nPlayerID = steamIdToPlayerId["id_" .. playerData["steam_id"]]

					if GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID] then
						local mmr = playerData["ad_mmr"] or 0
						local patronLevel = playerData["supporter_level"] or 0

						--new players has set mmr to -1 in database to recognize from players who have fallen to 0 (0 is min value).
						if mmr == -1 then
							mmr = GameRules.AbilityDraftRanked.basePlayerMMR
						end
		
						GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["mmr"] = mmr
						GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["supporter_level"] = patronLevel

						--currently no extra bonuses for supporters
						-- if patronLevel > 0 and GameRules.AbilityDraftRanked.patronBonuses[patronLevel] then
						-- 	GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["hero_rerolls"] = GameRules.AbilityDraftRanked.patronBonuses[patronLevel]["hero_rerolls"] or 0
						-- 	GameRules.AbilityDraftRanked._vPlayerStats[nPlayerID]["talent_rerolls"] = GameRules.AbilityDraftRanked.patronBonuses[patronLevel]["talent_rerolls"] or 0
						-- end
		
						--update players base stats
						GameRules.AbilityDraftRanked:UpdatePlayerStatsTable(nPlayerID, false)
					end
				end
			end

			GameRules.AbilityDraftRanked.playersDataFetched = true
		end
	)
end

function _HTTPConnection:updateDataForManyPlayers(data, attemptNumber)
	if not attemptNumber or not tonumber(attemptNumber) then
		return
	end

	if attemptNumber > self.maxServerAttempts then
		return
	end

	if (GameRules:IsCheatMode() and IsDedicatedServer()) then
		return
	end

	if data then
		local jsonData = json.stringify(data)

		local request = CreateHTTPRequestScriptVM( "POST", PROD_API_URL)
		request:SetHTTPRequestGetOrPostParameter("ad_players_data", jsonData)
		request:SetHTTPRequestGetOrPostParameter("action", "update_ad_users_mmr")
		request:SetHTTPRequestGetOrPostParameter("auth_key", _serverToken)
		-- request:SetHTTPRequestGetOrPostParameter("XDEBUG_SESSION_START", "PHPSTORM")
	
		request:Send(
			function(respone)
				if respone.StatusCode ~= 200 then
					Timers:CreateTimer(0.5 * (attemptNumber + 1), function ()
						self:updateDataForManyPlayers(data, attemptNumber + 1)
					end)
					return
				end
			end
		)
	end
end

function _HTTPConnection:getTopPlayersMMR(attemptNumber)
	if not attemptNumber or not tonumber(attemptNumber) then
		return
	end

	if attemptNumber > self.maxServerAttempts then
		print("attempts end")
		return
	end

	local request = CreateHTTPRequestScriptVM("GET", PROD_API_URL)
	request:SetHTTPRequestGetOrPostParameter("action", "ad_top_mmr")
	request:SetHTTPRequestGetOrPostParameter("auth_key", _serverToken)

	request:Send(
		function(result)
			if result.StatusCode ~= 200 or not result.Body or result.Body == "" then
				Timers:CreateTimer(0.5 * (attemptNumber + 1), function ()
					self:getTopPlayersMMR(attemptNumber + 1)
				end)
				return
			end

			local jsonTable = json.parse(result.Body)

			if not jsonTable or type ( jsonTable) ~= "table" then
				return
			end

			GameRules.AbilityDraftRanked.topPlayersMMR = jsonTable

			CustomNetTables:SetTableValue( "top_mmr_players", "0", jsonTable)
		end
	)
end

function _HTTPConnection:updateMatchTestData(data, attemptNumber)
	if not attemptNumber or not tonumber(attemptNumber) then
		return
	end

	if attemptNumber > self.maxServerAttempts then
		print("attempts end")
		return
	end

	local jsonData = json.stringify(data)

	local request = CreateHTTPRequestScriptVM("POST", PROD_API_URL)
	request:SetHTTPRequestGetOrPostParameter("action", "set_test_data")
	request:SetHTTPRequestGetOrPostParameter("test_data", jsonData)
	request:SetHTTPRequestGetOrPostParameter("auth_key", _serverToken)
	-- request:SetHTTPRequestGetOrPostParameter("XDEBUG_SESSION_START", "PHPSTORM")

	request:Send(
		function(result)
			if result.StatusCode ~= 200 then
				Timers:CreateTimer(0.5 * (attemptNumber + 1), function ()
					self:updateMatchTestData(attemptNumber + 1)
				end)
				return
			end
		end
	)
end