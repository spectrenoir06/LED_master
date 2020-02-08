love.filesystem.setRequirePath("?.lua;?/init.lua;lib/?.lua")


local LEDsController = require "lib.LEDsController"
local loveframes = require("lib.loveframes")

local frame_animation = require("frame.animation")
local frame_network_scan = require("frame.network_scan")
local frame_pixel_map = require("frame.pixel_map")
-- local frame_network_map = require("frame.network_map")
local frame_player = require("frame.player")


local timer = 0
local fps = 60
local sync = false
local counter = 0

local time = 0

local json = require "lib.json"
require("lib/color")

function love.load(arg)

	local thread = love.thread.newThread("thread_led_controller.lua")


	-- fps = 60
	-- -- lx, ly = 64, 64
	-- lx, ly = 64, 8
	-- m = json.decode(love.filesystem.read("map/map_hat_bis.json"))
	-- thread:start(
	-- 	{
	-- 		led_nb = lx*ly,
	-- 		protocol = "RGB888",
	-- 		ip = "192.168.1.210",
	-- 		debug = false,
	-- 		map = m
	-- 	},
	-- 	fps,
	-- 	true
	-- )

	fps = 30
	lx, ly = 40, 20
	m = json.decode(love.filesystem.read("map/map_40x20.json"))
	thread:start(
		{
			led_nb = lx*ly,
			protocol = "artnet",
			debug = false,
			map = m
		},
		fps,
		false
	)



	map = {}
	for k,v in ipairs(m) do
		if map[v.x+1] == nil then map[v.x+1]={} end
		map[v.x+1][v.y+1] = {
			uni = v.uni,
			id = v.id
		}
	end



	canvas = love.graphics.newCanvas(lx, ly)
	canvas_test = love.graphics.newCanvas(lx, ly)
	canvas:setFilter("nearest", "nearest")

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

	-- for k,v in pairs(loveframes.skins) do print(k,v) end

	-- loveframes.SetActiveSkin("Orange")
	-- loveframes.SetActiveSkin("Blue")
	loveframes.SetActiveSkin("Default blue")
	-- loveframes.SetActiveSkin("Dark red")

	frame_animation:load(loveframes, lx, ly)
	node_list = frame_network_scan:load(loveframes)
	frame_pixel_map:load(loveframes)
	-- frame_network_map:load(loveframes)
	frame_player:load(loveframes)

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
		love.thread.getChannel('img'):push(data)
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

	local info = love.thread.getChannel('node'):pop()
	if info then
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
