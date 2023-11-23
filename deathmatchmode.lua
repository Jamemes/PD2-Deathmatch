MutatorFriendlyFire.settings_list = {
	{"respawn_time", 		{value = 0,		item = "slider", 		step = 1, 		min = 0, 		max = 120, 		round = 1 		}},
	{"bleedout", 			{value = 10,	item = "slider", 		step = 1, 		min = 0, 		max = 30, 		round = 1 		}},
	{"lives", 				{value = 3,		item = "slider", 		step = 1, 		min = 0, 		max = 5, 		round = 1 		}},
	{"damage_interval", 	{value = 0.35,	item = "slider", 		step = 0.01, 	min = 0, 		max = 1, 		round = 0.01 	}},
	{"armor_regen_speed", 	{value = 3,		item = "slider", 		step = 1, 		min = 1, 		max = 12, 		round = 0.01 	}},
	{"movement_speed", 		{value = 1,		item = "slider", 		step = 0.05, 	min = 0.5, 		max = 2, 		round = 0.01 	}},
	{"spread_mul", 			{value = 0,		item = "slider", 		step = 0.05, 	min = -2,	 	max = 1, 		round = 0.01 	}},
	{"recoil_mul", 			{value = 0,		item = "slider", 		step = 0.05, 	min = -2,	 	max = 1, 		round = 0.01 	}},
	{"reload_speed", 		{value = 1,		item = "slider", 		step = 0.05, 	min = 0.6,	 	max = 3, 		round = 0.01 	}},
	{"police_force", 		{value = 1,		item = "slider", 		step = 0.05, 	min = 1, 		max = 5, 		round = 0.01 	}},
	{"no_alarms", 			{value = 0,		item = "toggle"}}
}

-- MutatorFriendlyFire.default = "payback=0|friendlyfire=1|respawn_time=0|bleedout=10|lives=3|damage_interval=0.35|armor_regen_speed=3|movement_speed=1|spread_mul=1|recoil_mul=1|reload_speed=1|police_force=1|no_alarms=0"
MutatorFriendlyFire.default = {
	payback = 0,
	friendlyfire = 1
}
for _, setting in pairs(MutatorFriendlyFire.settings_list) do
	MutatorFriendlyFire.default[setting[1]] = setting[2].value
end

Hooks:PostHook(MutatorFriendlyFire, 'register_values', 'PD2DMRegisterValues', function(self, mutator_manager)
	self:register_value("deathmatch", managers.menu:conv_val(self.default, "string"), "dz")
end)

Hooks:PostHook(MutatorFriendlyFire, 'reset_to_default', 'PD2DMDefault', function(self)
	local values = deep_clone(self.default)
	local function reset_options(key, value)
		if self._node then
			local option = self._node:item(key)
			if option then
				option:set_value(value)
			end
		end
	end
	
	values.payback = 1
		
	for key, value in pairs(values) do
		reset_options(key, value)
	end
		
	self:set_value("deathmatch", managers.menu:conv_val(values, "string"))
end)

function MutatorFriendlyFire:conv(id, val)
	val = tonumber(val)
	
	if id == "per" then
		return (val > 1 and "+" or "") .. (val - 1) * 100 .. "%"
	elseif id == "min" then
		local sec = math.floor(val % 60)
		return math.floor(val / 60) % 60 .. ":" .. (sec < 10 and "0" .. sec or sec)
	elseif id == "sec" then
		return val .. " " .. managers.localization:text("secs")
	end
end

function MutatorFriendlyFire:name()
	local name = MutatorFriendlyFire.super.name(self)
	local values = managers.menu:conv_val(self:value("deathmatch"), "table")
	if values.payback == 1 then
		local dm = ""
		dm = self:value("deathmatch"):gsub("|", "\n")
		-- dm = dm .. managers.localization:text("dm_respawn_time") .. ":\n " .. self:conv("min", values[2]) .. "\n"

		-- dm = dm .. managers.localization:text("dm_bleedout") .. ":\n " .. self:conv("min", values[9]) .. "\n"
		
		-- dm = dm .. managers.localization:text("dm_lives") .. ":\n " .. math.round(values[10]) .. "\n"
		
		-- if math.round(values[3], 0.01) ~= 0 then
			-- dm = dm .. managers.localization:text("dm_damage_interval") .. ":\n " .. self:conv("sec", values[3]) .. "\n"
		-- end
		
		-- dm = dm .. managers.localization:text("dm_armor_regen_speed") .. ":\n " .. self:conv("sec", values[4]) .. "\n"
		
		-- if math.round(values[5], 0.01) ~= 1 then
			-- dm = dm .. managers.localization:text("dm_movement_speed") .. ":\n " .. self:conv("per", values[5]) .. "\n"
		-- end
		
		-- if math.round(values[6], 0.01) ~= 1 then
			-- dm = dm .. managers.localization:text("dm_police_force") .. ":\n " .. self:conv("per", values[6]) .. "\n"
		-- end
		


		-- if values[7] == "on" then
			-- dm = dm .. managers.localization:text("dm_no_alarms") .. ":\n -" .. managers.localization:text("dm_no_alarms_desc") .. "\n"
		-- end
		
		-- if math.round(values[2], 0.01) ~= 1 then
			-- dm = dm .. managers.localization:text("dm_damage_on_players") .. ":\n " .. self:conv("per", math.round(self:value("damage_multiplier"), 0.01)) .. "\n"
		-- end
		
		return dm
	else
		return name
	end
end

local data = MutatorFriendlyFire.setup_options_gui
function MutatorFriendlyFire:setup_options_gui(node)
	local function add_slider(name, step, min, max, round)
		local params = {
			name = name,
			callback = "_update_mutator_value",
			text_id = "dm_" .. name,
			update_callback = function(item)
				local values = managers.menu:conv_val(self:value("deathmatch"), "table")
				values[name] = math.round(item:value(), round)
				self:set_value("deathmatch", managers.menu:conv_val(values, "string"))
			end
		}
		
		local data_node = {
			show_value = true,
			step = step,
			type = "CoreMenuItemSlider.ItemSlider",
			decimal_count = 2,
			min = min,
			max = max
		}

		local new_item = node:create_item(data_node, params)

		local values = managers.menu:conv_val(self:value("deathmatch"), "table")
		new_item:set_value(values[name])
		node:add_item(new_item)
	end
	
	local function add_toggle(name)
		local params = {
			name = name,
			callback = "_update_mutator_value",
			text_id = "dm_" .. name,
			update_callback = function(item)
				local values = managers.menu:conv_val(self:value("deathmatch"), "table")
				values[name] = item:value()
				self:set_value("deathmatch", managers.menu:conv_val(values, "string"))
			end
		}
		local data_node = {
			{ w = 24, y = 0, h = 24, s_y = 24, value = 1, s_w = 24, s_h = 24, s_x = 24, _meta = "option", icon = "guis/textures/menu_tickbox", x = 24, s_icon = "guis/textures/menu_tickbox"},
			{ w = 24, y = 0, h = 24, s_y = 24, value = 0, s_w = 24, s_h = 24, s_x = 0, _meta = "option", icon = "guis/textures/menu_tickbox", x = 0, s_icon = "guis/textures/menu_tickbox"},
			type = "CoreMenuItemToggle.ItemToggle"
		}
		local new_item = node:create_item(data_node, params)

		local values = managers.menu:conv_val(self:value("deathmatch"), "table")
		new_item:set_value(values[name])
		node:add_item(new_item)
	end
	
	if string.find(self:value("deathmatch"), "payback=1") then
		for _, setting in pairs(self.settings_list) do
			if setting then
				if setting[2].item == "slider" then
					add_slider(setting[1], setting[2].step, setting[2].min, setting[2].max, setting[2].round)
				elseif setting[2].item == "toggle" then
					add_toggle(setting[1])
				end
			end
		end
		
		local values = managers.menu:conv_val(self:value("deathmatch"), "table")
		local slider = node:item("ff_damage_slider")
		if slider then
			slider:set_value(values.friendlyfire)
		end
		
		node:parameters().scene_state = "blackmarket"
	end
	
	return data(self, node)
end

Hooks:PostHook(MutatorFriendlyFire, 'modify_value', 'PD2DMModifyValues', function(self, id, value)
	local values = managers.menu:conv_val(self:value("deathmatch"), "table")
	if values.payback == 1 then
		if id == "HuskPlayerDamage:FriendlyFireDamage" then
			return value * values.friendlyfire
		end
	end
end)

Hooks:PostHook(MutatorFriendlyFire, '_update_damage_multiplier', 'PD2DMModifyDamageToPlayers', function(self, item)
	local values = managers.menu:conv_val(self:value("deathmatch"), "table")
	values.friendlyfire = math.round(item:value(), 0.01)
	self:set_value("deathmatch", managers.menu:conv_val(values, "string"))
end)

function MutatorFriendlyFire:on_game_started(mutator_manager)
	if not string.find(self:value("deathmatch"), "payback=1") then
		return
	end
	
	local values = managers.menu:conv_val(self:value("deathmatch"), "table")
	local group = tweak_data.group_ai
	local force = group.besiege.assault.force_balance_mul
	
	ElementDialogue._can_play = function() end
	ObjectivesManager.activate_objective = function() end
	HUDManager.add_waypoint = function() end
	HUDSuspicion.show = function() end
	SecurityCamera._set_suspicion_sound = function() end
	ElementMissionEnd.on_executed = function() end
	TradeManager._announce_spawn = function() end
	ElementPointOfNoReturn.operation_add = function() end
	ContourExt._upd_color = function() end

		-- for _, unit in pairs(tweak_data.character) do
			-- if unit.calls_in then
				-- unit.calls_in = nil
			-- end
		-- end	

		
		-- managers.groupai:add_event_listener({}, "start_assault", function()
			-- managers.groupai:state():set_wave_mode("hunt")
		-- end)
		
		-- local action_request = CopMovement.action_request
		-- function CopMovement:action_request(action_desc)

		-- "e_so_alarm_under_table",
		-- "e_so_std_alarm",
		-- "cmf_so_press_alarm_wall",
		-- "cmf_so_press_alarm_table",
		
			-- if action_desc.variant == "run" then
				-- action_desc.variant = "suppressed_reaction"
				-- return false
			-- end
			
			-- return action_request(self, action_desc)
		-- end
		
	if values.no_alarms == 1 then
		-- GroupAIStateBase.on_police_called = function() end
		-- CivilianLogicFlee.on_police_call_success = function() end
		-- GroupAIStateBase.on_police_weapons_hot = function() end
		-- GroupAIStateBase.on_gangster_weapons_hot = function() end
		-- CopBrain.begin_alarm_pager = function() end
		
		if managers.groupai then
			managers.groupai:state():set_AI_enabled(false)
		end
						
		ElementLaserTrigger.update_laser = function() return end
	end
	
	Hooks:PostHook(MissionBriefingGui, "on_ready_pressed", "PD2DMSendtocustodyafterloadout", function(self, ...)
		if self._ready and not game_state_machine:current_state().blackscreen_started then
			managers.menu:close_menu("kit_menu")
			managers.menu_component:close_mission_briefing_gui()
			managers.hud._hud_mission_briefing:hide()
			managers.menu_component:close_chat_gui()
			
			if Global.hud_disabled then
				managers.hud:set_enabled()
			end
			
			MenuCallbackHandler:debug_goto_custody()
		end
	end)
	
	IngameWaitingForRespawnState.GUI_SPECTATOR_FULLSCREEN = Idstring("guis/spectator_mode")
	Hooks:PostHook(IngameWaitingForRespawnState, "at_enter", "PD2DMStartCustodyFogOfWar", function(self)	
		self._PD2DM_backdrop = MenuBackdropGUI:new()
		local gui_width, gui_height = managers.gui_data:get_base_res()
		local variant = math.random(2)
		local background_layer_full = self._PD2DM_backdrop:get_new_background_layer()
		local video = background_layer_full:video({
			blend_mode = "add",
			name = "money_video",
			alpha = 0.25,
			loop = true,
			video = "movies/fail_stage" .. tostring(variant),
			width = gui_width,
			height = gui_height
		})
	end)
	
	Hooks:PostHook(IngameWaitingForRespawnState, "at_exit", "PD2DMClearCustodyFogOfWar", function(self)
		self._PD2DM_backdrop:destroy()
	end)
	
	Hooks:PostHook(MissionBriefingGui, "close", "PD2DMFixDMLogo", function(self, ...)
		self._safe_workspace:panel():remove(self._lobby_mutators_text)
	end)

	IngameWaitingForRespawnState.trade_death = function()
		managers.dialog:queue_narrator_dialog("h51", {})
	end
	
	Hooks:PostHook(SecurityCamera, "_sound_the_alarm", "PD2DMAlarmBeepRemoval", function(self, ...)
		self._alarm_sound = self._unit:sound_source():post_event("camera_silent")
	end)
	
	Hooks:PostHook(HUDManager, 'align_teammate_name_label', 'PD2DMRemoveNameLables', function(self, panel, ...)
		panel:set_size(0, 0)
	end)
	
	if values.lives <= 1 then
		for i, panels in ipairs(managers.hud._teammate_panels) do
			if panels and panels:panel() then
				panels:panel():child("player"):child("revive_panel"):hide()
				panels:panel():child("callsign"):show()
				panels:panel():child("callsign_bg"):show()
			end
		end
	end
	
	Hooks:PostHook(HuskPlayerMovement, "set_character_anim_variables", "PD2DMRemoveTeammateContours", function(self)
		self._unit:contour():add("teammate", nil, nil, Color.black)
	end)

	local data = EnemyManager.add_delayed_clbk
	function EnemyManager:add_delayed_clbk(id, clbk, execute_t)

		if id == "_gameover_clbk" then
			execute_t = 10^10
		end
		
		data(self, id, clbk, execute_t)
	end
	
	local data = PlayerManager.movement_speed_multiplier
	function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
		local value = data(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)

		value = value * values.movement_speed
		
		return value
	end
	
		
	local data = NewRaycastWeaponBase.reload_speed_multiplier
	function NewRaycastWeaponBase:reload_speed_multiplier()
		local mul = data(self)

		return mul * values.reload_speed
	end

	local data = NewRaycastWeaponBase.recoil_multiplier
	function NewRaycastWeaponBase:recoil_multiplier()
		local mul = data(self)
		mul = mul * (1 - values.recoil_mul)
		return mul 
	end
	
	local data = NewRaycastWeaponBase.spread_multiplier
	function NewRaycastWeaponBase:spread_multiplier(current_state)
		local mul = data(self, current_state)
		mul = mul * (1 - values.spread_mul)
		return mul
	end

	-- local __reload_speed_multiplier = NewRaycastWeaponBase.reload_speed_multiplier
	-- function NewRaycastWeaponBase:recoil_multiplier()
		-- local is_moving = false
		-- local user_unit = self._setup and self._setup.user_unit

		-- if user_unit then
			-- is_moving = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state and user_unit:movement()._current_state._moving
		-- end

		-- local multiplier = managers.blackmarket:recoil_multiplier(self._name_id, self:weapon_tweak_data().categories, self._silencer, self._blueprint, is_moving)

		-- if self._alt_fire_active and self._alt_fire_data then
			-- multiplier = multiplier * (self._alt_fire_data.recoil_mul or 1)
		-- end

		-- return multiplier
	-- end
	
	-- local data = PlayerManager.body_armor_skill_multiplier
	-- function PlayerManager:body_armor_skill_multiplier(override_armor)
		-- local value = data(self, override_armor)

		-- value = value * values.movement_speed
		
		-- return value
	-- end
	
	-- function PlayerManager:body_armor_skill_multiplier(override_armor)
		-- local multiplier = 1
		-- multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
		-- multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
		-- multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
		-- multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
		-- multiplier = multiplier + self:get_hostage_bonus_multiplier("armor") - 1
		-- multiplier = multiplier + self:upgrade_value("player", "perk_armor_loss_multiplier", 1) - 1
		-- multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1
		-- multiplier = multiplier + self:upgrade_value("player", "chico_armor_multiplier", 1) - 1
		-- multiplier = multiplier + self:upgrade_value("player", "mrwi_armor_multiplier", 1) - 1

		-- return multiplier
	-- end
	
	local data = CriminalsManager.get_valid_player_spawn_pos_rot
	function CriminalsManager:get_valid_player_spawn_pos_rot(peer_id)
		local returned = data(self, peer_id)
		local level = Global.game_settings.level_id
		
		if level == "branchbank" then
			return table.random({
				{Vector3(-3969, -2206, 6), Rotation(-69, 0, 0)},
				{Vector3(-4831, -2344, -14), Rotation(37, 0, 0)},
				{Vector3(-6181, -3169, -14), Rotation(-1, 0, 0)},
				{Vector3(-8358, -3252, -14), Rotation(-91, 0, 0)},
				{Vector3(-5233, 2885, -14), Rotation(-81, 0, 0)},
				{Vector3(-4917, 2053, -14), Rotation(-36, 0, 0)},
				{Vector3(-2744, 162, 1), Rotation(-89, 0, 0)},
				{Vector3(-2129, 1167, -14), Rotation(176, 0, 0)},
				{Vector3(-1329, 1747, -14), Rotation(-5, 0, 0)},
				{Vector3(-1648, 3183, -14), Rotation(1, 0, 0)},
				{Vector3(2272, 3316, -14), Rotation(63, 0, 0)},
				{Vector3(-58, -18, -14), Rotation(-131, 0, 0)},
				{Vector3(-1151, -1937, -14), Rotation(-29, 0, 0)},
				{Vector3(-1393, 222, 386), Rotation(87, 0, 0)},
				{Vector3(-387, 3073, 386), Rotation(157, 0, 0)},
				{Vector3(-217, 2939, -14), Rotation(173, 0, 0)},
				{Vector3(-1514, 2185, -14), Rotation(-90, 0, 0)}
			})
		end
		
		return returned
	end
	
	if values.police_force ~= 1 then
		for i = 1, 4 do
			force[i] = force[i] * values.police_force
		end
	end
	
	for _, lvl in pairs(tweak_data.levels) do
		if lvl.name_id then
			lvl.team_ai_off = true
		end
	end
	
	local color = Color.black
	local cont = tweak_data.contour
	cont.character.standard_color = color
	cont.character.friendly_color = color
	cont.character.friendly_minion_color = color
	cont.character.downed_color = color
	cont.character.dead_color = color
	cont.character.tmp_invulnerable_color = color
	cont.character_interactable.standard_color = color
	cont.interactable.standard_color = color
	cont.contour_off.standard_color = color
	cont.deployable.standard_color = color
	cont.deployable.active_color = color
	cont.deployable.disabled_color = color
	cont.upgradable.standard_color = color
	cont.pickup.standard_color = color
	cont.interactable_icon.standard_color = color
	cont.interactable_look_at.standard_color = color

	local player = tweak_data.player
	player.damage.automatic_respawn_time = values.respawn_time
	player.damage.MIN_DAMAGE_INTERVAL = values.damage_interval
	player.damage.REGENERATE_TIME = values.armor_regen_speed
	player.damage.DOWNED_TIME = values.bleedout
	player.damage.LIVES_INIT = 1 + values.lives
	player.damage.respawn_time_penalty = 0
	player.damage.base_respawn_time_penalty = 0

	local speed = tweak_data.timespeed
	speed.mask_on.sustain = 0
	speed.mask_on.speed = 0
	speed.mask_on.fade_out = 0
	speed.mask_on.fade_in = 0
	speed.mask_on.fade_in_delay = 0
	speed.mask_on_player.sustain = 0
	speed.mask_on_player.speed = 0
	speed.mask_on_player.fade_out = 0
	speed.mask_on_player.fade_in = 0
	speed.mask_on_player.fade_in_delay = 0
	speed.downed.sustain = 0
	speed.downed.speed = 0
	speed.downed.fade_out = 0
	speed.downed.fade_in = 0
	speed.downed_player.sustain = 0
	speed.downed_player.speed = 0
	speed.downed_player.fade_out = 0
	speed.downed_player.fade_in = 0
	speed.mission_effects.quickdraw.sustain = 0
	speed.mission_effects.quickdraw.speed = 0
	speed.mission_effects.quickdraw.fade_out = 0
	speed.mission_effects.quickdraw.fade_in = 0
	speed.mission_effects.quickdraw.fade_in_delay = 0
	speed.mission_effects.quickdraw_player.sustain = 0
	speed.mission_effects.quickdraw_player.speed = 0
	speed.mission_effects.quickdraw_player.fade_out = 0
	speed.mission_effects.quickdraw_player.fade_in = 0
	speed.mission_effects.quickdraw_player.fade_in_delay = 0

	local effects = tweak_data.overlay_effects
	effects.spectator.fade_out = 0.5
	effects.spectator.fade_in = 0.5
	effects.fade_in.fade_out = 0.5

	for _, proj in pairs(tweak_data.projectiles) do
		if proj.player_damage then
			proj.player_damage = proj.damage
		end
	end
	
	tweak_data.weapon.trip_mines.player_damage = 100
end