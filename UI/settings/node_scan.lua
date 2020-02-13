local node_scan = {}

function node_scan:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_scan = loveframes.Create("panel")
	tabs:AddTab("Scan node", self.panel_scan, nil, "ressource/icons/node-magnifier.png")

	self.node_list = loveframes.Create("columnlist", self.panel_scan)
	self.node_list:SetPos(0, start_y+step_y)
	self.node_list:SetSize(self.panel_scan:GetWidth(), self.panel_scan:GetHeight()-start_y-step_y)
	self.node_list:AddColumn("Name")
	self.node_list:AddColumn("ip")
	self.node_list:AddColumn("port")
	self.node_list:AddColumn("net")
	self.node_list:AddColumn("subnet")
	self.node_list:AddColumn("nb_port")
	self.node_list:AddColumn("bindIndex")
	self.node_list:AddColumn("status")

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

	self.button_scan = loveframes.Create("button", self.panel_scan)
	self.button_scan:SetWidth(130)
	self.button_scan:SetText("   Scan network")
	self.button_scan:SetImage("ressource/icons/binocular.png")
	self.button_scan:SetPos(8, 8)

	self.button_scan.OnClick = function(object, x, y)
		self.node_list:Clear()
		love.thread.getChannel("data"):push({type = "poll"})
	end
end

return node_scan
