local pixel_map = {}

function pixel_map:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_pixel_map = loveframes.Create("panel")

	tabs:AddTab("Pixel map", self.panel_pixel_map, nil, "ressource/icons/map.png")

	local small_font = love.graphics.newFont(10)

	self.grid = loveframes.Create("grid", self.panel_pixel_map)

	self.grid:SetRows(mapping.ly)
	self.grid:SetColumns(mapping.lx)
	self.grid:SetCellWidth(34)
	self.grid:SetCellHeight(25)
	self.grid:SetCellPadding(2)
	self.grid:SetItemAutoSize(false)

	local id = 1

	for k,v in ipairs(mapping.map) do
		local ur,ug,ub = hslToRgb(v.uni/5,1,0.4)
		local ir,ig,ib = hslToRgb(v.id/100,1,0.0)
		local text = {
			{color = {ur, ug, ub}, font = small_font},
			"Uni:"..v.uni,
			{color = {ir, ig, ib}, font = small_font},
			"\nID:"..v.id,
		}
		local text1 = loveframes.Create("text")
		text1:SetText(text)
		self.grid:AddItem(text1, v.y+1, v.x+1)
	end

	self.panel_pixel_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-4)
	self.grid:SetSize(self.panel_pixel_map:GetWidth(), self.panel_pixel_map:GetHeight()-start_y-step_y)

	self.panel_pixel_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-4)
		self.grid:SetSize(self.panel_pixel_map:GetWidth(), self.panel_pixel_map:GetHeight()-start_y-step_y)
	end

end

return pixel_map
