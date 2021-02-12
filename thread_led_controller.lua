require "love.system"
require "love.image"
require "love.filesystem"
require "lib.dither"
local socket = require("socket")

local LEDsController = require("LEDsController")

local nodes = {}
local nodes_map = {}
local pixel_map = {}

local sync, debug = ...
-- local delay = 1/fps/2
-- print("thread start", t, fps, sync)

local data_channel = love.thread.getChannel("data")

local controller
local status, err = pcall(function() controller = LEDsController:new({led_nb = 0}) end)
if not status then
	error(err)
end

local udp = controller.udp

while true do
	local d = data_channel:demand(1)
	if d then
		if d.type ~= "image" then
			print(d.type)
		end
		if d.type == "image" then
			local img_data = d.data
			-- dither_fs(img_data, 5, 6, 5)
			local lx, ly = img_data:getDimensions()
			for k,v in ipairs(pixel_map) do
				if v.x >= 0 and v.x < lx and v.y >= 0 and v.y < ly then
					local r,g,b = img_data:getPixel(v.x, v.y)
					local n = nodes_map[v.net*256+v.uni]
					if n then
						n:setLED(v, r*255, g*255, b*255, 0)
					end
				end
			end
			for k,v in ipairs(nodes) do
				v:send(0, true)
			end
			-- if sync then controller:sendArtnetSync() end
		elseif d.type == "nodes" then
			for k,v in ipairs(nodes) do
				v:stop()
			end
			nodes = {}
			for k,v in ipairs(d.data) do
				v.udp = udp
				v.debug = debug
				v.remote_port = v.port
				local n = LEDsController:new(v)
				table.insert(nodes, n)
				nodes_map[v.net*256+v.uni] = n
			end
		elseif d.type == "map" then
			pixel_map = d.data
		elseif d.type == "poll" then
			controller:sendArtnetPoll()
		elseif d.type == "bright" then
			for k,v in ipairs(nodes) do
				v.bright = d.data
			end
		elseif d.type == "rgbw" then
			for k,v in ipairs(nodes) do
				v.rgbw_mode = d.data
			end
		elseif d.type == "dump" then
			nodes[1]:start_dump("Z565", os.time(os.date("!*t")))
		elseif d.type == "stop" then
			for k,v in ipairs(nodes) do
				v:stop()
			end
		end
	end
	--
	local data, ip, port = controller.udp:receivefrom()
	if data then
		local type, info = controller:receiveArtnet(data, ip, port)
		if type == "reply" then
			love.thread.getChannel('node'):push(info)
		end
	end
	-- socket.sleep(0.01)
end
