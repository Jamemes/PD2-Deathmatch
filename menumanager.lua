Hooks:Add("LocalizationManagerPostInit", "Deathmatch_Mode_loc", function(...)
	LocalizationManager:add_localized_strings({
		deathmatch_mode = "Deathmatch!",
		deathmatch_mode_options = "Deathmatch settings",
		deathmatch_mode_options_desc = "Your lobby, your own rules!",
		menu_respawn_time = "Respawn time",
		menu_damage_interval = "Interval between taking damage",
		menu_armor_regen_speed = "Armor regeneration time",
		menu_movement_speed = "Movement speed",
		menu_police_force = "Police Force",
		menu_endless_assault = "Endless Assault",
		
		
	})
		
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			deathmatch_mode = "Поединок!",
			deathmatch_mode_options = "Настройки Поединка",
			deathmatch_mode_options_desc = "Твоё лобби, твои правила!",
			menu_respawn_time = "Время до возрождения",
			menu_damage_interval = "Интервал между получением урона",
			menu_armor_regen_speed = "Скорость регенерации брони",
			menu_movement_speed = "Скорость передвижения",
			menu_police_force = "Кол-во Полицейских",
			menu_endless_assault = "Бесконечный штурм",
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "BuildCreateEmptyLobbyMenu", function(menu_manager, nodes)
	local node = nodes.main
	if node then
		local data_node = {
			type = "CoreMenuItem.Item"
		}
		local params = {
			name = "deathmatch_mode",
			text_id = "deathmatch_mode",
			font = "fonts/font_large_mf",
			font_size = 35,
			callback = "play_deathmatch_mode",
			next_node = "crimenet"
		}
		local new_item = node:create_item(data_node, params)
		
		new_item.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			new_item:set_callback_handler(node.callback_handler)
		end
		
		local pos = 0
		for id, item in pairs(node._items) do
			if item:name() == "divider_dlc_buy_pc" then
				pos = id
			end
		end
		
		table.insert(node._items, pos + 1, new_item)
	end
	
	local node = nodes.lobby
	if node then
		local data_node = {
			type = "CoreMenuItem.Item"
		}
		local params = {
			name = "deathmatch_mode_options",
			text_id = "deathmatch_mode_options",
			help_id = "deathmatch_mode_options_desc",
			font = "fonts/font_large_mf",
			font_size = 30,
			visible_callback = "is_deathmatch_mode",
			callback = "open_deathmatch_options"
		}
		local new_item = node:create_item(data_node, params)
		
		new_item.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			new_item:set_callback_handler(node.callback_handler)
		end
		
		local pos = 0
		for id, item in pairs(node._items) do
			if item:name() == "edit_game_settings" then
				pos = id
			end
		end
		
		table.insert(node._items, pos, new_item)
	end
end)

function MenuCallbackHandler:is_deathmatch_mode()
	return managers.menu:is_deathmatch_mode()
end

function MenuCallbackHandler:is_not_deathmatch_mode()
	return not managers.menu:is_deathmatch_mode()
end

function MenuManager:is_deathmatch_mode()
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	return string.find(mutator:value("deathmatch"), "enabled")
end

local data = MenuCallbackHandler.save_mutator_options
function MenuCallbackHandler:save_mutator_options(item)
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	
	if managers.menu:is_deathmatch_mode() then
		if mutator then
			managers.mutators:set_enabled(mutator, true)
		end

		managers.menu:back()
		self:_update_mutators_info()
		
		return
	end
	
	data(self, item)
end

function MenuCallbackHandler:open_deathmatch_options()
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	managers.menu:open_node("mutators_options", {mutator})
end

function MenuCallbackHandler:play_deathmatch_mode()
	if managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
		Global.game_settings.search_mutated_lobbies = true
		Global.game_settings.search_event_lobbies_override = true
		Global.game_settings.gamemode_filter = GamemodeStandard.id
	end

	-- managers.features:announce_feature("cg22_event_explanation")
	-- managers.mission:set_saved_job_value("cg22_participation", true)
	
	for _, mutator in ipairs(managers.mutators:mutators()) do
		managers.mutators:set_enabled(mutator, false)
	end
	
	local function size(str, val)
		return table.size(string.split(str, "|"))
	end
	
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	managers.mutators:set_enabled(mutator, true)
	
	if size(mutator:value("deathmatch")) ~= size(mutator.default) then
		mutator:clear_values()
	end

	local values = string.split(mutator:value("deathmatch"), "|")
	values[1] = "enabled"
	mutator:set_value("deathmatch", table.concat(values, "|"))
	
	managers.menu:active_menu().callback_handler:_update_mutators_info()
end

function MenuCallbackHandler:play_deathmatch_mode()
	if managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
		Global.game_settings.search_mutated_lobbies = true
		Global.game_settings.gamemode_filter = GamemodeStandard.id
	end

	-- managers.features:announce_feature("cg22_event_explanation")
	-- managers.mission:set_saved_job_value("cg22_participation", true)
	
	for _, mutator in ipairs(managers.mutators:mutators()) do
		managers.mutators:set_enabled(mutator, false)
	end
	
	local function size(str, val)
		return table.size(string.split(str, "|"))
	end
	
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	managers.mutators:set_enabled(mutator, true)
	
	if size(mutator:value("deathmatch")) ~= size(mutator.default) then
		mutator:clear_values()
	end

	local values = string.split(mutator:value("deathmatch"), "|")
	values[1] = "enabled"
	mutator:set_value("deathmatch", table.concat(values, "|"))
	
	managers.menu:active_menu().callback_handler:_update_mutators_info()
end

local function reset_dm()
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	if mutator:value("deathmatch") then
		local values = string.split(mutator:value("deathmatch"), "|")
		values[1] = "disabled"
		mutator:set_value("deathmatch", table.concat(values, "|"))
		
		managers.mutators:set_enabled(mutator, false)
		managers.menu:active_menu().callback_handler:_update_mutators_info()
	end
end

Hooks:PostHook(MenuCallbackHandler, 'on_leave_lobby', 'PD2DMResetDMM', function(self, ...)
	reset_dm()
end)

Hooks:PostHook(MenuCallbackHandler, 'play_single_player', 'PD2DMResetDMM2', function(self, ...)
	reset_dm()
end)

Hooks:PostHook(MenuCallbackHandler, 'play_online_game', 'PD2DMResetDMM2', function(self, ...)
	if not Network:is_server() then
		reset_dm()
	end
end)

local data = CrimeNetSidebarGui._setup
function CrimeNetSidebarGui:_setup()
	if managers.menu:is_deathmatch_mode() then
		tweak_data.old_sidebar = tweak_data.gui.crime_net.sidebar
		
		local exclude_list = {
			"menu_cn_quickplay",
			"menu_cn_short",
			"menu_cn_chill",
			"menu_cn_casino",
			"menu_mutators",
			"cn_crime_spree",
			"menu_cn_skirmish"
		}
		local sidebar_filtered = {}

		for i, item in ipairs(tweak_data.gui.crime_net.sidebar) do
			if not table.contains(exclude_list, item.name_id) then
				table.insert(sidebar_filtered, item)
			end
		end
		
		tweak_data.gui.crime_net.sidebar = sidebar_filtered
	end
	
	data(self)
	
	if managers.menu:is_deathmatch_mode() then
		tweak_data.gui.crime_net.sidebar = tweak_data.old_sidebar
	end
end