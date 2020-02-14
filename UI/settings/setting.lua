local setting = {}

function setting:load(loveframes, frame, tabs, start_y, step_y)

	local panel_setting = loveframes.Create("panel")
	local small_font = love.graphics.newFont(10)

	tabs:AddTab("Setting", panel_setting, nil, "ressource/icons/wrench.png", function() self:reload()end)
	self.numberbox_x = loveframes.Create("numberbox", panel_setting)
	self.numberbox_x:SetPos(8+100, start_y)
	self.numberbox_x:SetWidth(panel_setting:GetWidth()-16-100)
	self.numberbox_x:SetSize(100, 25)
	self.numberbox_x:SetMinMax(1, 2048)
	self.numberbox_x:SetValue(canvas:getWidth())

	self.numberbox_x_text = loveframes.Create("text", panel_setting)
	self.numberbox_x_text:SetPos(8, start_y+step_y*0+6)
	self.numberbox_x_text:SetText("Canvas X size")
	self.numberbox_x_text:SetFont(small_font)

	self.numberbox_x.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end

	self.numberbox_x:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.numberbox_x:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.numberbox_y = loveframes.Create("numberbox", panel_setting)
	self.numberbox_y:SetPos(8+100, start_y+step_y*1)
	self.numberbox_y:SetSize(100, 25)
	self.numberbox_y:SetWidth(panel_setting:GetWidth()-16-100)
	self.numberbox_y:SetMinMax(1, 2048)
	self.numberbox_y:SetValue(canvas:getHeight())

	self.numberbox_y_text = loveframes.Create("text", panel_setting)
	self.numberbox_y_text:SetPos(8, start_y+step_y*1+6)
	self.numberbox_y_text:SetText("Canvas Y size")
	self.numberbox_y_text:SetFont(small_font)

	self.numberbox_y:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.numberbox_y:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.numberbox_y.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end


	self.slider_bright = loveframes.Create("slider", panel_setting)
	self.slider_bright:SetPos(100, start_y+step_y*2)
	self.slider_bright:SetWidth(panel_setting:GetWidth()-100-8)
	self.slider_bright:SetMinMax(0.0, 1)
	self.slider_bright:SetValue(1)

	self.slider_bright_text = loveframes.Create("text", panel_setting)
	self.slider_bright_text:SetPos(8, start_y+step_y*2+4)
	self.slider_bright_text:SetText("Bright: "..(self.slider_bright:GetValue()*100).." %")
	self.slider_bright_text:SetFont(small_font)

	self.slider_bright.OnValueChanged = function(object)
		self.slider_bright_text:SetText("Bright: "..(math.floor(self.slider_bright:GetValue()*100)/100*100).." %")
		shaders_param.bright = self.slider_bright:GetValue()
		love.thread.getChannel('data'):push({ type = "bright", data = self.slider_bright:GetValue()})
	end

	self.choice_rgbw = loveframes.Create("text", panel_setting)
	self.choice_rgbw:SetPos(8, start_y+step_y*3+6)
	self.choice_rgbw:SetText("RGBW mode:")
	self.choice_rgbw:SetFont(small_font)

	self.choice_rgbw = loveframes.Create("multichoice", panel_setting)
	self.choice_rgbw:SetPos(108, start_y+step_y*3)
	self.choice_rgbw:SetSize(panel_setting:GetWidth()-16-100, 25)

	self.choice_rgbw:AddChoice("Mode 0")
	self.choice_rgbw:AddChoice("Mode 1")
	self.choice_rgbw:AddChoice("Mode 2")
	self.choice_rgbw:AddChoice("Mode 3")
	self.choice_rgbw:SelectChoice("Mode 0")


	panel_setting.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.numberbox_x:SetWidth(object:GetWidth()-16-100)
		self.numberbox_y:SetWidth(object:GetWidth()-16-100)
		self.slider_bright:SetWidth(object:GetWidth()-100-8)
		self.choice_rgbw:SetSize(object:GetWidth()-16-100, 25)
	end

	self.choice_rgbw.OnChoiceSelected = function(object, choice)
		local v = 0
		if choice == "Mode 1" then v = 1 end
		if choice == "Mode 2" then v = 2 end
		if choice == "Mode 3" then v = 3 end
		love.thread.getChannel('data'):push({ type = "rgbw", data = v})
	end
end

function setting:reload()
	self.numberbox_x:SetValue(canvas:getWidth())
	self.numberbox_y:SetValue(canvas:getHeight())
end

return setting
