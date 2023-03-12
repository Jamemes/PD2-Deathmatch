CriminalsManager.MAX_NR_TEAM_AI = 0

local data = CriminalsManager.get_valid_player_spawn_pos_rot
function CriminalsManager:get_valid_player_spawn_pos_rot(peer_id)
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
	
	return data(self, peer_id)
end
