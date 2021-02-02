local parrot = {}

local img = love.graphics.newImage("ressource/image/parrot.png")

local quads = {}
for y=0, 3 do
	for x=0, 4 do
		table.insert(quads, love.graphics.newQuad( x*128, y*128, 128, 128, img:getDimensions() ))
	end
end
local x = 0

function parrot:update(dt, lx, ly)
	local k = ly / 128
	x = x + dt * 20
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(img, quads[(math.floor(x)%(#quads))+1], 0, 0, 0,  k, k)
	-- love.graphics.draw(img, math.floor(x)%img:getWidth(), y, 0, k, k)
	-- love.graphics.draw(img,  math.floor(x)%img:getWidth()-img:getWidth(), y, 0, k, k)
end

return parrot
