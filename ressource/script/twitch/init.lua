local twitch = {}
local pathOfThisFile = ...
local font = love.graphics.newFont("ressource/font/Code_8x8.ttf",8)
font:setFilter("nearest","nearest")

local ctn = 0

function twitch:update(dt, lx, ly)

	print(pathOfThisFile)
	love.graphics.setFont(font)
	love.graphics.clear(0,0,0,1)
	love.graphics.print(math.floor(ctn), 1, -1)
	ctn = ctn + dt * 100
end

return twitch
