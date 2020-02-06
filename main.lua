local LEDsController = require "lib.LEDsController.LEDsController"
local loveframes = require("lib.loveframes")

local frame_animation = require("frame.animation")
local frame_network_scan = require("frame.network_scan")
local frame_pixel_map = require("frame.pixel_map")
local frame_network_map = require("frame.network_map")
local frame_music = require("frame.music")
local frame_player = require("frame.player")


local timer = 0
local fps = 30
local counter = 0

time = 0

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

	lx, ly = 40, 20
	controller = LEDsController:new(lx*ly, "artnet", "10.80.1.18")
	controller:loadMap(json.decode(love.filesystem.read("map/map_20x20_bis.json")))
	controller.rgbw = true
	controller.leds_by_uni = 100


	-- lx, ly = 64, 8
	-- controller = LEDsController:new(lx*ly, "artnet", "192.168.1.210")--"10.80.1.18")
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
	shader_nb = 1

	local list = love.filesystem.getDirectoryItems("shader/")
	print("Compile shader:")
	for k,v in ipairs(list) do
		print("    "..v)
		shaders[k] = {}
		shaders[k].shader = love.graphics.newShader("shader/"..v)
		shaders[k].name = v
	end

	-- for k,v in pairs(loveframes.skins) do print(k,v) end

	loveframes.SetActiveSkin("Orange")
	-- loveframes.SetActiveSkin("Default red")

	frame_animation:load(loveframes, lx, ly)
	node_list = frame_network_scan:load(loveframes)
	frame_pixel_map:load(loveframes)
	frame_network_map:load(loveframes)
	frame_music:load(loveframes)
	frame_player:load(loveframes)
	print(node_list)



	-- local frame5 = loveframes.Create("frame")
	-- frame5:SetName("Pixel Map 2")
	-- -- frame5:SetSize(300, 715)
	-- frame5:SetSize(890, 715)
	-- frame5:SetPos(0, 300)
	--
	-- local map = loveframes.Create("columnlist", frame5)
	-- map:SetPos(5, 30)
	-- map:SetSize(frame5:GetWidth()-10, frame5:GetHeight()-30-5)
	-- map:SetDefaultColumnWidth(60)


	-- local id = 1
	-- for x=1, #controller.map do
	-- 	map:AddColumn(x)
	-- end
	--
	-- for y=1, #controller.map[1] do
	-- 	local t= {}
	-- 	for x=1, #controller.map do
	-- 		local m = controller.map[x][y]
	-- 		if m then
	-- 			-- local ur,ug,ub = hslToRgb(m.uni/5,1,0.4)
	-- 			-- local ir,ig,ib = hslToRgb(m.id/100,1,0.0)
	-- 			-- local text = {
	-- 			-- 	{color = {ur, ug, ub}},
	-- 			-- 	"Uni:"..m.uni,
	-- 			-- 	{color = {ir, ig, ib}},
	-- 			-- 	"\nID:"..m.id,
	-- 			-- }
	-- 			-- local text1 = loveframes.Create("text")
	-- 			--
	-- 			-- print(x,y)
	-- 			-- map:AddItem(text1, y, x)
	-- 			table.insert(t, "Uni:"..m.uni..", Id:"..m.uni)
	-- 		end
	-- 	end
	--
	-- 	map:AddRow(unpack(t))
	-- end


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
end

function love.update(dt)
	timer = timer + dt
	time = time + dt
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
	end

	local data, ip, port = controller.udp:receivefrom()
	if data then
		local type, info = controller:receiveArtnet(data, ip, port)
		if type == "reply" then
			-- for i=0,20 do
				print(info)
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
	if key == "up" and shader_nb > 1 then shader_nb = shader_nb - 1 end
	if key == "down" and shader_nb < #shaders then shader_nb = shader_nb + 1 end
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
