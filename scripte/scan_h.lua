local scan_h = {}

local x = 0

function scan_h:update(dt, lx, ly)
	x = x + dt * 10
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", x%lx, 0, 1, ly)
end

return scan_h
