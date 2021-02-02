local pokemon = {}

local img = love.graphics.newImage("ressource/image/pokemon32.png")
local x = 0

local next_time = 0
local timer = 0
local y = 0
function pokemon:update(dt, lx, ly)
	-- local k = ly / img:getHeight()
	local k = 1

	timer = timer + dt

	if timer > 0.1 then
		if y == 0 then
			y = -32
		else
			y = 0
		end
		timer = 0
		-- print("Hello")
	end
	x = x - dt * 50
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(img, math.floor(x)%img:getWidth(), y, 0, k, k)
	love.graphics.draw(img, math.floor(x)%img:getWidth()-img:getWidth(), y, 0, k, k)
end

return pokemon
