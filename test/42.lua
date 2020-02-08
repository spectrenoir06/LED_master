local forty_two = {}

local img = love.graphics.newImage("ressource/42_2.png")

function forty_two:update(dt)
	-- love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()
	love.graphics.draw(img, math.floor(canvas:getWidth()/2 - img:getWidth()/2), 0)
end

return forty_two
