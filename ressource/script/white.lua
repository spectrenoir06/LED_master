local test = {}

local font = love.graphics.newFont("ressource/font/Code_8x8.ttf",8)
font:setFilter("nearest","nearest")

function test:update(dt, lx, ly)
	love.graphics.clear(1,1,1,1)
	-- love.graphics.rectangle("fill", 0, 0, canvas_test:getWidth(), canvas_test:getHeight())
end

return test
