if string.lower(RequiredScript) == "lib/managers/enemymanager" then
	local data = EnemyManager.add_delayed_clbk
	function EnemyManager:add_delayed_clbk(id, clbk, execute_t)

		if id == "_gameover_clbk" then
			execute_t = managers.mutators:modify_value("PD2DMStopGameOverScreen", execute_t)
		end
		
		data(self, id, clbk, execute_t)
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/huskplayermovement" then
	Hooks:PostHook(HuskPlayerMovement, "set_character_anim_variables", "PD2DMRemoveTeammateContours", function(self)
		managers.mutators:modify_value("PD2DMRemoveTeammateContours", self)
	end)
elseif string.lower(RequiredScript) == "lib/managers/trademanager" then
	local data = TradeManager._announce_spawn
	function TradeManager:_announce_spawn(criminal_name)
		if managers.mutators:modify_value("PD2DMRespawnAnnouncement", self) == "true" then
			return
		end
		
		data(self, criminal_name)
	end
elseif string.lower(RequiredScript) == "lib/managers/criminalsmanager" then
	local data = CriminalsManager.get_valid_player_spawn_pos_rot
	function CriminalsManager:get_valid_player_spawn_pos_rot(peer_id)
		local returned = data(self, peer_id)
		
		returned = managers.mutators:modify_value("PD2DMGetRespawnPositions", returned)
		
		return returned
	end
elseif string.lower(RequiredScript) == "lib/states/ingamewaitingforrespawn" then
	local data = IngameWaitingForRespawnState.trade_death
	function IngameWaitingForRespawnState:trade_death(respawn_delay, hostages_killed)
		if managers.mutators:modify_value("PD2DMRespawnAnnouncement", self) == "true" then
			managers.dialog:queue_narrator_dialog("h51", {})
			return
		end
		
		data(self, respawn_delay, hostages_killed)
	end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
	Hooks:PostHook(HUDTeammate, 'init', 'PD2DMRemoveDownCounter', function(self)
		managers.mutators:modify_value("PD2DMRemoveDownCounter", self)
	end)
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, 'align_teammate_name_label', 'PD2DMRemoveNameLables', function(self, panel, ...)
		managers.mutators:modify_value("PD2DMRemoveNameLables", panel)
	end)
elseif string.lower(RequiredScript) == "lib/managers/playermanager" then
	local data = PlayerManager.movement_speed_multiplier
	function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
		local returned = data(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
		
		returned = managers.mutators:modify_value("PD2DMMovementSpeed", returned)
		
		return returned
	end
end