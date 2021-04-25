local pokemon = {}
local path = ...

function pokemon:load(lx, ly)
	self.img = love.graphics.newImage(path.."/pokemon32.png")

	self.x = 0
	self.y = 0

	self.next_time = 0
	self.timer = 0
end

function pokemon:update(dt, lx, ly)
	local k = ly / self.img:getHeight() * 2

	self.timer = self.timer + dt

	if self.timer > 0.1 then
		if y == 0 then
			y = -32 * k
		else
			y = 0
		end
		self.timer = 0
	end
	self.x = self.x - dt * 50
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setShader(shaders[shader_nb].shader)
		love.graphics.draw(canvas_test,0,0)
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.img, math.floor(self.x)%self.img:getWidth(), y, 0, k, k)
	love.graphics.draw(self.img, math.floor(self.x)%self.img:getWidth()-self.img:getWidth(), y, 0, k, k)
end

return pokemon
