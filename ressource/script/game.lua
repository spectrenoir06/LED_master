local pokemon = {}

local img = love.graphics.newImage("ressource/image/game.png")
local x = 0
function pokemon:update(dt, lx, ly)
	-- local k = ly / img:getHeight()
	local k = 1
	local y = ly/2 - img:getHeight()/2
	x = x - dt * 10
	-- love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(img, math.floor(x)%img:getWidth(), y, 0, k, k)
	love.graphics.draw(img,  math.floor(x)%img:getWidth()-img:getWidth(), y, 0, k, k)
end

return pokemon
