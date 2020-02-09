local test = {}

local font = love.graphics.newFont("ressource/font/Code_8x8.ttf",16)
font:setFilter("nearest","nearest")


function test:update(dt, lx, ly)
	love.graphics.setFont(font)
	love.graphics.clear(0,0,0,1)
	love.graphics.setLineStyle("rough")
	-- for x=0,3 do
	-- 	for y=0,1 do
	-- 		local r,g,b = hslToRgb((x+y*4)/8,1,0.2)
	-- 		love.graphics.setColor(r,g,b)
	-- 		love.graphics.rectangle("fill", x*10, y*10, 10, 10)
	--
	-- 		love.graphics.setColor(1,1,1)
	-- 		love.graphics.print(x+y*4, x*10+1, y*10)
	-- 	end
	-- end
	love.graphics.print("0",1,1)
	love.graphics.line(10,10, 40,20)
end

return test
