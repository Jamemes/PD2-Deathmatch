Hooks:PostHook(HuskPlayerMovement, "set_character_anim_variables", "PD2DMRemoveTeammateContours", function(self)
	self._unit:contour():add("teammate", nil, nil, Color.black)
end)

Hooks:PostHook(HUDTeammate, 'init', 'PD2DMRemoveDownCounter', function(self)
	self._panel:child("player"):child("revive_panel"):hide()
	self._panel:child("callsign"):show()
	self._panel:child("callsign_bg"):show()
end)

function HUDManager:_update_name_labels(t, dt)
end

function TradeManager:_announce_spawn(criminal_name)
end