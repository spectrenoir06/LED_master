local pixel_map_auto = {}
local small_font = love.graphics.newFont(10)

function pixel_map_auto:load(loveframes, frame, tabs, start_y, step_y, parent)

	self.parent = parent

	parent.panel_pixel_map_auto = loveframes.Create("panel")

	tabs:AddTab("Auto", parent.panel_pixel_map_auto, nil, "ressource/icons/map.png", function() self:preview() end, function()  self.parent:map_to_2d() self.parent:reload() end )
	local start_y = start_y-10
	local step_y = 21
	local setting_lx = 180

	self.numberbox_x = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.numberbox_x:SetPos(8, start_y+step_y*1)
	self.numberbox_x:SetSize(70, 25)
	self.numberbox_x:SetMinMax(0, mapping.lx-1)
	self.numberbox_x:SetValue(0)

	self.numberbox_x_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.numberbox_x_text:SetPos(8, start_y+step_y*0+6)
	self.numberbox_x_text:SetText("X:")
	self.numberbox_x_text:SetFont(small_font)

	self.numberbox_x.OnValueChanged = function(obj, value)
		self.parent.select_x = value
		self:preview()
	end

	self.numberbox_y = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.numberbox_y:SetPos(8+70+8, start_y+step_y*1)
	self.numberbox_y:SetSize(70, 25)
	self.numberbox_y:SetMinMax(0, mapping.ly-1)
	self.numberbox_y:SetValue(0)

	self.numberbox_y_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.numberbox_y_text:SetPos(8+85, start_y+step_y*0+6)
	self.numberbox_y_text:SetText("Y:")
	self.numberbox_y_text:SetFont(small_font)

	self.numberbox_y.OnValueChanged = function(obj, value)
		self.parent.select_y = value
		self:preview()
	end

	self.numberbox_lx = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.numberbox_lx:SetPos(8, start_y+step_y*3)
	self.numberbox_lx:SetSize(70, 25)
	self.numberbox_lx:SetMinMax(1, 9999)
	self.numberbox_lx:SetValue(self.parent.select_lx)

	self.numberbox_lx_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.numberbox_lx_text:SetPos(8, start_y+step_y*2+6)
	self.numberbox_lx_text:SetText("LX:")
	self.numberbox_lx_text:SetFont(small_font)

	self.numberbox_lx.OnValueChanged = function(obj, value)
		self.parent.select_lx = value
		self:preview()
	end

	self.numberbox_ly = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.numberbox_ly:SetPos(8+70+8, start_y+step_y*3)
	self.numberbox_ly:SetSize(70, 25)
	self.numberbox_ly:SetMinMax(1, 9999)
	self.numberbox_ly:SetValue(self.parent.select_ly)

	self.numberbox_ly_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.numberbox_ly_text:SetPos(8+70+8, start_y+step_y*2+6)
	self.numberbox_ly_text:SetText("LY:")
	self.numberbox_ly_text:SetFont(small_font)

	self.numberbox_ly.OnValueChanged = function(obj, value)
		self.parent.select_ly = value
		self:preview()
	end


	self.net = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.net:SetPos(8, start_y+step_y*5)
	self.net:SetSize(100, 25)
	self.net:SetWidth(60)
	self.net:SetMinMax(0, 127)
	self.net:SetValue(0)

	self.net_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.net_text:SetPos(8, start_y+step_y*4+8)
	self.net_text:SetText("Net:")
	self.net_text:SetFont(small_font)

	self.net:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.net:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.subnet = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.subnet:SetPos(8+59, start_y+step_y*5)
	self.subnet:SetSize(100, 25)
	self.subnet:SetWidth(45)
	self.subnet:SetMinMax(0, 15)
	self.subnet:SetValue(0)

	self.subnet_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.subnet_text:SetPos(8+59, start_y+step_y*4+8)
	self.subnet_text:SetText("Subnet:")
	self.subnet_text:SetFont(small_font)

	self.subnet:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.subnet:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.uni = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.uni:SetPos(8+103, start_y+step_y*5)
	self.uni:SetSize(100, 25)
	self.uni:SetWidth(45)
	self.uni:SetMinMax(0, 15)
	self.uni:SetValue(0)

	self.uni_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.uni_text:SetPos(8+103, start_y+step_y*4+8)
	self.uni_text:SetText("Uni:")
	self.uni_text:SetFont(small_font)

	self.uni.OnValueChanged = function(obj, value)
		self:preview()
	end

	self.uni:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.uni:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.id = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.id:SetPos(8, start_y+step_y*7)
	self.id:SetSize(70, 25)
	self.id:SetMinMax(0, 9999)
	self.id:SetValue(0)

	self.id_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.id_text:SetPos(8, start_y+step_y*6+6)
	self.id_text:SetText("Id Start:")
	self.id_text:SetFont(small_font)

	self.id.OnValueChanged = function(obj, value)
		self:preview()
	end

	self.id:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.id:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.id_max = loveframes.Create("numberbox", parent.panel_pixel_map_auto)
	self.id_max:SetPos(8+70+8, start_y+step_y*7)
	self.id_max:SetSize(70, 25)
	self.id_max:SetMinMax(0, 9999)
	self.id_max:SetValue(170)


	self.id_max_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.id_max_text:SetPos(8+70+8, start_y+step_y*6+6)
	self.id_max_text:SetText("Id max:")
	self.id_max_text:SetFont(small_font)

	self.id_max.OnValueChanged = function(obj, value)
		self:preview()
	end

	self.id_max:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.id_max:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.mode = loveframes.Create("multichoice", parent.panel_pixel_map_auto)
	self.mode:SetPos(8, start_y+step_y*9)
	self.mode:SetSize(70, 25)
	self.mode:AddChoice("Line H")
	self.mode:AddChoice("Line V")
	self.mode:AddChoice("Snake H")
	self.mode:AddChoice("Snake V")

	self.mode:SetChoice("Line H")


	self.mode_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.mode_text:SetPos(8, start_y+step_y*8+6)
	self.mode_text:SetText("Mode:")
	self.mode_text:SetFont(small_font)

	self.mode.OnChoiceSelected = function(obj, value)
		self:preview()
	end

	self.start = loveframes.Create("multichoice", parent.panel_pixel_map_auto)
	self.start:SetPos(8+70+8, start_y+step_y*9)
	self.start:SetSize(70, 25)
	self.start:AddChoice("UP/LEFT")
	self.start:AddChoice("UP/RIGHT")
	self.start:AddChoice("DOWN/LEFT")
	self.start:AddChoice("DOWN/RIGHT")

	self.start:SetChoice("UP/LEFT")


	self.start_text = loveframes.Create("text", parent.panel_pixel_map_auto)
	self.start_text:SetPos(8+70+8, start_y+step_y*8+6)
	self.start_text:SetText("Start:")
	self.start_text:SetFont(small_font)

	self.start.OnChoiceSelected = function(obj, value)
		self:preview()
	end


	self.button_set = loveframes.Create("button", parent.panel_pixel_map_auto)
	self.button_set:SetWidth(60)
	self.button_set:SetText("Set")
	self.button_set:SetImage("ressource/icons/map--pencil.png")
	self.button_set:SetPos(8, start_y+step_y*10+8)

	self.button_set.OnClick = function(object, x, y)
		self.parent:map_from_2d()
		self.parent:reload()
	end

	parent.panel_pixel_map_auto.Update = function(obj, dt)
		obj:SetHeight(tabs:GetHeight()-8)
	end

	self.parent:reload()
end

function pixel_map_auto:update_value()
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

function pixel_map_auto:click(x,y)
	self.numberbox_x:SetValue(x)
	self.numberbox_y:SetValue(y)
	self:preview()
end

function pixel_map_auto:preview()
	self.parent:map_to_2d()

	local off_x, off_y = self.parent.select_x, self.parent.select_y

	local start = self.start:GetValue()
	local mode = self.mode:GetValue()

	function set(px,py,id)
		if not self.parent.map[off_x+px] then self.parent.map[off_x+px] = {} end
		local id_c = id%self.id_max:GetValue()
		local uni = self.uni:GetValue()+math.floor(id/self.id_max:GetValue())

		self.parent.map[off_x+px][off_y+py] = {
			x = off_x+px-1,
			y = off_y+py-1,
			net = self.net:GetValue(),
			subnet = self.subnet:GetValue(),
			uni = uni,--self.uni:GetValue(),
			id = id_c,--self.id:GetValue()
		}
	end
	local id = self.id:GetValue()

	local px_start
	local px_end
	local px_inc

	local py_start
	local py_end
	local py_inc

	local is_up = start == "UP/LEFT" or start == "UP/RIGHT"
	local is_down =  not is_up
	local is_left = start == "UP/LEFT" or start == "DOWN/LEFT"
	local is_right =  not is_left

	if is_left then -- LEFT
		px_start = 1
		px_end = self.parent.select_lx
		px_inc = 1
	else	-- RIGHT
		px_start = self.parent.select_lx
		px_end = 1
		px_inc = -1
	end

	if is_up then -- UP
		py_start = 1
		py_end = self.parent.select_ly
		py_inc = 1
	else	-- DOWN
		py_start = self.parent.select_ly
		py_end = 1
		py_inc = -1
	end

	if mode == "Line H" or mode == "Snake H" then
		for py=py_start, py_end, py_inc do
			local p = is_up and py or py-self.parent.select_ly+1
			if p%2 == 0 and mode == "Snake H" then
				for px=px_end, px_start, px_inc*-1 do
					set(px,py,id)
					id=id+1
				end
			else
				for px=px_start, px_end, px_inc do
					set(px,py,id)
					id=id+1
				end
			end
		end
	elseif mode == "Line V" or mode == "Snake V"  then
		for px=px_start, px_end, px_inc do
			local p = is_left and px or px-self.parent.select_lx+1
			if p%2 == 0 and mode == "Snake V" then
				for py=py_end, py_start, py_inc*-1 do
					set(px,py,id)
					id=id+1
				end
			else
				for py=py_start, py_end, py_inc do
					set(px,py,id)
					id=id+1
				end
			end
		end
	end

	self.parent:reload()
end

function pixel_map_auto:update_select()
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

return pixel_map_auto
