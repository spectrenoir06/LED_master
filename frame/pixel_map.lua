local pixel_map = {}

function pixel_map:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Pixel Map")
	frame:SetSize(890, 715)
	frame:SetPos(610, 0)

	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)


	local grid = loveframes.Create("grid", frame)
	grid:SetPos(5, 30)
	grid:SetRows(#controller.map[1])
	grid:SetColumns(#controller.map)
	grid:SetCellWidth(40)
	grid:SetCellHeight(30)
	grid:SetCellPadding(2)
	grid:SetItemAutoSize(true)

	local id = 1

	for x=1, #controller.map do
		for y=1, #controller.map[1] do
			local m = controller.map[x][y]
			if m then
				local ur,ug,ub = hslToRgb(m.uni/5,1,0.4)
				local ir,ig,ib = hslToRgb(m.id/100,1,0.0)
				local text = {
					{color = {ur, ug, ub}},
					"Uni:"..m.uni,
					{color = {ir, ig, ib}},
					"\nID:"..m.id,
				}
				local text1 = loveframes.Create("text")
				text1:SetText(text)
				grid:AddItem(text1, y, x)
			end
		end
	end

end

return pixel_map
