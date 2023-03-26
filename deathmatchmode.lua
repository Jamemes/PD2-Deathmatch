MutatorFriendlyFire.default = "disabled|5|0|6|1|1|off|1"

Hooks:PostHook(MutatorFriendlyFire, 'register_values', 'PD2DMRegisterValues', function(self, mutator_manager)
	self:register_value("deathmatch", self.default, "dz")
end)

Hooks:PostHook(MutatorFriendlyFire, 'reset_to_default', 'PD2DMDefault', function(self)
	local values = string.split(self.default, "|")
	local function reset_options(index, id)
		if self._node then
			local option = self._node:item(id)
			if option then
				option:set_value(values[index])
			end
		end
	end
	
	values[1] = "enabled"
	reset_options(2, "respawn_time")
	reset_options(3, "damage_interval")
	reset_options(4, "armor_regen_speed")
	reset_options(5, "movement_speed")
	reset_options(6, "police_force")
	reset_options(7, "endless_assault")
	reset_options(8, "damage_to_player")
		
	self:set_value("deathmatch", table.concat(values, "|"))
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
	local values = string.split(self:value("deathmatch"), "|")
	if values[1] == "enabled" then
		local dm = ""

		dm = dm .. managers.localization:text("dm_respawn_time") .. ":\n " .. self:conv("min", values[2]) .. "\n"
		
		if math.round(values[3], 0.01) ~= 0 then
			dm = dm .. managers.localization:text("dm_damage_interval") .. ":\n " .. self:conv("sec", values[3]) .. "\n"
		end
		
		dm = dm .. managers.localization:text("dm_armor_regen_speed") .. ":\n " .. self:conv("sec", values[4]) .. "\n"
		
		if math.round(values[5], 0.01) ~= 1 then
			dm = dm .. managers.localization:text("dm_movement_speed") .. ":\n " .. self:conv("per", values[5]) .. "\n"
		end
		
		if math.round(values[6], 0.01) ~= 1 then
			dm = dm .. managers.localization:text("dm_police_force") .. ":\n " .. self:conv("per", values[6]) .. "\n"
		end
		
		if math.round(values[8], 0.01) ~= 1 then
			dm = dm .. managers.localization:text("dm_damage_on_players") .. ":\n " .. self:conv("per", math.round(self:value("damage_multiplier"), 0.01)) .. "\n"
		end

		if values[7] == "on" then
			dm = dm .. managers.localization:text("dm_endless_assault") .. ":\n -" .. managers.localization:text("dm_endless_assault_desc") .. "\n"
		end
		
		return dm
	else
		return name
	end
end

local data = MutatorFriendlyFire.setup_options_gui
function MutatorFriendlyFire:setup_options_gui(node)
	local function add_slider(index, name, step, min, max, round)
		local params = {
			name = name,
			callback = "_update_mutator_value",
			text_id = "dm_" .. name,
			update_callback = function(item)
				local values = string.split(self:value("deathmatch"), "|")
				values[index] = math.round(item:value(), round)
				self:set_value("deathmatch", table.concat(values, "|"))
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

		local values = string.split(self:value("deathmatch"), "|")
		new_item:set_value(values[index])
		node:add_item(new_item)
	end
	
	local function add_toggle(index, name)
		local params = {
			name = name,
			callback = "_update_mutator_value",
			text_id = "dm_" .. name,
			update_callback = function(item)
				local values = string.split(self:value("deathmatch"), "|")
				values[index] = item:value()
				self:set_value("deathmatch", table.concat(values, "|"))
			end
		}
		local data_node = {
			{ w = 24, y = 0, h = 24, s_y = 24, value = "on", s_w = 24, s_h = 24, s_x = 24, _meta = "option", icon = "guis/textures/menu_tickbox", x = 24, s_icon = "guis/textures/menu_tickbox"},
			{ w = 24, y = 0, h = 24, s_y = 24, value = "off", s_w = 24, s_h = 24, s_x = 0, _meta = "option", icon = "guis/textures/menu_tickbox", x = 0, s_icon = "guis/textures/menu_tickbox"},
			type = "CoreMenuItemToggle.ItemToggle"
		}
		local new_item = node:create_item(data_node, params)

		local values = string.split(self:value("deathmatch"), "|")
		new_item:set_value(values[index])
		node:add_item(new_item)
	end
	
	if string.find(self:value("deathmatch"), "enabled") then
		add_slider(2, "respawn_time", 1, 0, 120, 1)
		add_slider(3, "damage_interval", 0.01, 0, 1, 0.01)
		add_slider(4, "armor_regen_speed", 1, 1, 12, 0.01)
		add_slider(5, "movement_speed", 0.05, 0.5, 2, 0.01)
		add_slider(6, "police_force", 0.05, 0, 5, 0.01)
		add_toggle(7, "endless_assault")
		
		local slider = node:item("ff_damage_slider")
		if slider then
			slider:set_value(values[8])
		end
		
		node:parameters().scene_state = "blackmarket"
	end
	
	return data(self, node)
end

Hooks:PostHook(MutatorFriendlyFire, 'modify_value', 'PD2DMModifyValues', function(self, id, value)
	local values = string.split(self:value("deathmatch"), "|")
	if values[1] == "enabled" then
		if id == "HuskPlayerDamage:FriendlyFireDamage" then
			return value * values[8]
		end
	end
end)

Hooks:PostHook(MutatorFriendlyFire, '_update_damage_multiplier', 'PD2DMModifyDamageToPlayers', function(self, item)
	local values = string.split(self:value("deathmatch"), "|")
	values[8] = math.round(item:value(), 0.01)
	self:set_value("deathmatch", table.concat(values, "|"))
end)

function MutatorFriendlyFire:on_game_started(mutator_manager)
	if not string.find(self:value("deathmatch"), "enabled") then
		return
	end
	
	local values = string.split(self:value("deathmatch"), "|")
	local group = tweak_data.group_ai
	local force = group.besiege.assault.force_balance_mul
	
	ElementDialogue._can_play = function() end
	ObjectivesManager.activate_objective = function() end
	HUDManager.add_waypoint = function() end
	HUDSuspicion.show = function() end
	SecurityCamera._set_suspicion_sound = function() end
	ElementMissionEnd.on_executed = function() end
	TradeManager._announce_spawn = function() end
	
	IngameWaitingForRespawnState.trade_death = function()
		managers.dialog:queue_narrator_dialog("h51", {})
	end
	
	Hooks:PostHook(SecurityCamera, "_sound_the_alarm", "PD2DMAlarmBeepRemoval", function(self, ...)
		if managers.menu:is_deathmatch_mode() then
			self._alarm_sound = self._unit:sound_source():post_event("camera_silent")
		end
	end)
	
	Hooks:PostHook(HUDManager, 'align_teammate_name_label', 'PD2DMRemoveNameLables', function(self, panel, ...)
		panel:set_size(0, 0)
	end)
	
	for i, panels in ipairs(managers.hud._teammate_panels) do
		panels:panel():child("player"):child("revive_panel"):hide()
		panels:panel():child("callsign"):show()
		panels:panel():child("callsign_bg"):show()
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
		
		value = value * values[5]
		
		return value
	end
	
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
	
	if values[6] ~= 1 then
		for i = 1, 4 do
			force[i] = force[i] * values[6]
		end
	end
	
	if values[7] == "on" then
		managers.groupai:add_event_listener({}, "start_assault", function()
			managers.groupai:state():set_wave_mode("hunt")
		end)
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
	player.damage.automatic_respawn_time = values[2]
	player.damage.MIN_DAMAGE_INTERVAL = values[3]
	player.damage.REGENERATE_TIME = values[4]
	player.damage.DOWNED_TIME = 0
	player.damage.LIVES_INIT = 0
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
end