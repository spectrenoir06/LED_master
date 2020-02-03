local LEDsController = require "lib.LEDsController.LEDsController"

local timer = 0
local fps = 40
local counter = 0

local time = 0

local lx = 40
local ly = 20

local json = require "lib.json"

function rgb(r,g,b)
	return r/255,g/255,b/255
end


function love.load(arg)
	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")
	font = love.graphics.setNewFont(10)
	love.graphics.setFont(font)

	poke = love.graphics.newImage("ressource/antoine.png")

	controller = LEDsController:new(lx*ly, "artnet", "192.168.1.210")--"10.80.1.18")
	controller:loadMap(json.decode(love.filesystem.read("map_20x20.json")))
	controller.rgbw = false
	controller.leds_by_uni = 170

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	-- controller:start_dump("BRO888")
	local ctn = 0
	-- local t = {}
	-- t.map = {}

	-- --
	-- for off_x=0,1 do
	-- 	for off_y=0,1 do
	-- 		for x=1,10,1 do
	-- 			if (x % 2 ~= 0) then
	-- 				for y=1, 10 do
	-- 					-- print(ctn,x+off_x*10,y+off_y*10)
	-- 					local c = {
	-- 						x = x+off_x*10-1,
	-- 						y = y+off_y*10-1,
	-- 						id = ctn,
	-- 						uni = off_x+off_y*2,
	-- 					}
	-- 					table.insert(t.map, c)
	-- 					ctn = ctn + 1
	-- 				end
	-- 			else
	-- 				for y=10,1,-1 do
	-- 					-- print(ctn,x+off_x*10,y+off_y*10)
	-- 					local c = {
	-- 						x = x+off_x*10-1,
	-- 						y = y+off_y*10-1,
	-- 						id = ctn%,
	-- 						uni = off_x+off_y*2,
	-- 					}
	-- 					table.insert(t.map, c)
	-- 					ctn = ctn + 1
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end	print(json.encode(t))
	--
	-- print(t[1][1])
	--
	-- for y=1,20  do
	-- 	for x=1,20 do
	-- 		-- print(x,y,t[x][y])
	-- 		io.write(t[x][y].uni.."\t")
	-- 	end
	-- 	print()
	-- end

	-- for y=1,20  do
	-- 	for x=1,20 do
	-- 		-- print(x,y,t[x][y])
	-- 		io.write(map[x][y].uni.."\t")
	-- 	end
	-- 	print()
	-- end

	shaders = {}
	shader_nb = 4

	local list = love.filesystem.getDirectoryItems("shader/")
	print("Compile shader:")
	for k,v in ipairs(list) do
		print("    "..v)
		shaders[k] = {}
		shaders[k].shader = love.graphics.newShader("shader/"..v)
		shaders[k].name = v
	end

end

function love.joystickpressed( joystick, button )
	print( joystick, button)

end

function love.draw()
	-- love.graphics.setShader(shaders[shader_nb].shader)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas,0,0,0,12,12);
	-- love.graphics.setShader()
end

function love.update(dt)
	if timer > 1 / fps then

		canvas:renderTo(function()
		love.graphics.clear()

		local s = 4
		--
		-- for i=0,64,s*3 do
		-- 	love.graphics.setColor(0,0,0.5)
		-- 	love.graphics.rectangle("fill", (0+i+counter/5)%64, 0, s, 64)
		--
		-- 	love.graphics.setColor(0.2,0.2,0.2)
		-- 	love.graphics.rectangle("fill", (0+i+s+counter/5)%64, 0, s, 64)
		--
		-- 	love.graphics.setColor(0.5,0,0)
		-- 	love.graphics.rectangle("fill", (0+i+s*2+counter/5)%64, 0, s, 64)
		-- end
		--
		-- local c = color_wheel(counter)
		-- love.graphics.setColor(c[1]/255, c[2]/255, c[3]/255)
		--
		-- love.graphics.rectangle("line", 0, 0, 64, 8)
		--
		love.graphics.setColor(1,1,1)
		-- love.graphics.print(counter,0,-2)
		-- print(shaders[2].shader)

		-- love.graphics.setColor(1,0,0)
		-- love.graphics.rectangle("fill", 0, 0, 10, 10)
		--
		-- love.graphics.setColor(0,1,0)
		-- love.graphics.rectangle("fill", 10, 0, 10, 10)
		--
		-- love.graphics.setColor(1,0,1)
		-- love.graphics.rectangle("fill", 0, 10, 10, 10)
		--
		-- love.graphics.setColor(1,1,0)
		-- love.graphics.rectangle("fill", 10, 10, 10, 10)

		love.graphics.setShader(shaders[shader_nb].shader)
			love.graphics.draw(canvas_test,0,0)
		love.graphics.setShader()

		love.graphics.setColor(1,1,1,1)

		-- love.graphics.push()
		-- 	love.graphics.translate(10,10)
		-- 	love.graphics.rotate(time*2)
		--
		-- 	love.graphics.rectangle("fill", -5, -5, 10, 10)
		--
		-- love.graphics.pop()

		-- love.graphics.rectangle("line", 1, 1, 19, 19)
		--
		--
		-- love.graphics.print("Spectre",(counter/10)%128-64,-3)


		-- love.graphics.draw(poke, -math.floor(counter/5), 0)
		-- love.graphics.draw(poke, -math.floor(counter/5)+poke:getWidth(), 0)

		-- love.graphics.print("Hello", counter, 0)

		end)

		local data = canvas:newImageData()
		local ctn = 1
		local leds = controller.leds
		for x=0,canvas:getWidth()-1,1 do
			for y=0,canvas:getHeight()-1,1 do
				local r,g,b = data:getPixel(x, y)
				controller:setArtnetLED(x, y, {r*255, g*255, b*255})
				-- print(x, y, m.id)
			end
		end
		-- for j=0,3 do
		-- 	for i=0,100-1 do
		-- 		local c = color_wheel(j*(256/5)+ctn)
		-- 		controller.leds[i+1+j*100] = {c[1], c[2], c[3], 0}
		-- 	end
		-- end
		controller:send(1/fps, true)
		-- controller:dump()
		counter = counter + 1
		if counter > poke:getWidth() then
			-- love.event.quit()
		end
		timer = 0
	end
	timer = timer + dt
	time = time + dt

	if shaders[shader_nb] then
		if shaders[shader_nb].shader:hasUniform('iResolution') then
			shaders[shader_nb].shader:send('iResolution', { lx, ly, 1 })
		end
		if shaders[shader_nb].shader:hasUniform('iTime') then
			shaders[shader_nb].shader:send('iTime', time)
		end
		if shaders[shader_nb].shader:hasUniform('iMouse') then
			local lx, ly = love.graphics.getDimensions()
			shaders[shader_nb].shader:send('iMouse', { lx/love.mouse.getX(), ly/love.mouse.getY()})
		end
	end

end

function love.keypressed( key, scancode, isrepeat )
	if key == "up" and shader_nb > 1 then shader_nb = shader_nb - 1 end
	if key == "down" and shader_nb < #shaders then shader_nb = shader_nb + 1 end
end
