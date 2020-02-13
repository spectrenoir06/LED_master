local node_map = {}

function node_map:load(loveframes, frame, tabs, start_y, step_y)
	self.panel_node_map = loveframes.Create("panel")

	tabs:AddTab("Node map", self.panel_node_map, nil, "ressource/icons/node.png", function() self:reload() end)

	self.node_list = loveframes.Create("columnlist", self.panel_node_map)
	self.node_list:SetPos(0, start_y+step_y)
	self.node_list:SetSize(self.panel_node_map:GetWidth(), self.panel_node_map:GetHeight()-start_y-step_y)
	self.node_list:AddColumn("net")
	self.node_list:AddColumn("subnet")
	self.node_list:AddColumn("ip")
	self.node_list:AddColumn("port")
	self.node_list:AddColumn("protocol")
	self.node_list:AddColumn("RGBW")
	self.node_list:AddColumn("LEDs nb")

	self.button_add = loveframes.Create("button", self.panel_node_map)
	self.button_add:SetWidth(130)
	self.button_add:SetText("   Add new node")
	self.button_add:SetImage("ressource/icons/node-insert-next.png")
	self.button_add:SetPos(8, 8)

	self.panel_node_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_node_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.node_list:SetSize(self.panel_node_map:GetWidth(), self.panel_node_map:GetHeight()-start_y-step_y)
	end
end

function node_map:reload()
	self.node_list:Clear()
	for k,v in ipairs(mapping.nodes) do
		self.node_list:AddRow(
			v.net,
			v.uni,
			v.ip,
			v.port,
			v.protocol,
			v.rgbw,
			v.led_nb
		)
	end
end

return node_map
