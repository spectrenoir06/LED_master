local LEDsController = require "lib.LEDsController.LEDsController"
local loveframes = require("lib.loveframes")


local timer = 0
local fps = 30
local counter = 0

local time = 0

local lx = 20
local ly = 20

local json = require "lib.json"
require("lib/color")

function love.load(arg)
	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")
	font = love.graphics.setNewFont(14)
	love.graphics.setFont(font)

	poke = love.graphics.newImage("ressource/antoine.png")
	mario = love.graphics.newImage("ressource/mario.png")
	mario_anim = love.graphics.newImage("ressource/mario_anim.png")

	quad = {
		love.graphics.newQuad( 0, 0, 16, 20, mario_anim:getDimensions()),
		love.graphics.newQuad( 16, 0, 16, 20, mario_anim:getDimensions()),
	}

	controller = LEDsController:new(lx*ly, "artnet", "10.80.1.18")--"10.80.1.18")
	controller:loadMap(json.decode(love.filesystem.read("map/map_20x20_bis.json")))
	controller.rgbw = true
	controller.leds_by_uni = 100
	controller.debug = false

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

	-- loveframes.SetActiveSkin("Orange")
	loveframes.SetActiveSkin("Default red")

	local frame = loveframes.Create("frame")
	frame:SetName("Animation")
	frame:SetSize(20*20, 20*20)
	frame:SetResizable(true)
	frame:SetMaxWidth(800)
	frame:SetMaxHeight(600)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	local panel = loveframes.Create("panel", frame)
	panel:SetPos(4, 28)
	panel:SetSize(frame:GetWidth(), frame:GetHeight())

	panel.Draw = function(object)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(
			canvas,
			object:GetX(),
			object:GetY(),
			0,
			(object:GetWidth()-4)/lx,
			(object:GetHeight()-4)/ly
		)
	end

	panel.Update = function(object)
		object:SetSize(frame:GetWidth()-2, frame:GetHeight()-2-26)
	end

	local frame2 = loveframes.Create("frame")
	frame2:SetName("Network Discovery")
	frame2:SetSize(600, 400)
	frame2:SetPos(0, 300)
	-- frame2:SetResizable(true)

	local button = loveframes.Create("button", frame2)
	button:SetWidth(200)
	button:SetPos(5, 30)
	button:SetText("Scan network")
	-- button:Center()
	button.OnClick = function(object, x, y)
		node_list:Clear()
		controller:sendArtnetPoll()
	end

	node_list = loveframes.Create("columnlist", frame2)
	node_list:SetPos(5, 60)
	node_list:SetSize(frame2:GetWidth()-10, frame2:GetHeight()-60-5)
	node_list:AddColumn("Name")
	node_list:AddColumn("ip")
	node_list:AddColumn("port")
	node_list:AddColumn("net")
	node_list:AddColumn("subnet")
	node_list:AddColumn("nb_port")
	node_list:AddColumn("bindIndex")
	node_list:AddColumn("status")

	local frame3 = loveframes.Create("frame")
	frame3:SetName("Pixel Map")
	-- frame3:SetSize(300, 715)
	frame3:SetSize(890, 715)
	frame3:SetPos(0, 300)

	local grid = loveframes.Create("grid", frame3)
	grid:SetPos(5, 30)
	grid:SetRows(#controller.map[1])
	grid:SetColumns(#controller.map)
	grid:SetCellWidth(40)
	grid:SetCellHeight(30)
	grid:SetCellPadding(2)
	grid:SetItemAutoSize(true)

	local id = 1

	for x=1, #controller.map do
		for y=1, #controller.map[1] do
			local m = controller.map[x][y]
			if m then
				local ur,ug,ub = hslToRgb(m.uni/5,1,0.4)
				local ir,ig,ib = hslToRgb(m.id/100,1,0.0)
				local text = {
					{color = {ur, ug, ub}},
					"Uni:"..m.uni,
					{color = {ir, ig, ib}},
					"\nID:"..m.id,
				}
				local text1 = loveframes.Create("text")
				text1:SetText(text)
				grid:AddItem(text1, y, x)
			end
		end
	end

	local frame4 = loveframes.Create("frame")
	frame4:SetName("Network Map")
	frame4:SetSize(600, 250)
	frame4:SetPos(0, 600)

	network_map = loveframes.Create("columnlist", frame4)
	network_map:SetPos(5, 30)
	network_map:SetSize(frame4:GetWidth()-10, frame4:GetHeight()-30-5)
	network_map:AddColumn("net")
	network_map:AddColumn("subnet")
	network_map:AddColumn("ip")
	network_map:AddColumn("port")
	network_map:AddColumn("Sync")
	network_map:AddColumn("On")

	for i=0,8 do
		network_map:AddRow(
			0,
			i,
			"192.168.1."..i,
			6454,
			nb_port,
			bindIndex,
			"False",
			"True"
		)
	end

	local frame5 = loveframes.Create("frame")
	frame5:SetName("Pixel Map 2")
	-- frame5:SetSize(300, 715)
	frame5:SetSize(890, 715)
	frame5:SetPos(0, 300)

	local map = loveframes.Create("columnlist", frame5)
	map:SetPos(5, 30)
	map:SetSize(frame5:GetWidth()-10, frame5:GetHeight()-30-5)
	map:SetDefaultColumnWidth(60)


	local id = 1
	for x=1, #controller.map do
		map:AddColumn(x)
	end

	for y=1, #controller.map[1] do
		local t= {}
		for x=1, #controller.map do
			local m = controller.map[x][y]
			if m then
				-- local ur,ug,ub = hslToRgb(m.uni/5,1,0.4)
				-- local ir,ig,ib = hslToRgb(m.id/100,1,0.0)
				-- local text = {
				-- 	{color = {ur, ug, ub}},
				-- 	"Uni:"..m.uni,
				-- 	{color = {ir, ig, ib}},
				-- 	"\nID:"..m.id,
				-- }
				-- local text1 = loveframes.Create("text")
				--
				-- print(x,y)
				-- map:AddItem(text1, y, x)
				table.insert(t, "Uni:"..m.uni..", Id:"..m.uni)
			end
		end

		map:AddRow(unpack(t))
	end


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
	love.graphics.draw(bgimage, bgquad, 0, 0)
	loveframes.draw()
end

function love.update(dt)
	timer = timer + dt
	time = time + dt

	if timer > 1 / fps then

		canvas:renderTo(function()
			love.graphics.clear(0,0,0,1)

			love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.setShader(shaders[shader_nb].shader)
				love.graphics.draw(canvas_test,0,0)
			love.graphics.setShader()
			
			love.graphics.push()
				love.graphics.translate(10, 10)
				love.graphics.rotate(time*4)
				local r,g,b = hslToRgb(math.sin(time)/2+1, 1, 0.5)
				love.graphics.setColor(r,g,b,1)
				love.graphics.rectangle("fill", -6, -6, 12, 12)
			love.graphics.pop()
			-- love.graphics.print(math.floor(time), 0, 0)

			love.graphics.setColor(1,1,1)

			-- love.graphics.draw(mario,0,0)
			-- love.graphics.draw(mario_anim, quad[math.floor(time*5)%2+1] ,2,0)

			--

		end)

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
		controller:send(1/fps, false)
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
