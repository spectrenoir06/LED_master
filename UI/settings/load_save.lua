local load_save = {}

function load_save:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_load_save = loveframes.Create("panel")
	tabs:AddTab("Load/Save", self.panel_load_save, nil, "ressource/icons/json.png")

	self.choice_file = loveframes.Create("multichoice", self.panel_load_save)
	self.choice_file:SetPos(8, 8)
	self.choice_file:SetSize(self.panel_load_save:GetWidth()-16, 25)

	for k,v in pairs(maps) do
		self.choice_file:AddChoice(v.name)
	end
	self.choice_file:SelectChoice("42.lua")

	self.panel_load_save:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_load_save.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.choice_file:SetWidth(object:GetWidth()-16)
	end
end

return load_save
