Hooks:Add("MenuManagerBuildCustomMenus", "BuildCreateEmptyLobbyMenu", function(menu_manager, nodes)
	local node = nodes.main

	if node then
		local data_node = {
			type = "CoreMenuItem.Item"
		}
		local params = {
			name = "deathmatch_mode",
			text_id = "deathmatch_mode",
			help_id = "deathmatch_mode_desc",
			font = "fonts/font_large_mf",
			font_size = 35,
			index = 1,
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
end)

function MenuCallbackHandler:play_deathmatch_mode()
	if managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
		Global.game_settings.search_mutated_lobbies = true
		Global.game_settings.search_event_lobbies_override = true
		Global.game_settings.gamemode_filter = GamemodeStandard.id
	end

	managers.mutators:reset_all_mutators()
	
	-- managers.features:announce_feature("cg22_event_explanation")
	-- managers.mission:set_saved_job_value("cg22_participation", true)
	
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	managers.mutators:set_enabled(mutator, true)
	mutator:set_value("deathmatch", true)
	managers.menu:active_menu().callback_handler:_update_mutators_info()
	
	-- test.text(managers.mutators:get_mutator(MutatorFriendlyFire))
	-- test.text(MutatorFriendlyFire._type)
	
	-- managers.crimenet:set_sidebar_exclude_filter({
		-- "menu_cn_short",
		-- "menu_cn_chill",
		-- "menu_cn_casino",
		-- "menu_mutators",
		-- "cn_crime_spree",
		-- "menu_cn_skirmish"
	-- })
end

local function reset_dm()
	local mutator = managers.mutators:get_mutator(MutatorFriendlyFire)
	if mutator:value("deathmatch") then
		mutator:set_value("deathmatch", false)
		managers.mutators:set_enabled(mutator, false)
		managers.menu:active_menu().callback_handler:_update_mutators_info()
	end
end

Hooks:PostHook(MenuCallbackHandler, 'on_leave_lobby', 'PD2DMResetDMM', function(self, ...)
	reset_dm()
end)

Hooks:PostHook(MenuCallbackHandler, 'play_online_game', 'PD2DMResetDMM2', function(self, ...)
	if not Network:is_server() then
		reset_dm()
	end
end)