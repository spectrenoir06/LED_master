local LEDsController = require "lib.LEDsController.LEDsController"
require("lib.LoveFrames")


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
	controller:loadMap(json.decode(love.filesystem.read("map/map_20x20.json")))
	controller.rgbw = false
	controller.leds_by_uni = 170

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	-- controller:start_dump("BRO888")

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
	timer = timer + dt
	time = time + dt

	if timer > 1 / fps then

		canvas:renderTo(function()
			love.graphics.clear()

			love.graphics.setShader(shaders[shader_nb].shader)
				love.graphics.draw(canvas_test,0,0)
			love.graphics.setShader()

			love.graphics.setColor(1,1,1,1)
		end)

		local data = canvas:newImageData()
		local ctn = 1
		local leds = controller.leds
		for x=0,canvas:getWidth()-1,1 do
			for y=0,canvas:getHeight()-1,1 do
				local r,g,b = data:getPixel(x, y)
				controller:setArtnetLED(x, y, {r*255, g*255, b*255})
			end
		end
		controller:send(1/fps, true)
	end

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
