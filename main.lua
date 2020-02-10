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

	local os = love.system.getOS()
	if os == "Android" or  os == "iOS" then
		love.window.setMode( 411, 838, {resizable = false} )
	end


	local thread = love.thread.newThread("thread_led_controller.lua")

	love.graphics.setDefaultFilter("nearest", "nearest",0)
	fps = 60
	-- lx, ly = 64, 64
	-- lx, ly = 64, 8
	m = json.decode(love.filesystem.read("ressource/map/map_hat_bis.json"))
	-- thread:start(
	-- 	{
	-- 		led_nb = lx*ly,
	-- 		protocol = "BRO888",
	-- 		ip = "192.168.1.210",
	-- 		debug = false,
	-- 		map = m
	-- 	},
	-- 	fps,
	-- 	true
	-- )

	-- fps = 30
	-- lx, ly = 216, 64
	lx, ly = 40, 20
	-- m = json.decode(love.filesystem.read("ressource/map/map_40x20.json"))
	-- thread:start(
	-- 	{
	-- 		led_nb = lx*ly,
	-- 		ip = "10.80.1.18",
	-- 		protocol = "artnet",
	-- 		debug = false,
	-- 		map = m,
	-- 		rgbw = true,
	-- 		leds_by_uni = 100
	-- 	},
	-- 	fps,
	-- 	false
	-- )



	map = {}
	for k,v in ipairs(m) do
		if map[v.x+1] == nil then map[v.x+1]={} end
		map[v.x+1][v.y+1] = {
			uni = v.uni,
			id = v.id
		}
	end



	canvas = love.graphics.newCanvas(lx, ly, {dpiscale = 1, mipmaps = "none"})
	canvas_test = love.graphics.newCanvas(lx, ly, {dpiscale = 1, mipmaps = "none"})
	canvas:setFilter("nearest", "nearest")

	shaders = {}
	shaders_param = {
		speed = 1,
		density = 1
	}
	shader_nb = 1

	local list = love.filesystem.getDirectoryItems("ressource/shader/")
	print("Compile shader:")
	for k,v in ipairs(list) do
		print("    "..v)
		shaders[k] = {}
		shaders[k].shader = love.graphics.newShader("ressource/shader/"..v)
		shaders[k].name = v
	end

	-- for k,v in pairs(loveframes.skins) do print(k,v) end

	-- loveframes.SetActiveSkin("Orange")
	-- loveframes.SetActiveSkin("Blue")
	loveframes.SetActiveSkin("Default red")
	-- loveframes.SetActiveSkin("Dark red")

	frame_animation:load(loveframes, lx, ly)
	node_list = frame_network_scan:load(loveframes)
	-- frame_pixel_map:load(loveframes)
	-- frame_network_map:load(loveframes)
	frame_player:load(loveframes)

	local image = love.graphics.newImage("ressource/image/bg.png")
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

	-- local width, height = love.window.getDesktopDimensions(1)
	-- local tx, ty =love.window.getMode()
	-- local pixelwidth, pixelheight = love.graphics.getPixelDimensions()
	-- local gx, gy = love.graphics.getDimensions()
	-- local x,y,sx, sy = love.window.getSafeArea()
	--
	-- love.graphics.print("getDesktopDimensions: "..width.."x"..height, 10, 50)
	-- love.graphics.print("getMode: "..tx.."x"..ty, 10, 70)
	-- love.graphics.print("getPixelDimensions: "..pixelwidth.."x"..pixelheight, 10, 90)
	-- love.graphics.print("getDimensions: "..gx.."x"..gy, 10, 110)
	-- love.graphics.print("getSafeArea: "..x.."x"..y..", "..sx.."x"..sy, 10, 130)
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
	loveframes.keypressed(key, unicode)
	if key == "up" then
		ly = ly + 1
	elseif key == "down" and canvas:getHeight() > 1 then
		ly = ly - 1
	elseif key == "left" and canvas:getWidth() > 1 then
		lx = lx - 1
	elseif key == "right" then
		lx = lx + 1
	else
		return
	end
	canvas = love.graphics.newCanvas(lx, ly, {dpiscale = 1, mipmaps = "none"})
	canvas_test = love.graphics.newCanvas(lx, ly, {dpiscale = 1, mipmaps = "none"})
	canvas:setFilter("nearest", "nearest")
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
