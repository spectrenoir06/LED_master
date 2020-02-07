love.filesystem.setRequirePath("?.lua;?/init.lua;lib/?.lua")


local LEDsController = require "lib.LEDsController"
local loveframes = require("lib.loveframes")

local frame_animation = require("frame.animation")
local frame_network_scan = require("frame.network_scan")
local frame_pixel_map = require("frame.pixel_map")
-- local frame_network_map = require("frame.network_map")
local frame_player = require("frame.player")


local timer = 0
local fps = 30
local counter = 0

local time = 0

local json = require "lib.json"
require("lib/color")

function love.load(arg)
	font = love.graphics.setNewFont(14)
	love.graphics.setFont(font)

	poke = love.graphics.newImage("ressource/antoine.png")
	mario = love.graphics.newImage("ressource/mario.png")
	mario_anim = love.graphics.newImage("ressource/mario_anim.png")

	quad = {
		love.graphics.newQuad( 0, 0, 16, 20, mario_anim:getDimensions()),
		love.graphics.newQuad( 16, 0, 16, 20, mario_anim:getDimensions()),
	}

	lx, ly = 20, 20
	controller = LEDsController:new(lx*ly, "artnet", "10.80.1.18")
	controller:loadMap(json.decode(love.filesystem.read("map/map_20x20.json")))
	controller.rgbw = true
	controller.leds_by_uni = 100


	-- lx, ly = 64, 8
	-- lx, ly = 64, 64
	-- controller = LEDsController:new(lx*ly, "artnet")--"10.80.1.18")
	-- controller:loadMap(json.decode(love.filesystem.read("map/map_hat_bis.json")))
	-- controller.rgbw = false
	-- controller.leds_by_uni = 170


	controller.debug = false


	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	-- controller:start_dump("BRO888")

	shaders = {}
	shaders_param = {
		speed = 1,
		density = 1
	}
	shader_nb = 1

	local list = love.filesystem.getDirectoryItems("shader/")
	print("Compile shader:")
	for k,v in ipairs(list) do
		print("    "..v)
		shaders[k] = {}
		shaders[k].shader = love.graphics.newShader("shader/"..v)
		shaders[k].name = v
	end

	for k,v in pairs(loveframes.skins) do print(k,v) end

	-- loveframes.SetActiveSkin("Orange")
	-- loveframes.SetActiveSkin("Blue")
	loveframes.SetActiveSkin("Default blue")
	-- loveframes.SetActiveSkin("Dark red")

	frame_animation:load(loveframes, lx, ly)
	node_list = frame_network_scan:load(loveframes)
	frame_pixel_map:load(loveframes)
	-- frame_network_map:load(loveframes)
	frame_player:load(loveframes)
	print(node_list)


	local image = love.graphics.newImage("ressource/bg.png")
	image:setWrap("repeat", "repeat")
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	bgquad = love.graphics.newQuad(0, 0, width, height, image:getWidth(), image:getHeight())
	bgimage = image
end

function love.joystickpressed( joystick, button )
	print(joystick, button)

end

function love.draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(bgimage, bgquad, 0, 0)
	loveframes.draw()
	-- love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.update(dt)
	timer = timer + dt
	time = time + (dt * shaders_param.speed)
	-- print(1/dt)

	if timer > 1 / fps then

		local data = canvas:newImageData()
		local ctn = 1
		local leds = controller.leds
		for x=0,canvas:getWidth()-1,1 do
			for y=0,canvas:getHeight()-1,1 do
				local r,g,b = data:getPixel(x, y)
				-- local w = (math.max(r,g,b) + math.min(r,g,b)) / 2
				-- local w = math.min(r,g,b)
				-- r,g,b = r-w, g-w, b-w
				local w = 0

				controller:setArtnetLED(x, y, {r*255, g*255, b*255, w*255})
			end
		end

		controller:send(0, false)
		timer = 0
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
		for k,v in pairs(shaders_param) do
			if shaders[shader_nb].shader:hasUniform(k) then
				shaders[shader_nb].shader:send(k,v)
			end
		end
	end

	local data, ip, port = controller.udp:receivefrom()
	if data then
		local type, info = controller:receiveArtnet(data, ip, port)
		if type == "reply" then
			-- for i=0,20 do
				controller:addArtnetNode(
					info.net,
					info.subnet,
					info.ip[1].."."..info.ip[2].."."..info.ip[3].."."..info.ip[4],
					info.port,
					nb
				)
				node_list:AddRow(
					info.short_name,
					info.ip[1].."."..info.ip[2].."."..info.ip[3].."."..info.ip[4],
					info.port,
					info.net,
					info.subnet,
					info.nb_port,
					info.bindIndex,
					info.status
				)
			-- end
		end
	end
	--
	loveframes.update(dt)
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.keypressed( key, scancode, isrepeat )
	-- print(key)
	if key == "up" then
		ly = ly + 1
	elseif key == "down" and canvas:getHeight() > 1 then
		ly = ly - 1
	elseif key == "left" and canvas:getWidth() > 1 then
		lx = lx - 1
	elseif key == "right" then
		lx = lx + 1
	end
	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")
	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
	loveframes.keyreleased(key)
end

function love.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function love.resize(w, h)
	bgquad = love.graphics.newQuad(0, 0, w, h, bgimage:getWidth(), bgimage:getHeight())
end
