local self = tweak_data.player
self.damage.automatic_respawn_time = 3
self.damage.DOWNED_TIME = 0
self.damage.LIVES_INIT = 0
self.damage.respawn_time_penalty = 0
self.damage.base_respawn_time_penalty = 0
self.damage.MIN_DAMAGE_INTERVAL = 0
self.damage.REGENERATE_TIME = 10

local self = tweak_data.timespeed
self.mask_on.sustain = 0
self.mask_on.speed = 0
self.mask_on.fade_out = 0
self.mask_on.fade_in = 0
self.mask_on.fade_in_delay = 0
self.mask_on_player.sustain = 0
self.mask_on_player.speed = 0
self.mask_on_player.fade_out = 0
self.mask_on_player.fade_in = 0
self.mask_on_player.fade_in_delay = 0
self.downed.sustain = 0
self.downed.speed = 0
self.downed.fade_out = 0
self.downed.fade_in = 0
self.downed_player.sustain = 0
self.downed_player.speed = 0
self.downed_player.fade_out = 0
self.downed_player.fade_in = 0
self.mission_effects.quickdraw.sustain = 0
self.mission_effects.quickdraw.speed = 0
self.mission_effects.quickdraw.fade_out = 0
self.mission_effects.quickdraw.fade_in = 0
self.mission_effects.quickdraw.fade_in_delay = 0
self.mission_effects.quickdraw_player.sustain = 0
self.mission_effects.quickdraw_player.speed = 0
self.mission_effects.quickdraw_player.fade_out = 0
self.mission_effects.quickdraw_player.fade_in = 0
self.mission_effects.quickdraw_player.fade_in_delay = 0

local self = tweak_data.overlay_effects
self.spectator.fade_out = 0.5
self.spectator.fade_in = 0.5
self.fade_in.fade_out = 0.5

for _, proj in pairs(tweak_data.projectiles) do
	if proj.player_damage then
		proj.player_damage = proj.damage
	end
end