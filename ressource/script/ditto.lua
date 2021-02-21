require "color"
local ditto = {}

local img = love.graphics.newImage("ressource/image/ditto.png")

local quads = {}
for x=0, 3 do
	table.insert(quads, love.graphics.newQuad(x*33, 0, 33, img:getHeight(), img:getDimensions()))
end
local x = 0

function ditto:update(dt, lx, ly)
	-- local kx = lx / (img:getWidth()/5)
	local ky = ly / (img:getHeight())
	x = x + dt * 10
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()

	
	local nbx = math.ceil(lx / 33)-1
	for i=0, nbx+1 do
		local r,g,b = hslToRgb((x/20+0.20)%1, 1, 0.8)
		love.graphics.setColor(r, g, b)
		love.graphics.draw(
			img,
			quads[(math.floor(x+i)%(#quads))+1],
			(x*2 + i*33)%(((math.ceil(lx/33)+1)*33))-33,--lx/2 - img:getWidth()/5*ky/2,
			0,
			0,
			ky,
			ky
		)
	end
	-- love.graphics.draw(img, math.floor(x)%img:getWidth(), y, 0, k, k)
	-- love.graphics.draw(img, math.floor(x)%img:getWidth()-img:getWidth(), y, 0, k, k)
end

return ditto
