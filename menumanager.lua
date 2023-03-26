Hooks:Add("LocalizationManagerPostInit", "Deathmatch_Mode_loc", function(...)
	LocalizationManager:add_localized_strings({
		deathmatch_mode = "Deathmatch!",
		menu_deathmatchs = "Deathmatch",
		menu_deathmatchs_lobby_wait_title = "Deathmatch",
		cn_menu_contract_deathmatchs_header = "Deathmatch Mode:",
		menu_cn_deathmatchs_active = "Deathmatch",
		deathmatch_mode_options = "Deathmatch settings",
		deathmatch_mode_options_desc = "Your lobby, your own rules!",
		dm_respawn_time = "Respawn time",
		dm_damage_interval = "Interval between taking damage",
		dm_armor_regen_speed = "Armor regeneration time",
		dm_movement_speed = "Players movement speed",
		dm_police_force = "Police Force",
		dm_endless_assault = "Endless Assault",
		dm_damage_on_players = "Damage on players",
		dm_endless_assault_desc = "No breaks between assaults.",
		player_without_dmm = " has no PD2 Deathmatch installed.",
		secs = "s.",
	})
		
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			deathmatch_mode = "Поединок!",
			menu_deathmatchs = "Поединок",
			menu_deathmatchs_lobby_wait_title = "Поединок",
			cn_menu_contract_deathmatchs_header = "Режим Поединка:",
			menu_cn_deathmatchs_active = "Поединок",
			deathmatch_mode_options = "Настройки Поединка",
			deathmatch_mode_options_desc = "Твоё лобби, твои правила!",
			dm_respawn_time = "Время до возрождения",
			dm_damage_interval = "Интервал между получением урона",
			dm_armor_regen_speed = "Скорость регенерации брони",
			dm_movement_speed = "Скорость передвижения игроков",
			dm_police_force = "Кол-во Полицейских",
			dm_endless_assault = "Бесконечный штурм",
			dm_damage_on_players = "Урон по игрокам",
			dm_endless_assault_desc = "Нет перерывов между штурмами.",
			player_without_dmm = " не имеет PD2 Deathmatch в списке модов.",
			secs = "с.",
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
	
	local function size(str)
		local _, count = string.gsub(str, "|", "")
		return count
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

local function fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end	

Hooks:PostHook(ContractBoxGui, 'create_mutators_tooltip', 'PD2DMtooltip', function(self, ...)
	if managers.menu:is_deathmatch_mode() then
		local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)

		self._mutators_tooltip:clear()
		
		local deathmatch_title = self._mutators_tooltip:text({
			y = 10,
			name = "deathmatch_title",
			x = 10,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			text = managers.localization:to_upper_text("menu_cn_deathmatchs_active"),
			h = tweak_data.menu.pd2_medium_font_size
		})
		fine_text(deathmatch_title)
	
		local w = 0
		local y = deathmatch_title:bottom()
		local presets = {
			x = 10,
			y = y,
			layer = 1,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size * 0.85
		}
		
		presets.text = mutator:name()
		local respawn_time = self._mutators_tooltip:text(presets)
		fine_text(respawn_time)
		y = y + respawn_time:h()
		w = w + respawn_time:w()

		self._mutators_tooltip:set_size(w + 16, y + 8)
		self._mutators_tooltip:rect({
			alpha = 0.8,
			layer = -1,
			color = Color.black
		})
		BoxGuiObject:new(self._mutators_tooltip, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
end)

Hooks:PostHook(CrimeNetContractGui, 'init', 'PD2DMfixdescriptionwhenjoin', function(self, ...)
	if managers.menu:is_deathmatch_mode() then
		local deathmatch = self._mutators_scroll and self._mutators_scroll:canvas() and self._mutators_scroll:canvas():child("mutator_text_1")
		if alive(deathmatch) then
			fine_text(deathmatch)
			self._mutators_scroll:update_canvas_size()
		end
	end
end)