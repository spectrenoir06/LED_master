local network_scan = {}

function network_scan:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("Network Discovery")
	frame:SetPos(0, 280+230)

	local lx, ly = love.graphics.getDimensions()
	if love.system.getOS() == "Android" then
		lx, ly = ly, lx
	end
	frame:SetSize(lx, 328+30)

	frame:SetResizable(true)
	-- frame:SetMaxWidth(1000)
	-- frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)
	-- frame:SetScreenLocked(true)

	frame:SetDockable(true)

	local node_list = loveframes.Create("columnlist", frame)
	node_list:SetPos(5, 60)
	node_list:SetSize(frame:GetWidth()-10, frame:GetHeight()-60-5)
	node_list:AddColumn("Name")
	node_list:AddColumn("ip")
	node_list:AddColumn("port")
	node_list:AddColumn("net")
	node_list:AddColumn("subnet")
	node_list:AddColumn("nb_port")
	node_list:AddColumn("bindIndex")
	node_list:AddColumn("status")

	node_list.Update = function(object)
		object:SetSize(frame:GetWidth()-10, frame:GetHeight()-60-5)
	end

	local button = loveframes.Create("button", frame)
	button:SetWidth(200)
	button:SetPos(5, 30)
	button:SetText("Scan network")
	-- button:Center()
	button.OnClick = function(object, x, y)
		node_list:Clear()
		love.thread.getChannel('poll'):push(true)
	end

	return node_list
end

return network_scan
