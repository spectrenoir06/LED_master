local pong = {}

pong.players = {
	{
		x = 1,
		y = 0,
		lx = 1,
		ly = 6,
		color = {0,0,1}
	},
	{
		x = 1,
		y = 0,
		lx = 1,
		ly = 6,
		color = {1,0,0}
	}
}

pong.ball = {
	x = 0,
	y = 0,
	dx = 0.1,
	dy = 0.1,
	color = {1,1,1}
}

function pong:reset(lx,ly)
	self.players[1].ly = 1+math.floor(ly*0.2)
	self.players[1].x = 1
	self.players[1].y = ly / 2 - self.players[1].ly/2

	self.players[2].ly = 1+math.floor(ly*0.2)
	self.players[2].x = lx-2
	self.players[2].y = ly / 2 - self.players[2].ly/2

	self.ball.x = lx/2
	self.ball.y = ly/2
end

function pong:update(dt, lx, ly)
	if not self.init or love.keyboard.isDown("space") then
		self:reset(lx,ly)
		self.init = true
	end

	love.graphics.clear(0,0,0,1)

	-- love.graphics.setColor(0.7, 0.7, 0.7)
	-- love.graphics.setShader(shaders[shader_nb].shader)
	-- 	love.graphics.draw(canvas_test,0,0)
	-- love.graphics.setShader()

	self.ball.x = self.ball.x + self.ball.dx
	self.ball.y = self.ball.y + self.ball.dy

	if love.keyboard.isDown("w") and self.players[1].y > 0 then
		self.players[1].y = self.players[1].y - 1
	elseif love.keyboard.isDown("s") and self.players[1].y + self.players[1].ly < ly then
		self.players[1].y = self.players[1].y + 1
	end

	if self.ball.y < 0 then
		self.ball.y = 0
		self.ball.dy = -self.ball.dy
	elseif self.ball.y >= ly-1 then
		self.ball.y = ly-1
		self.ball.dy = -self.ball.dy
	end

	if self.ball.x < 0 then
		self.ball.x = 0
		self.ball.dx = -self.ball.dx
	elseif self.ball.x >= lx-1 then
		self.ball.x = lx-1
		self.ball.dx = -self.ball.dx
	end

	-- if self.ball.x < 0 then
	-- 	self.ball.x = 0
	-- 	self.ball.dx = -self.ball.dx


	love.graphics.setColor(self.ball.color)
	love.graphics.rectangle("fill", (self.ball.x), (self.ball.y), 1, 1)

	love.graphics.setColor(self.players[1].color)
	love.graphics.rectangle("fill", self.players[1].x, self.players[1].y, self.players[1].lx, self.players[1].ly)

	love.graphics.setColor(self.players[2].color)
	love.graphics.rectangle("fill", self.players[2].x, self.players[2].y, self.players[2].lx, self.players[2].ly)
end

return pong
