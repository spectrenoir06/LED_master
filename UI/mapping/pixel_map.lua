local pixel_map = {}

function pixel_map:load(loveframes, frame, tabs, start_y, step_y)

	local panel_pixel_map = loveframes.Create("panel")

	tabs:AddTab("Pixel map", panel_pixel_map, nil, "ressource/icons/map.png")

	local small_font = love.graphics.newFont(10)

	local grid = loveframes.Create("grid", panel_pixel_map)
	grid:SetPos(0, 0)
	grid:SetRows(mapping.ly)
	grid:SetColumns(mapping.lx)
	grid:SetCellWidth(34)
	grid:SetCellHeight(25)
	grid:SetCellPadding(2)
	-- grid:SetItemAutoSize(true)

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
		grid:AddItem(text1, v.y+1, v.x+1)
	end

	-- frame:SetSize(
	-- 	(grid:GetCellWidth()+grid:GetCellPadding()*2)*grid:GetColumns()+10,
	-- 	(grid:GetCellHeight()+grid:GetCellPadding()*2)*grid:GetRows()+30+5
	-- )

	panel_pixel_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		grid:SetSize(panel_pixel_map:GetWidth(), panel_pixel_map:GetHeight()-start_y-step_y)
	end

end

return pixel_map
