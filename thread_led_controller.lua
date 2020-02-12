require "love.system"
require "love.image"
local socket = require("socket")

local LEDsController = require "lib.LEDsController"

local nodes = {}
local nodes_map = {}
local pixel_map = {}
local ctn = 0

local sync, debug = ...
-- local delay = 1/fps/2
-- print("thread start", t, fps, sync)


local img_channel = love.thread.getChannel("img")
local data_channel = love.thread.getChannel("data")

local controller = LEDsController:new({led_nb = 0})
local udp = controller.udp

while true do
	local img_data = img_channel:pop()
	if img_data then
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
			v:send(0, true, ctn)
			ctn = ctn + 1
		end
		-- if sync then controller:sendArtnetSync() end
	end

	local data = data_channel:pop()
	if data then
		if data.type == "mapping" then
			for k,v in ipairs(data.data.nodes) do
				v.udp = udp
				v.debug = debug
				local n = LEDsController:new(v)
				table.insert(nodes, n)
				nodes_map[v.net*256+v.uni] = n
			end
			pixel_map = data.data.map
		elseif data.type == "poll" then
			controller:sendArtnetPoll()
		elseif data.type == "bright" then
			for k,v in ipairs(nodes) do
				v.bright = data.data
			end
		end
	end
	--
	local data, ip, port = controller.udp:receivefrom()
	if data then
		local type, info = controller:receiveArtnet(data, ip, port)
		if type == "reply" then
			-- controller:addArtnetNode(
			-- 	info.net,
			-- 	info.subnet,
			-- 	info.ip[1].."."..info.ip[2].."."..info.ip[3].."."..info.ip[4],
			-- 	info.port,
			-- 	nb
			-- )
			love.thread.getChannel('node'):push(info)
		end
	end
end
