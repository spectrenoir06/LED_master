local load_save = {}

function load_save:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_load_save = loveframes.Create("panel")
	tabs:AddTab("Load/Save", self.panel_load_save, nil, "ressource/icons/json.png", function() self:reload() end)

	-- self.choice_file = loveframes.Create("multichoice", self.panel_load_save)
	-- self.choice_file:SetPos(8, 8)
	-- self.choice_file:SetSize(self.panel_load_save:GetWidth()-16, 25)

	self.list = loveframes.Create("columnlist", self.panel_load_save)
	self.list:SetPos(8, 8)
	self.list:SetSize((self.panel_load_save:GetWidth()-16)-230, self.panel_load_save:GetHeight()-16)
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

	-- self.choice_file:SelectChoice("42.map")

	self.panel_load_save:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_load_save.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		-- self.choice_file:SetWidth(object:GetWidth()-16)
		self.list:SetSize((object:GetWidth()-16)-230, object:GetHeight()-16)

		self.panel_load_setting:SetSize(230-8, self.panel_load_save:GetHeight()-16)
		self.panel_load_setting:SetPos(self.panel_load_save:GetWidth()-230,8)
	end

	self.panel_load_setting = loveframes.Create("panel", self.panel_load_save)
	self.panel_load_setting:SetSize(230-8, self.panel_load_save:GetHeight()-16)
	self.panel_load_setting:SetPos(self.panel_load_save:GetWidth()-230,8)

	self.button_save = loveframes.Create("button", self.panel_load_setting)
	self.button_save:SetWidth(60)
	self.button_save:SetText("Save")
	self.button_save:SetImage("ressource/icons/disk.png")
	self.button_save:SetPos(8, step_y*1+8)

	self.button_save.OnClick = function(object, x, y)
		local data = gen_map_file(mapping)
		print(love.filesystem.write( "ressource/map/"..mapping.name, data))
		self:reload()
	end


	self.button_delete = loveframes.Create("button", self.panel_load_setting)
	self.button_delete:SetWidth(60)
	self.button_delete:SetText("Delete")
	self.button_delete:SetImage("ressource/icons/disk--minus.png")
	self.button_delete:SetPos(60+8+8, step_y*1+8)

	self.button_clone = loveframes.Create("button", self.panel_load_setting)
	self.button_clone:SetWidth(60)
	self.button_clone:SetText("Clone")
	self.button_clone:SetImage("ressource/icons/disks.png")
	self.button_clone:SetPos(120+8+8+8, step_y*1+8)

	self.textinput_name = loveframes.Create("textinput", self.panel_load_setting)
	self.textinput_name:SetPos(8, step_y*0+8)
	self.textinput_name:SetWidth(230-16-8)
	-- self.textinput_name:SetFont(love.graphics.newFont(12))

	local menu = loveframes.Create("menu")
	menu:AddOption("Duplicate", "ressource/icons/node-design.png", nil)
	menu:AddOption("Remove map", "ressource/icons/disk--minus.png", nil)
	menu:AddOption("Remove change", "ressource/icons/disk--minus.png", nil)
	menu:SetVisible(false)


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

		self.textinput_name:SetText(data[1]:match("^(.+).map$"))
	end

	self.list.OnRowRightClicked = function(parent, row, data)
		menu:SetPos(love.mouse.getX(), love.mouse.getY())
		menu:SetVisible(true)
		menu:MoveToTop()
	end

	for k,v in pairs(maps) do
		self.list:AddRow(v.name, v.lx, v.ly, v.fps, #v.nodes, #v.map, false)
	end
	-- self:reload()

	self.list:SelectRow(self.list.internals[1].children[1])
	menu:SetVisible(false)

end

function load_save:reload()
	for k,v in ipairs(self.list.internals[1].children) do
		local name = v.columndata[1]
		local diff = (gen_map_file(maps[name]) ~= love.filesystem.read("ressource/map/"..name))
		v.columndata[7] = tostring(diff)
	end
end

return load_save
