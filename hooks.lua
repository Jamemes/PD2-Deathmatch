local allowed_jobs = {
	"branchbank_prof"
}

if string.lower(RequiredScript) == "lib/managers/crimenetmanager" then
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
elseif string.lower(RequiredScript) == "lib/managers/mutatorsmanager" then
	local data = MutatorsManager.get_category_color
	function MutatorsManager:get_category_color(category)
		if managers.menu:is_deathmatch_mode() then
			return tweak_data.screen_colors.pro_color
		end
		
		return data(self, category)
	end
	
	local data = MutatorsManager.get_category_text_color
	function MutatorsManager:get_category_text_color(category)
		if managers.menu:is_deathmatch_mode() then
			return tweak_data.screen_colors.pro_color
		end
		
		return data(self, category)
	end
	
	local data = MutatorsManager.get_enabled_active_mutator_category
	function MutatorsManager:get_enabled_active_mutator_category()
		if managers.menu:is_deathmatch_mode() then
			return "deathmatch"
		end
		
		return data(self)
	end
elseif string.lower(RequiredScript) == "lib/units/weapons/trip_mine/tripminebase" then

		-- if ray and managers.player:player_unit() then
-- function TripMineBase:_sensor(t)
	-- local ray = self:_raycast()
	
	-- if ray then
		-- ray.unit = managers.player:player_unit()
	-- end
	
	-- if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
		-- self._sensor_units_detected = self._sensor_units_detected or {}

		-- if not self._sensor_units_detected[ray.unit:key()] then
			-- self._sensor_units_detected[ray.unit:key()] = true

			-- if managers.player:has_category_upgrade("trip_mine", "sensor_highlight") and (managers.groupai:state():whisper_mode() and tweak_data.character[ray.unit:base()._tweak_table].silent_priority_shout or tweak_data.character[ray.unit:base()._tweak_table].priority_shout) then
				-- managers.game_play_central:auto_highlight_enemy(ray.unit, true)
				-- self:_emit_sensor_sound_and_effect()

				-- if managers.network:session() then
					-- managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", TripMineBase.EVENT_IDS.sensor_beep)
				-- end
			-- end

			-- self._sensor_last_unit_time = t + 5
		-- end
	-- end
-- end

end