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

	network_map = loveframes.Create("columnlist", frame)
	network_map:SetPos(5, 30)
	network_map:SetSize(frame:GetWidth()-10, frame:GetHeight()-30-5)
	network_map:AddColumn("net")
	network_map:AddColumn("subnet")
	network_map:AddColumn("ip")
	network_map:AddColumn("port")
	network_map:AddColumn("protocol")
	network_map:AddColumn("RGBW")
	network_map:AddColumn("LEDs nb")

	return frame, network_map
end

return network_map
