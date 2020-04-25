local load_save = {}

function load_save:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_load_save = loveframes.Create("panel")
	tabs:AddTab("Load/Save", self.panel_load_save, nil, "ressource/icons/json.png")

	self.choice_file = loveframes.Create("multichoice", self.panel_load_save)
	self.choice_file:SetPos(8, 8)
	self.choice_file:SetSize(self.panel_load_save:GetWidth()-16, 25)

	local list = loveframes.Create("columnlist", self.panel_load_save)
	list:SetPos(8, 38)
	list:SetSize(self.panel_load_save:GetWidth()-16, self.panel_load_save:GetHeight()-38-8)
	list:AddColumn("Name").children[1].width = 120
	list:AddColumn("lx").children[2].width = 30
	list:AddColumn("ly").children[3].width = 30
	list:AddColumn("fps").children[4].width = 30
	list:AddColumn("nodes").children[4].width = 30
	list:AddColumn("pixels").children[5].width = 30

	for k,v in pairs(maps) do
		self.choice_file:AddChoice(v.name)
		list:AddRow(v.name, v.lx, v.ly, v.fps, #v.nodes, #v.map)
	end
	self.choice_file:SelectChoice("42.map")

	self.panel_load_save:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_load_save.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.choice_file:SetWidth(object:GetWidth()-16)
		list:SetSize(object:GetWidth()-16, object:GetHeight()-38-8)
	end

	self.choice_file.OnChoiceSelected = function(object, choice)
		mapping = maps[choice]
		local channel_data = love.thread.getChannel("data")
		channel_data:push({type = "map", data = mapping.map})
		channel_data:push({type = "nodes", data = mapping.nodes})

		canvas = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end
end

return load_save
