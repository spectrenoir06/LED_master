local time = {}

local font = love.graphics.newFont("ressource/font/Code_8x8.ttf",8)
font:setFilter("nearest","nearest")


function time:update(dt, lx, ly)
	love.graphics.setFont(font)
	love.graphics.clear(0,0,0,1)
	love.graphics.print(os.date('%H%M') , 1, 1)
	love.graphics.print(os.date('%d%m') , 1, 10)
end

return time
