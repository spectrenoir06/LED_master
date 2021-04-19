local script = {}

-- local font = love.graphics.newFont("ressource/font/Code_8x8.ttf",8)
local font = love.graphics.newFont(32)

font:setFilter("nearest", "nearest")

local timer = 0
local text = "42Chips   "
local text_w = font:getWidth(text)
local text_h = font:getHeight()
print(text_h)

function script:update(dt, lx, ly)
	local k = math.max(ly / text_h, 1)
	love.graphics.clear(0, 0, 0, 1)

	local r,g,b = hslToRgb((timer)%1, 1, 0.5)
	love.graphics.setColor(r,g,b)

	love.graphics.setFont(font)

	timer = timer + dt
	-- print(text_h, k)
	local x = (-timer*15)%(text_w*k)
	for i=0, lx / (text_w*k)+1 do
		love.graphics.print(text, math.floor(x+(text_w*k)*(i-1)), 0, 0, k, k)
	end
end

return script
