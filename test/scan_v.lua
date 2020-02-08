local scan_v = {}

local y = 0

function scan_v:update(dt)
	y = y + dt * 10
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", 0, y%canvas:getHeight(), canvas:getWidth(), 1)
end

return scan_v
