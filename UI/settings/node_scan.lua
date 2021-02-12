local node_scan = {}

function node_scan:load(loveframes, frame, tabs, start_y, step_y, parent)

	self.panel_scan = loveframes.Create("panel")
	tabs:AddTab("Scan node", self.panel_scan, nil, "ressource/icons/node-magnifier.png")

	self.node_list = loveframes.Create("columnlist", self.panel_scan)
	self.node_list:SetPos(0, start_y+step_y)
	self.node_list:SetSize(self.panel_scan:GetWidth(), self.panel_scan:GetHeight()-start_y-step_y)
	self.node_list:AddColumn("Name").children[1].width = 80
	self.node_list:AddColumn("ip").children[2].width = 80
	self.node_list:AddColumn("port").children[3].width = 40
	self.node_list:AddColumn("net").children[4].width = 30
	self.node_list:AddColumn("sub").children[5].width = 30
	self.node_list:AddColumn("ports").children[6].width = 30
	self.node_list:AddColumn("id").children[7].width = 30
	self.node_list:AddColumn("status").children[8].width = 100

	self.panel_scan:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_scan.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.node_list:SetSize(self.panel_scan:GetWidth(), self.panel_scan:GetHeight()-start_y-step_y)

		local info = love.thread.getChannel('node'):pop()
		if info then
			self.node_list:AddRow(
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

	self.node_list:AddRow(
		"TEST",
		"192.168.1.42",
		1234,
		0,
		42,
		1,
		1,
		"Test debug"
	)

	self.node_list:SetSelectionEnabled(true)

	local function add_new_node()
		tabs:SetVisible(false)
		local data = self.node_list:GetSelectedRows()[1]:GetColumnData()
		local net, sub, ip, port = data[4], data[5], data[2], data[3]
		parent.new_node:reload(net, sub, ip, port)
		parent.new_node.panel_node_new:SetVisible(true)
		parent.new_node.edit = 0
	end

	local menu = loveframes.Create("menu")
	menu:AddOption("Add to node map", "ressource/icons/node-insert-next.png", add_new_node)
	menu:AddOption("Edit node", "ressource/icons/node-design.png", function() end)
	-- menu:AddOption("Delete node", "ressource/icons/node-delete-next.png", function() end)
	menu:SetVisible(false)

	self.node_list.OnRowClicked = function(parent, row, data)
		menu:SetPos(love.mouse.getX(), love.mouse.getY())
		menu:SetVisible(true)
		menu:MoveToTop()
		self.node_list:SelectRow(row)
	end

	self.button_scan = loveframes.Create("button", self.panel_scan)
	self.button_scan:SetWidth(130)
	self.button_scan:SetText("   Scan network")
	self.button_scan:SetImage("ressource/icons/binocular.png")
	self.button_scan:SetPos(8, 8)

	self.button_scan.OnClick = function(object, x, y)
		self.node_list:Clear()
		love.thread.getChannel("data"):supply({type = "poll"})
	end
end

return node_scan
