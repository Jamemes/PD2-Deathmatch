MutatorFriendlyFire.default = "disabled|5|0|6|1|1|off"

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
		
	self:set_value("deathmatch", table.concat(values, "|"))
end)

function MutatorFriendlyFire:name()
	local name = MutatorFriendlyFire.super.name(self)
	if self:_mutate_name("deathmatch") then
		return tostring(self:value("deathmatch"))
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
			text_id = "menu_" .. name,
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
			text_id = "menu_" .. name,
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
		
		node:parameters().scene_state = "blackmarket"
	end
	
	return data(self, node)
end

Hooks:PostHook(MutatorFriendlyFire, 'modify_value', 'PD2DMModifyValues', function(self, id, value)
	local values = string.split(self:value("deathmatch"), "|")
	if values[1] == "enabled" then
		if id == "PD2DMGetRespawnPositions" then
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
		elseif id == "PD2DMStopGameOverScreen" then
			return 10^10
		elseif id == "PD2DMRemoveTeammateContours" then
			value._unit:contour():add("teammate", nil, nil, Color.black)
		elseif id == "PD2DMRemoveDownCounter" then
			value._panel:child("player"):child("revive_panel"):hide()
			value._panel:child("callsign"):show()
			value._panel:child("callsign_bg"):show()
		elseif id == "PD2DMRemoveNameLables" then
			value:set_size(0, 0)
		elseif id == "PD2DMRespawnAnnouncement" then
			return "true"
		elseif id == "PD2DMMovementSpeed" then
			return value * values[5]
		elseif id == "HuskPlayerDamage:FriendlyFireDamage" then
			return value * self:get_friendly_fire_damage_multiplier()
		end
	end
end)

function MutatorFriendlyFire:on_game_started(mutator_manager)
	if not string.find(self:value("deathmatch"), "enabled") then
		return
	end
	
	local values = string.split(self:value("deathmatch"), "|")
	local group = tweak_data.group_ai
	local force = group.besiege.assault.force_balance_mul
	
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