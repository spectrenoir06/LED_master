local counter = {}

local font = love.graphics.newFont("ressource/Code_8x8.ttf",8)
font:setFilter("nearest","nearest")

local ctn = 0

function counter:update(dt, lx, ly)
	love.graphics.setFont(font)
	love.graphics.clear(0,0,0,1)
	love.graphics.print(math.floor(ctn), 1, ly/4)
	ctn = ctn + dt * 100
end

return counter
