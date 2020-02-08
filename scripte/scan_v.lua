local scan_v = {}

local y = 0

function scan_v:update(dt, lx, ly)
	y = y + dt * 10
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", 0, y%ly, lx, 1)
end

return scan_v
