local node_scan = {}

function node_scan:load(loveframes, frame, tabs, start_y, step_y)

	local panel_scan = loveframes.Create("panel")
	tabs:AddTab("Scan node", panel_scan, nil, "ressource/icons/node-magnifier.png")

	local node_list = loveframes.Create("columnlist", panel_scan)
	node_list:SetPos(0, start_y+step_y)
	node_list:SetSize(panel_scan:GetWidth(), panel_scan:GetHeight())
	node_list:AddColumn("Name")
	node_list:AddColumn("ip")
	node_list:AddColumn("port")
	node_list:AddColumn("net")
	node_list:AddColumn("subnet")
	node_list:AddColumn("nb_port")
	node_list:AddColumn("bindIndex")
	node_list:AddColumn("status")

	panel_scan.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		node_list:SetSize(panel_scan:GetWidth(), panel_scan:GetHeight()-start_y-step_y)

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

	end

	local button_scan = loveframes.Create("button", panel_scan)
	button_scan:SetWidth(130)
	button_scan:SetText("   Scan network")
	button_scan:SetImage("ressource/icons/binocular.png")
	button_scan:SetPos(8, 8)

	local button_add = loveframes.Create("button", panel_scan)
	button_add:SetWidth(130)
	button_add:SetText("   Add node")
	button_add:SetImage("ressource/icons/node-insert-next.png")
	button_add:SetPos(130+16, 8)

	button_scan.OnClick = function(object, x, y)
		node_list:Clear()
		love.thread.getChannel("data"):push({type = "poll"})
	end

	return node_list
end

return node_scan
