local node_map = {}

function node_map:load(loveframes, frame, tabs, start_y, step_y)

	local panel_node_map = loveframes.Create("panel")

	tabs:AddTab("Node map", panel_node_map, nil, "ressource/icons/node.png")

	local node_list = loveframes.Create("columnlist", panel_node_map)
	node_list:SetPos(0, start_y+step_y)
	node_list:SetSize(panel_node_map:GetWidth(), panel_node_map:GetHeight())
	node_list:SetSize(frame:GetWidth()-10, frame:GetHeight()-30-5)
	node_list:AddColumn("net")
	node_list:AddColumn("subnet")
	node_list:AddColumn("ip")
	node_list:AddColumn("port")
	node_list:AddColumn("protocol")
	node_list:AddColumn("RGBW")
	node_list:AddColumn("LEDs nb")

	for k,v in ipairs(mapping.nodes) do
		node_list:AddRow(
			v.net,
			v.uni,
			v.ip,
			v.port,
			v.protocol,
			v.rgbw,
			v.led_nb
		)
	end

	panel_node_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		node_list:SetSize(panel_node_map:GetWidth(), panel_node_map:GetHeight()-start_y-step_y)
	end

	return node_list
end

return node_map
