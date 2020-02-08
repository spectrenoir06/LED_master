local scan_h = {}

local x = 0

function scan_h:update(dt)
	x = x + dt * 10
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", x%canvas:getWidth(), 0, 1, canvas:getHeight())
end

return scan_h
