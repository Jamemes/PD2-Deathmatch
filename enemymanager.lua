local data = EnemyManager.add_delayed_clbk
function EnemyManager:add_delayed_clbk(id, clbk, execute_t)

	if id == "_gameover_clbk" then
		execute_t = 10^10
	end
	
	data(self, id, clbk, execute_t)
end
