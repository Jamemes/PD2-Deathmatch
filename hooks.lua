local allowed_jobs = {
	"branchbank_prof"
}

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
elseif string.lower(RequiredScript) == "lib/managers/crimenetmanager" then
	local data = CrimeNetManager.preset
	function CrimeNetManager:preset(id)
		local presets = data(self, id)
		
		if managers.menu:is_deathmatch_mode() then
			presets.job_id = table.random(allowed_jobs)
		end
		
		return presets
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/contractbrokergui" then
	Hooks:PostHook(ContractBrokerGui, '_create_job_data', 'PD2DMExcludeJobs', function(self, ...)
		if managers.menu:is_deathmatch_mode() then
			local jobs = {}
			local contacts = {}
			local max_jc = managers.job:get_max_jc_for_player()
			local current_date_value = {
				tonumber(os.date("%Y")),
				tonumber(os.date("%m")),
				tonumber(os.date("%d"))
			}
			current_date_value = current_date_value[1] * 30 * 12 + current_date_value[2] * 30 + current_date_value[3]
			local job_tweak, dlc, date_value, contact, contact_tweak, include_job = nil

			for index, job_id in ipairs(allowed_jobs) do
				job_tweak = tweak_data.narrative:job_data(job_id)
				contact = job_tweak.contact
				contact_tweak = tweak_data.narrative.contacts[contact]

				if self._job_filter then
					include_job = self._job_filter(job_id, contact, job_tweak, contact_tweak)
				else
					include_job = not tweak_data.narrative:is_wrapped_to_job(job_id)
					include_job = include_job and contact_tweak and not contact_tweak.hidden
				end

				if include_job then
					dlc = not job_tweak.dlc or managers.dlc:is_dlc_unlocked(job_tweak.dlc)
					dlc = dlc and not tweak_data.narrative:is_job_locked(job_id)
					date_value = job_tweak.date_added and job_tweak.date_added[1] * 30 * 12 + job_tweak.date_added[2] * 30 + job_tweak.date_added[3] - current_date_value or false

					table.insert(jobs, {
						job_id = job_id,
						job_tweak = job_tweak,
						contact = contact,
						contact_tweak = contact_tweak,
						enabled = dlc and max_jc >= (job_tweak.jc or 0) + (job_tweak.professional and 10 or 0),
						date_value = date_value,
						is_new = date_value ~= false and date_value >= -self.RELEASE_WINDOW
					})

					contacts[contact] = contacts[contact] or {}

					table.insert(contacts[contact], jobs[#jobs])
				end
			end

			self._job_data = jobs
			self._contact_data = contacts
		end
	end)
end