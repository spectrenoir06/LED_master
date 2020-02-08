local script = {}

local font = love.graphics.newFont("ressource/Code_8x8.ttf",8)
font:setFilter("nearest","nearest")

local timer = 0
local text = "42Chips  "

function script:update(dt, lx, ly)
	love.graphics.clear(0,0,0,1)

	local r,g,b = hslToRgb((timer)%1,1,0.5)
	love.graphics.setColor(r,g,b)

	love.graphics.setFont(font)

	timer = timer + dt
	local x = (-timer*15)%font:getWidth(text)

	love.graphics.print(text, x, 5)
	love.graphics.print(text, x-font:getWidth(text), 5)

	love.graphics.rectangle("line", -1, 1, lx+2, ly-1)
end

return script
