local node_map = {}

function node_map:load(loveframes, frame, tabs, start_y, step_y, parent)
	self.panel_node_map = loveframes.Create("panel")

	tabs:AddTab("Node map", self.panel_node_map, nil, "ressource/icons/node.png", function() self:reload() end)

	self.node_list = loveframes.Create("columnlist", self.panel_node_map)
	self.node_list:SetPos(0, start_y+step_y)
	self.node_list:SetSize(self.panel_node_map:GetWidth(), self.panel_node_map:GetHeight()-start_y-step_y)

	self.node_list:AddColumn("net").children[1].width = 30
	self.node_list:AddColumn("sub").children[2].width = 30
	self.node_list:AddColumn("uni").children[3].width = 30
	self.node_list:AddColumn("ip").children[4].width = 80
	self.node_list:AddColumn("port").children[5].width = 40	
	self.node_list:AddColumn("protocol").children[6].width = 50
	self.node_list:AddColumn("RGBW").children[7].width = 40
	self.node_list:AddColumn("LEDs nb").children[8].width = 50

	self.button_add = loveframes.Create("button", self.panel_node_map)
	self.button_add:SetWidth(130)
	self.button_add:SetText("   Add a node manually")
	self.button_add:SetImage("ressource/icons/node-insert-next.png")
	self.button_add:SetPos(8, 8)

	self.panel_node_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.button_add.OnClick = function()
		tabs:SetVisible(false)
		parent.new_node.edit = 0
		parent.new_node:reload()
		parent.new_node.panel_node_new:SetVisible(true)
	end

	local function edit_node()
		tabs:SetVisible(false)
		local data = self.node_list:GetSelectedRows()[1]:GetColumnData()
		local net, sub, uni, ip, port, protocol, rgbw, led_nb = data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]

		parent.new_node:reload(net, sub, uni, ip, port, protocol, rgbw, led_nb)
		parent.new_node.panel_node_new:SetVisible(true)
		for k,v in ipairs(self.node_list.internals[1].children) do
			if v == self.node_list:GetSelectedRows()[1] then
				parent.new_node.edit = k
				parent.node_map:reload()
				return
			end
		end
	end

	local function remove_node()
		local d = self.node_list:GetSelectedRows()[1]
		for k,v in ipairs(self.node_list.internals[1].children) do
			if v == d then
				self.node_list:RemoveRow(k)
				table.remove(mapping.nodes, d:GetColumnData()[8])
				return
			end
		end
	end

	local menu = loveframes.Create("menu")
	menu:AddOption("Edit node", "ressource/icons/node-design.png", edit_node)
	menu:AddOption("Remove node", "ressource/icons/node-delete-next.png", remove_node)
	menu:SetVisible(false)

	self.node_list.OnRowClicked = function(parent, row, data)
		menu:SetPos(love.mouse.getX(), love.mouse.getY())
		menu:SetVisible(true)
		menu:MoveToTop()
		self.node_list:SelectRow(row)
	end

	self.panel_node_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.node_list:SetSize(self.panel_node_map:GetWidth(), self.panel_node_map:GetHeight()-start_y-step_y)
	end
end

function node_map:reload()
	self.node_list:Clear()
	for k,v in ipairs(mapping.nodes) do
		local uni = (bit.band(v.uni or 0, 0xF))
		local subnet = bit.rshift(v.uni or 0, 4)
		self.node_list:AddRow(
			v.net,
			subnet,
			uni,
			v.ip,
			v.port,
			v.protocol,
			v.rgbw,
			v.led_nb,
			k
		)
	end
	local channel_data = love.thread.getChannel("data")
	channel_data:supply({type = "nodes", data = mapping.nodes})
end

return node_map
