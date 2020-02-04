local LEDsController = require "lib.LEDsController.LEDsController"
local loveframes = require("lib.loveframes")


local timer = 0
local fps = 30
local counter = 0

local time = 0

local lx = 64
local ly = 8

local json = require "lib.json"

function rgb(r,g,b)
	return r/255,g/255,b/255
end


function hslToRgb(h, s, l, a)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		function hue2rgb(p, q, t)
			if t < 0   then t = t + 1 end
			if t > 1   then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local q
		if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
		local p = 2 * l - q

		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	return r, g, b, a
end


function love.load(arg)
	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")
	font = love.graphics.setNewFont(10)
	love.graphics.setFont(font)

	poke = love.graphics.newImage("ressource/antoine.png")

	controller = LEDsController:new(lx*ly, "RGB888", "192.168.1.210")--"10.80.1.18")
	controller:loadMap(json.decode(love.filesystem.read("map/map_hat_bis.json")))
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

	for k,v in pairs(loveframes.skins) do print(k,v) end

	-- loveframes.SetActiveSkin("Orange")
	loveframes.SetActiveSkin("Default red")

	local frame = loveframes.Create("frame")
	frame:SetName("Animation")
	frame:SetSize(40*10, 20*10)
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

	local frame3 = loveframes.Create("frame")
	frame3:SetName("Network Map")
	frame3:SetSize(600, 250)
	frame3:SetPos(0, 600)

	network_map = loveframes.Create("columnlist", frame3)
	network_map:SetPos(5, 30)
	network_map:SetSize(frame3:GetWidth()-10, frame3:GetHeight()-30-5)
	network_map:AddColumn("net")
	network_map:AddColumn("subnet")
	network_map:AddColumn("ip")
	network_map:AddColumn("port")
	network_map:AddColumn("Sync")
	network_map:AddColumn("On")

	for i=0,8 do
		print(info)
		network_map:AddRow(
			0,
			i,
			"192.168.1."..i,
			6454,
			"False",
			"True"
		)
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
		-- controller:send(1/fps, true)
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
