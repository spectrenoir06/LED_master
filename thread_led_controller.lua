require "love.system"
require "love.image"

local LEDsController = require "lib.LEDsController"


local t, fps, sync = ...
-- print("thread start", t, fps, sync)

controller = LEDsController:new(t)
while true do
	local data = love.thread.getChannel('img'):pop()
	if data then
		local leds = controller.leds
		for x=0,data:getWidth()-1,1 do
			for y=0,data:getHeight()-1,1 do
				local r,g,b = data:getPixel(x, y)
				-- local w = (math.max(r,g,b) + math.min(r,g,b)) / 2
				-- local w = math.min(r,g,b)
				-- r,g,b = r-w, g-w, b-w
				local w = 0
				controller:setArtnetLED(x, y, {r*255, g*255, b*255, w*255})
			end
		end
		controller:send(1/fps, sync)
	end

	local data = love.thread.getChannel('poll'):pop()
	if data then
		controller:sendArtnetPoll()
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
				love.thread.getChannel('node'):push(info)
			-- end
		end
	end
end
