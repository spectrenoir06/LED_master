require "love.system"
require "love.image"

local LEDsController = require "lib.LEDsController"


local t, fps, sync = ...
print("thread start", t, fps, sync)

controller = LEDsController:new(t)
while true do
	local data = love.thread.getChannel('img'):pop()
	if data then
		local lx, ly = data:getDimensions()
		for k,v in ipairs(controller.map) do
			if v.x >= 0 and v.x < lx and v.y >= 0 and v.y < ly then
				local r,g,b = data:getPixel(v.x, v.y)
				controller:setArtnetLED(v, r*255, g*255, b*255, 0)
			end
		end
		controller:send(1/fps/2, sync)
	end

	local data = love.thread.getChannel('poll'):pop()
	if data then
		controller:sendArtnetPoll()
	end

	local data = love.thread.getChannel('bright'):pop()
	if data then
		LEDsController.bright = data
	end

	local data, ip, port = controller.udp:receivefrom()
	if data then
		-- print(ip,port)
		local type, info = controller:receiveArtnet(data, ip, port)
		if type == "reply" then
			controller:addArtnetNode(
				info.net,
				info.subnet,
				info.ip[1].."."..info.ip[2].."."..info.ip[3].."."..info.ip[4],
				info.port,
				nb
			)
			love.thread.getChannel('node'):push(info)
		end
	end
end
