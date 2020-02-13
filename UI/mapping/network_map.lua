local network_map = {}

function network_map:load(loveframes, lx)
	local frame = loveframes.Create("frame")
	frame:SetName("Network Map")
	frame:SetIcon("ressource/icons/network-hub.png")

	local lx, ly = love.graphics.getDimensions()
	if love.system.getOS() == "Android" then
		lx, ly = ly, lx
	end

	frame:SetSize(lx, 318+30)
	frame:SetPos(0, 290+230)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	frame:SetDockable(true)

	column = loveframes.Create("columnlist", frame)
	column:SetPos(5, 30)
	column:SetSize(frame:GetWidth()-10, frame:GetHeight()-30-5)
	column:AddColumn("net")
	column:AddColumn("subnet")
	column:AddColumn("ip")
	column:AddColumn("port")
	column:AddColumn("protocol")
	column:AddColumn("RGBW")
	column:AddColumn("LEDs nb")

	frame.Update = function(object, dt)
		column:SetSize(frame:GetWidth()-10, frame:GetHeight()-30-5)
	end
	return frame, column
end

return network_map
