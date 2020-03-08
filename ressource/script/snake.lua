local snake = {}

snake.player = {
	size = 4,
	dx = -1,
	dy = 0,
	tail = {},
	color = {0,0,1}
}

snake.food = {0,0}


local font = love.graphics.newFont("ressource/font/Code_8x8.ttf", 8, "normal")
font:setFilter("nearest","nearest")

function snake:reset(lx,ly)
	self.players[1].ly = 1+math.floor(ly*0.2)
	self.players[1].x = 1
	self.players[1].y = ly / 2 - self.players[1].ly/2

	self.players[2].ly = 1+math.floor(ly*0.2)
	self.players[2].x = lx-2
	self.players[2].y = ly / 2 - self.players[2].ly/2

	self.ball.x = lx/2
	self.ball.y = ly/2
end

function snake:is_tail(p)
	for k,v in ipairs(self.player.tail) do
		if p[1] == v[1] and p[2] == v[2] then
			return true
		end
	end
	return false
end

function snake:spawn_food()
	repeat
		self.food[1] = math.random(0, lx-1)
		self.food[2] = math.random(0, ly-1)
	until (not self:is_tail(self.food))
end

function snake:reset()
	self:spawn_food()
	self.player.tail = {{lx/2, ly/2}}
	self.init = true
	self.score = false
end

local timer = 10

function snake:update(dt, lx, ly)
	timer = timer + dt

	if not self.init or (love.keyboard.isDown("w","s","a","d") and self.score) then
		self:reset()
	end

	if love.keyboard.isDown("w") and self.player.dy ~= 1 then
		self.player.dx = 0
		self.player.dy = -1
	elseif love.keyboard.isDown("s") and self.player.dy ~= -1 then
		self.player.dx = 0
		self.player.dy = 1
	elseif love.keyboard.isDown("a") and self.player.dx ~= 1 then
		self.player.dx = -1
		self.player.dy = 0
	elseif love.keyboard.isDown("d") and self.player.dx ~= -1 then
		self.player.dx = 1
		self.player.dy = 0
	end

	if timer > 0.1 and not self.score then
		timer = 0
		-- love.graphics.setColor(0.7, 0.7, 0.7)
		-- love.graphics.setShader(shaders[shader_nb].shader)
		-- 	love.graphics.draw(canvas_test,0,0)
		-- love.graphics.setShader()

		local l_pos = self.player.tail[#self.player.tail]
		local pos = {l_pos[1]+self.player.dx, l_pos[2]+self.player.dy}


		if pos[1] == self.food[1] and pos[2] == self.food[2] then
			self.player.size = self.player.size + 1
			self:spawn_food()
		end

		if self.player.size < #self.player.tail then
			table.remove(self.player.tail, 1)
		end

		if pos[1] < 0 or pos[1] > lx-1 or pos[2] < 0 or pos[2] > ly-1 or self:is_tail(pos)  then
			self.score = true
		else
			table.insert(self.player.tail, pos)
		end
	end

	love.graphics.clear(0,0,0,1)


	if self.score then
		love.graphics.setFont(font)
		local r,g,b = hslToRgb((time)%1,1,0.5)
		love.graphics.setColor(r,g,b)
		love.graphics.print(#self.player.tail-4,lx/2-font:getWidth(#self.player.tail-4)/2,5)
	else
		love.graphics.setColor(1,1,1,(math.sin(time*20)+1)/4+0.75)
		love.graphics.rectangle("fill", self.food[1], self.food[2], 1, 1)

		for k,v in ipairs(self.player.tail) do
			local r,g,b = hslToRgb((time+k/30)%1,1,0.5)
			love.graphics.setColor(r,g,b)
			love.graphics.rectangle("fill", v[1], v[2], 1, 1)
		end
	end

end

return snake
