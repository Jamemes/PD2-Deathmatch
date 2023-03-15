
Hooks:Add("LocalizationManagerPostInit", "CrimeNET_Enhanced_loc", function(...)
	LocalizationManager:add_localized_strings({
		pd2dm_respawn_time = "Respawn Timer - $value; sec.",
		pd2dm_damage_interval = "Interval between received damage - $value; sec.",
		pd2dm_armor_regen_speed = "Armor regeneration timer - $value; sec.",
		pd2dm_movement_speed = "Movement speed multipler - x$value;",
		pd2dm_damage_multiplier = "Damage multipler x$value;",

	})
		
	-- local rt = "\n   " .. managers.localization:text("", {value = self:value("respawn_time")})
	-- local di = "\n   " .. managers.localization:text("", {value = self:value("damage_interval")})
	-- local ar = "\n   " .. managers.localization:text("", {value = self:value("armor_regen_speed")})
	-- local ms = "\n   " .. managers.localization:text("", {value = self:value("movement_speed")})
	-- local dm = "\n   " .. managers.localization:text("", {value = self:value("damage_multiplier")})
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_steam_profile = "Steam Профиль",
		})
	end
end)

Hooks:PostHook(MutatorFriendlyFire, 'register_values', 'PD2DMRegisterValues', function(self, mutator_manager)
	self:register_value("respawn_time", 5, "rt")
	self:register_value("damage_interval", 0, "di")
	self:register_value("armor_regen_speed", 6, "ar")
	self:register_value("movement_speed", 1, "ms")
end)

Hooks:PostHook(MutatorFriendlyFire, 'reset_to_default', 'PD2DMDefault', function(self)
	local function reset_value(id, val)
		local slider = self._node:item(id)
		if slider then
			slider:set_value(val)
			self:set_value(id, val)
		end
	end
	
	reset_value("respawn_time", 5)
	reset_value("damage_interval", 0)
	reset_value("armor_regen_speed", 6)
	reset_value("movement_speed", 1)
end)

local data = MutatorFriendlyFire.setup_options_gui
function MutatorFriendlyFire:setup_options_gui(node)
	local function add_slider(name, step, min, max)
		local params = {
			name = name,
			callback = "_update_mutator_value",
			text_id = "menu_" .. name,
			update_callback = function(item)
				self:set_value(name, item:value())
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

		new_item:set_value(self:value(name))
		node:add_item(new_item)
	end
	
	add_slider("respawn_time", 1, 3, 120)
	add_slider("damage_interval", 0.01, 0, 1)
	add_slider("armor_regen_speed", 1, 1, 12)
	add_slider("movement_speed", 0.05, 0.5, 2)
	
	return data(self, node)
end

function MutatorFriendlyFire:name()
	local name = MutatorFriendlyFire.super.name(self)

	local rt = "\n   " .. managers.localization:text("pd2dm_respawn_time", {value = self:value("respawn_time")})
	local di = "\n   " .. managers.localization:text("pd2dm_damage_interval", {value = self:value("damage_interval")})
	local ar = "\n   " .. managers.localization:text("pd2dm_armor_regen_speed", {value = self:value("armor_regen_speed")})
	local ms = "\n   " .. managers.localization:text("pd2dm_movement_speed", {value = self:value("movement_speed")})
	local dm = "\n   " .. managers.localization:text("pd2dm_damage_multiplier", {value = self:value("damage_multiplier")})
	
	return name .. rt .. di .. ar .. ms .. dm
end

function MutatorFriendlyFire:on_game_started(mutator_manager)
	CriminalsManager.MAX_NR_TEAM_AI = 0
	
	local player = tweak_data.player
	player.damage.automatic_respawn_time = self:value("respawn_time")
	player.damage.MIN_DAMAGE_INTERVAL = self:value("damage_interval")
	player.damage.REGENERATE_TIME = self:value("armor_regen_speed")
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

Hooks:PostHook(MutatorFriendlyFire, 'modify_value', 'PD2DMModifyValues', function(self, id, value)
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
		return value * self:value("movement_speed")
	elseif id == "HuskPlayerDamage:FriendlyFireDamage" then
		return value * self:get_friendly_fire_damage_multiplier()
	end
end)