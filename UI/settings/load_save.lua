local load_save = {}

function load_save:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_load_save = loveframes.Create("panel")
	tabs:AddTab("Load/Save", self.panel_load_save, nil, "ressource/icons/json.png", function() self:reload() end)

	-- self.choice_file = loveframes.Create("multichoice", self.panel_load_save)
	-- self.choice_file:SetPos(8, 8)
	-- self.choice_file:SetSize(self.panel_load_save:GetWidth()-16, 25)

	self.list = loveframes.Create("columnlist", self.panel_load_save)
	self.list:SetPos(8, 8)
	self.list:SetSize((self.panel_load_save:GetWidth()-16)/2, self.panel_load_save:GetHeight()-16)
	self.list:AddColumn("Name").children[1].width = 120
	self.list:AddColumn("lx").children[2].width = 30
	self.list:AddColumn("ly").children[3].width = 30
	self.list:AddColumn("fps").children[4].width = 30
	self.list:AddColumn("nodes").children[5].width = 40
	self.list:AddColumn("pixels").children[6].width = 50
	self.list:AddColumn("change").children[7].width = 40
	--
	self.list:SetSelectionEnabled(true)
	-- self.list:SelectRow(1)

	self:reload()

	-- self.choice_file:SelectChoice("42.map")

	self.panel_load_save:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_load_save.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		-- self.choice_file:SetWidth(object:GetWidth()-16)
		self.list:SetSize((object:GetWidth()-16)/2, object:GetHeight()-16)
	end

	self.list.OnRowSelected = function(object, row, data)
		print("OnRowSelected", data[1])
		mapping = maps[data[1]]
		local channel_data = love.thread.getChannel("data")
		channel_data:push({type = "map", data = mapping.map})
		channel_data:push({type = "nodes", data = mapping.nodes})

		canvas = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end

	for k,v in pairs(maps) do
		self.list:AddRow(v.name, v.lx, v.ly, v.fps, #v.nodes, #v.map, diff)
	end

	self.list:SelectRow(self.list.internals[1].children[1])

end

function load_save:reload()
	for k,v in ipairs(self.list.internals[1].children) do
		local name = v.columndata[1]
		local diff = (gen_map_file(maps[name]) ~= love.filesystem.read("ressource/map/"..name))
		v.columndata[7] = tostring(diff)
	end
end

return load_save
