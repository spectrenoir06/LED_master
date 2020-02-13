local setting = {}

function setting:load(loveframes, frame, tabs, start_y, step_y)

	local panel_setting = loveframes.Create("panel")

	local font = love.graphics.newFont("ressource/font/Code_8x8.ttf", 8, "normal")
	font:setFilter("nearest","nearest")
	local lx, ly = canvas:getDimensions()

	tabs:AddTab("Setting", panel_setting, nil, "ressource/icons/wrench.png", function() love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight()) end, function() love.keyboard.setTextInput(false) end)
	local numberbox_x = loveframes.Create("numberbox", panel_setting)
	numberbox_x:SetPos(8, 8)
	numberbox_x:SetSize(200, 25)
	numberbox_x:SetMinMax(1, 512)
	numberbox_x:SetValue(lx)

	numberbox_x.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end


	local numberbox_y = loveframes.Create("numberbox", panel_setting)
	numberbox_y:SetPos(8, 40)
	numberbox_y:SetSize(200, 25)
	numberbox_y:SetMinMax(1, 512)
	numberbox_y:SetValue(ly)

	numberbox_y.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end

	panel_setting.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		numberbox_x:SetWidth(object:GetWidth()-16)
		numberbox_y:SetWidth(object:GetWidth()-16)

		love.graphics.setCanvas(canvas)
			love.graphics.setFont(font)
			love.graphics.clear(0,0,0,1)
			love.graphics.setColor(1,1,1,1)
				local lx, ly = canvas:getDimensions()
				love.graphics.print("x "..lx, 1, 0)
				love.graphics.print("y "..ly, 1, 10)
		love.graphics.setCanvas()
	end

end

return setting
