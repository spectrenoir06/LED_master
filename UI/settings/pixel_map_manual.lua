local pixel_map_manual = {}
local small_font = love.graphics.newFont(10)

function pixel_map_manual:load(loveframes, frame, tabs, start_y, step_y, parent)

	self.parent = parent

	parent.panel_pixel_map_manual = loveframes.Create("panel")

	tabs:AddTab("Manual", parent.panel_pixel_map_manual, nil, "ressource/icons/pencil.png", function() self.parent:reload() end)
	local step_y = 25
	local setting_lx = 180
	local start_y = start_y-10

	self.numberbox_x = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.numberbox_x:SetPos(8, start_y+step_y*1)
	self.numberbox_x:SetSize(70, 25)
	self.numberbox_x:SetMinMax(0, mapping.lx-1)
	self.numberbox_x:SetValue(0)

	self.numberbox_x_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.numberbox_x_text:SetPos(8, start_y+step_y*0+6)
	self.numberbox_x_text:SetText("X:")
	self.numberbox_x_text:SetFont(small_font)

	self.numberbox_x.OnValueChanged = function(obj, value)
		self.parent.select_x = value
		self:update_box()
	end

	self.numberbox_y = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.numberbox_y:SetPos(8+70+8, start_y+step_y*1)
	self.numberbox_y:SetSize(70, 25)
	self.numberbox_y:SetMinMax(0, mapping.ly-1)
	self.numberbox_y:SetValue(0)

	self.numberbox_y_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.numberbox_y_text:SetPos(8+85, start_y+step_y*0+6)
	self.numberbox_y_text:SetText("Y:")
	self.numberbox_y_text:SetFont(small_font)

	self.numberbox_y.OnValueChanged = function(obj, value)
		self.parent.select_y = value
		self:update_box()
	end

	self.net = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.net:SetPos(8, start_y+step_y*3)
	self.net:SetSize(100, 25)
	self.net:SetWidth(60)
	self.net:SetMinMax(0, 127)
	self.net:SetValue(0)

	self.net_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.net_text:SetPos(8, start_y+step_y*2+8)
	self.net_text:SetText("Net:")
	self.net_text:SetFont(small_font)

	self.net.OnValueChanged = function(obj, value)
		self:update_value_and_reload()
	end

	self.net:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.net:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.subnet = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.subnet:SetPos(8+59, start_y+step_y*3)
	self.subnet:SetSize(100, 25)
	self.subnet:SetWidth(45)
	self.subnet:SetMinMax(0, 15)
	self.subnet:SetValue(0)

	self.subnet_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.subnet_text:SetPos(8+59, start_y+step_y*2+8)
	self.subnet_text:SetText("Subnet:")
	self.subnet_text:SetFont(small_font)

	self.subnet.OnValueChanged = function(obj, value)
		self:update_value_and_reload()
	end

	self.subnet:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.subnet:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.uni = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.uni:SetPos(8+103, start_y+step_y*3)
	self.uni:SetSize(100, 25)
	self.uni:SetWidth(45)
	self.uni:SetMinMax(0, 15)
	self.uni:SetValue(0)

	self.uni_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.uni_text:SetPos(8+103, start_y+step_y*2+8)
	self.uni_text:SetText("Uni:")
	self.uni_text:SetFont(small_font)

	self.uni.OnValueChanged = function(obj, value)
		self:update_value_and_reload()
	end

	self.uni:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.uni:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.id = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.id:SetPos(8, start_y+step_y*5)
	self.id:SetSize(80, 25)
	self.id:SetMinMax(-1, 9999)
	self.id:SetValue(0)

	self.id_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.id_text:SetPos(8, start_y+step_y*4+6)
	self.id_text:SetText("Id:")
	self.id_text:SetFont(small_font)

	self.id.OnValueChanged = function(obj, value)
		self:update_value_and_reload()
	end

	self.id:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.id:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.checkbox = loveframes.Create("checkbox", parent.panel_pixel_map_manual)
	self.checkbox:SetText("Set OnClick")
	self.checkbox:SetFont(small_font)
	self.checkbox:SetPos(8, start_y+step_y*7)


	self.inc = loveframes.Create("checkbox", parent.panel_pixel_map_manual)
	self.inc:SetText("Bump")
	self.inc:SetFont(small_font)
	self.inc:SetPos(8+88, start_y+step_y*5+4)

	self.checkbox.OnChanged = function(obj, value)
		self.inc:SetEnabled(value)
	end

	self.parent:reload()

	parent.panel_pixel_map_manual.Update = function(obj, dt)
		obj:SetHeight(tabs:GetHeight()-8)
	end
end

function pixel_map_manual:update_value_and_reload()
	self.parent:map_to_2d()
	self:update_2d_from_box()
	self.parent:map_from_2d()
	self.parent:reload()
end

function pixel_map_manual:update_2d_from_box()
	if not self.parent.map[self.parent.select_x+1] then self.parent.map[self.parent.select_x+1] = {} end
	self.parent.map[self.parent.select_x+1][self.parent.select_y+1] = {
		x = self.parent.select_x,
		y = self.parent.select_y,
		net = self.net:GetValue(),
		subnet = self.subnet:GetValue(),
		uni = self.uni:GetValue(),
		id = self.id:GetValue()
	}
end

function pixel_map_manual:click(x,y)
	if self.checkbox:GetChecked() then
		self:update_2d_from_box()
		self.parent:map_from_2d()
		self.parent:reload()
		self.id:SetValue(self.id:GetValue()+(self.inc:GetChecked() and 1 or 0))
		self.numberbox_x:SetValue(x)
		self.numberbox_y:SetValue(y)
	else
		self.numberbox_x:SetValue(x)
		self.numberbox_y:SetValue(y)
	end
end

function pixel_map_manual:update_box()
	if (self.parent.map[self.parent.select_x+1] and self.parent.map[self.parent.select_x+1][self.parent.select_y+1]) then
		self.net:SetValueRaw(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].net)
		self.subnet:SetValueRaw(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].subnet)
		self.uni:SetValueRaw(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].uni)
		self.id:SetValueRaw(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].id)
	else
		self.net:SetValueRaw(0)
		self.subnet:SetValueRaw(0)
		self.uni:SetValueRaw(0)
		self.id:SetValueRaw(-1)
	end
end

return pixel_map_manual
