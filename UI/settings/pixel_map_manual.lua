local pixel_map_manual = {}
local small_font = love.graphics.newFont(10)

function pixel_map_manual:load(loveframes, frame, tabs, start_y, step_y, parent)

	self.parent = parent

	parent.panel_pixel_map_manual = loveframes.Create("panel")

	tabs:AddTab("Manual", parent.panel_pixel_map_manual, nil, "ressource/icons/map.png")
	local step_y = 25
	local setting_lx = 180

	self.numberbox_x = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.numberbox_x:SetPos(8+15, start_y+step_y*0)
	self.numberbox_x:SetSize(100, 25)
	self.numberbox_x:SetWidth(parent.panel_pixel_map_manual:GetWidth()-16-100)
	self.numberbox_x:SetMinMax(0, mapping.lx-1)
	self.numberbox_x:SetValue(0)

	self.numberbox_x_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.numberbox_x_text:SetPos(8, start_y+step_y*0+6)
	self.numberbox_x_text:SetText("X:")
	self.numberbox_x_text:SetFont(small_font)

	self.numberbox_x.OnValueChanged = function(obj, value)
		self.select_x = value
		self:update_select()
	end

	self.numberbox_y = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.numberbox_y:SetPos(8+15+85, start_y+step_y*0)
	self.numberbox_y:SetSize(100, 25)
	self.numberbox_y:SetWidth(parent.panel_pixel_map_manual:GetWidth()-16-100)
	self.numberbox_y:SetMinMax(0, mapping.ly-1)
	self.numberbox_y:SetValue(0)

	self.numberbox_y_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.numberbox_y_text:SetPos(8+85, start_y+step_y*0+6)
	self.numberbox_y_text:SetText("Y:")
	self.numberbox_y_text:SetFont(small_font)

	self.numberbox_y.OnValueChanged = function(obj, value)
		self.select_y = value
		self:update_select()
	end


	self.net = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.net:SetPos(8, start_y+step_y*2)
	self.net:SetSize(100, 25)
	self.net:SetWidth(60)
	self.net:SetMinMax(0, 127)
	self.net:SetValue(0)

	self.net_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.net_text:SetPos(8, start_y+step_y*1+8)
	self.net_text:SetText("Net:")
	self.net_text:SetFont(small_font)

	self.net:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.net:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.subnet = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.subnet:SetPos(8+59, start_y+step_y*2)
	self.subnet:SetSize(100, 25)
	self.subnet:SetWidth(45)
	self.subnet:SetMinMax(0, 15)
	self.subnet:SetValue(0)

	self.subnet_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.subnet_text:SetPos(8+67, start_y+step_y*1+8)
	self.subnet_text:SetText("Subnet:")
	self.subnet_text:SetFont(small_font)

	self.subnet:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.subnet:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.uni = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.uni:SetPos(8+103, start_y+step_y*2)
	self.uni:SetSize(100, 25)
	self.uni:SetWidth(45)
	self.uni:SetMinMax(0, 15)
	self.uni:SetValue(0)

	self.uni_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.uni_text:SetPos(8+120, start_y+step_y*1+8)
	self.uni_text:SetText("Uni:")
	self.uni_text:SetFont(small_font)

	self.uni:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.uni:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.id = loveframes.Create("numberbox", parent.panel_pixel_map_manual)
	self.id:SetPos(8+20, start_y+step_y*4)
	self.id:SetSize(100, 25)
	self.id:SetWidth(parent.panel_pixel_map_manual:GetWidth()-16-100)
	self.id:SetMinMax(0, 9999)
	self.id:SetValue(0)

	self.id_text = loveframes.Create("text", parent.panel_pixel_map_manual)
	self.id_text:SetPos(8, start_y+step_y*4+6)
	self.id_text:SetText("Id:")
	self.id_text:SetFont(small_font)

	self.id:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.id:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.button_set = loveframes.Create("button", parent.panel_pixel_map_manual)
	self.button_set:SetWidth(60)
	self.button_set:SetText("Set")
	self.button_set:SetImage("ressource/icons/map--pencil.png")
	self.button_set:SetPos(8+80, start_y+step_y*4)

	self.button_set.OnClick = function(object, x, y)
		self:update_value()
		self.parent:map_from_2d()
		self.parent:reload()
	end

	self.parent:reload()
end

function pixel_map_manual:update_value()
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
	print("click")
	self.numberbox_x:SetValue(x)
	self.numberbox_y:SetValue(y)
	-- self:update_select()
end

function pixel_map_manual:update_select()
	if (self.parent.map[self.parent.select_x+1] and self.parent.map[self.parent.select_x+1][self.parent.select_y+1]) then
		self.net:SetValue(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].net)
		self.subnet:SetValue(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].subnet)
		self.uni:SetValue(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].uni)
		self.id:SetValue(self.parent.map[self.parent.select_x+1][self.parent.select_y+1].id)
	else
		self.net:SetValue(0)
		self.subnet:SetValue(0)
		self.uni:SetValue(0)
		self.id:SetValue(0)
	end

end

return pixel_map_manual
