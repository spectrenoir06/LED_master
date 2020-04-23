local pixel_map = {}
local small_font = love.graphics.newFont(10)

function pixel_map:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_pixel_map = loveframes.Create("panel")
	self.panel_pixel = loveframes.Create("map", self.panel_pixel_map)
	self.panel_setting = loveframes.Create("panel", self.panel_pixel_map)

	tabs:AddTab("Pixel map", self.panel_pixel_map, nil, "ressource/icons/map.png", function() self:reload() end)


	self.select_x = 0
	self.select_y = 0
	local step_y = 25


	self.panel_pixel.Draw = function(object)
		local x = object.x
		local y = object.y
		local width = object.width
		local height = object.height
		local stencilfunc = function()
			love.graphics.rectangle("fill", x, y, width, height)
		end

		love.graphics.stencil(stencilfunc)
		love.graphics.setStencilTest("greater", 0)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(self.cv, x, y)

			love.graphics.setColor(1,1,1,0.6)
			love.graphics.rectangle("fill", x+self.select_x*24+1, y+self.select_y*24+1, 22, 22)
		love.graphics.setStencilTest()
	end

	self.panel_pixel.OnPixelClick = function(obj,x,y)
		if x>=0 and y >=0 and x < mapping.lx and y < mapping.ly then
			-- print(x,y, self.map[x+1][y+1].id,self.map[x+1][y+1].uni)
			self.select_x = x
			self.select_y = y
			self.numberbox_x:SetValue(x)
			self.numberbox_y:SetValue(y)
			self:update_select()
		end
	end

	local setting_lx = 180

	self.panel_pixel_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_setting:SetSize(setting_lx, self.panel_pixel_map:GetHeight())
	self.panel_pixel:SetSize(self.panel_pixel_map:GetWidth(), self.panel_pixel_map:GetHeight())

	-- local form = loveframes.Create("form", self.panel_setting)
	-- form:SetPos(5, 5)
	-- form:SetSize(self.panel_setting:GetWidth()-10, 65)
	-- form:SetLayoutType("horizontal")
	-- form:SetName("Matrix settings")

	self.numberbox_x = loveframes.Create("numberbox", self.panel_setting)
	self.numberbox_x:SetPos(8+15, start_y+step_y*0)
	self.numberbox_x:SetSize(100, 25)
	self.numberbox_x:SetWidth(self.panel_setting:GetWidth()-16-100)
	self.numberbox_x:SetMinMax(0, mapping.lx-1)
	self.numberbox_x:SetValue(0)

	self.numberbox_x_text = loveframes.Create("text", self.panel_setting)
	self.numberbox_x_text:SetPos(8, start_y+step_y*0+6)
	self.numberbox_x_text:SetText("X:")
	self.numberbox_x_text:SetFont(small_font)

	self.numberbox_x.OnValueChanged = function(obj, value)
		self.select_x = value
		self:update_select()
	end

	self.numberbox_y = loveframes.Create("numberbox", self.panel_setting)
	self.numberbox_y:SetPos(8+15+85, start_y+step_y*0)
	self.numberbox_y:SetSize(100, 25)
	self.numberbox_y:SetWidth(self.panel_setting:GetWidth()-16-100)
	self.numberbox_y:SetMinMax(0, mapping.ly-1)
	self.numberbox_y:SetValue(0)

	self.numberbox_y_text = loveframes.Create("text", self.panel_setting)
	self.numberbox_y_text:SetPos(8+85, start_y+step_y*0+6)
	self.numberbox_y_text:SetText("Y:")
	self.numberbox_y_text:SetFont(small_font)

	self.numberbox_y.OnValueChanged = function(obj, value)
		self.select_y = value
		self:update_select()
	end


	self.net = loveframes.Create("numberbox", self.panel_setting)
	self.net:SetPos(8, start_y+step_y*2)
	self.net:SetSize(100, 25)
	self.net:SetWidth(60)
	self.net:SetMinMax(0, 127)
	self.net:SetValue(0)

	self.net_text = loveframes.Create("text", self.panel_setting)
	self.net_text:SetPos(8, start_y+step_y*1+8)
	self.net_text:SetText("Net:")
	self.net_text:SetFont(small_font)

	self.net:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.net:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.subnet = loveframes.Create("numberbox", self.panel_setting)
	self.subnet:SetPos(8+67, start_y+step_y*2)
	self.subnet:SetSize(100, 25)
	self.subnet:SetWidth(45)
	self.subnet:SetMinMax(0, 15)
	self.subnet:SetValue(0)

	self.subnet_text = loveframes.Create("text", self.panel_setting)
	self.subnet_text:SetPos(8+67, start_y+step_y*1+8)
	self.subnet_text:SetText("Subnet:")
	self.subnet_text:SetFont(small_font)

	self.subnet:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.subnet:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.uni = loveframes.Create("numberbox", self.panel_setting)
	self.uni:SetPos(8+120, start_y+step_y*2)
	self.uni:SetSize(100, 25)
	self.uni:SetWidth(45)
	self.uni:SetMinMax(0, 15)
	self.uni:SetValue(0)

	self.uni_text = loveframes.Create("text", self.panel_setting)
	self.uni_text:SetPos(8+120, start_y+step_y*1+8)
	self.uni_text:SetText("Uni:")
	self.uni_text:SetFont(small_font)

	self.uni:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.uni:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.id = loveframes.Create("numberbox", self.panel_setting)
	self.id:SetPos(8+20, start_y+step_y*4)
	self.id:SetSize(100, 25)
	self.id:SetWidth(self.panel_setting:GetWidth()-16-100)
	self.id:SetMinMax(1, 2048)
	self.id:SetValue(0)

	self.id_text = loveframes.Create("text", self.panel_setting)
	self.id_text:SetPos(8, start_y+step_y*4+6)
	self.id_text:SetText("Id:")
	self.id_text:SetFont(small_font)

	self.id:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.id:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.button_set = loveframes.Create("button", self.panel_setting)
	self.button_set:SetWidth(60)
	self.button_set:SetText("Set")
	self.button_set:SetImage("ressource/icons/map--pencil.png")
	self.button_set:SetPos(8+100, start_y+step_y*4)

	self.button_set.OnClick = function(object, x, y)
		if not self.map[self.select_x+1] then self.map[self.select_x+1] = {} end
		self.map[self.select_x+1][self.select_y+1] = {
			x = self.select_x,
			y = self.select_y,
			net = self.net:GetValue(),
			subnet = self.subnet:GetValue(),
			uni = self.uni:GetValue(),
			id = self.id:GetValue()
		}
		pixel_map:genMap()
		self:reload()
	end


	self.panel_pixel_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.panel_pixel:SetSize(object:GetWidth()-setting_lx, object:GetHeight())
		self.panel_setting:SetPos(self.panel_pixel:GetWidth(), 0)
		self.panel_setting:SetSize(setting_lx, self.panel_pixel_map:GetHeight())
	end

	self:reload()
end

function pixel_map:update_select()
	if (self.map[self.select_x+1] and self.map[self.select_x+1][self.select_y+1]) then
		self.net:SetValue(self.map[self.select_x+1][self.select_y+1].net)
		self.subnet:SetValue(self.map[self.select_x+1][self.select_y+1].subnet)
		self.uni:SetValue(self.map[self.select_x+1][self.select_y+1].uni)
		self.id:SetValue(self.map[self.select_x+1][self.select_y+1].id)
	else
		self.net:SetValue(0)
		self.subnet:SetValue(0)
		self.uni:SetValue(0)
		self.id:SetValue(0)
	end
end

function pixel_map:genMap()
	mapping.map = {}
	for x=1,mapping.lx do
		for y=1,mapping.ly do
			local v
			if self.map[x] then
				v = self.map[x][y]
			end
			if v then
				table.insert(mapping.map, v)
			end
		end
	end

end

function pixel_map:reload()
	love.graphics.setFont(small_font)
	self.cv = love.graphics.newCanvas(24*mapping.lx, 24*mapping.ly)
	love.graphics.setCanvas(self.cv)
	local l = 0.8

	self.numberbox_x:SetMinMax(0, mapping.lx-1)
	self.numberbox_y:SetMinMax(0, mapping.ly-1)

	self.map = {}

	for k,v in ipairs(mapping.map) do
		if not self.map[v.x+1] then
			self.map[v.x+1] = {}
		end
		self.map[v.x+1][v.y+1] = v
	end

	for x=1,mapping.lx do
		for y=1,mapping.ly do
			local v
			if self.map[x] then
				v = self.map[x][y]
			end
			if v then
				local ur,ug,ub = hslToRgb((v.uni/8)%1,1,l-( (v.id%170)/170) * (l * 0.8) )

				love.graphics.setColor(ur, ug, ub)
				love.graphics.rectangle("fill", v.x*24, v.y*24, 24, 24)
				love.graphics.setColor(0.2,0.2,0.2,1)
				love.graphics.rectangle("line", v.x*24, v.y*24, 24, 24)
				love.graphics.setColor(0,0,0,1)
				love.graphics.print(v.id, v.x*24-small_font:getWidth(v.id)/2+12+1, v.y*24+5+1)
				love.graphics.setColor(1,1,1,1)
				love.graphics.print(v.id, v.x*24-small_font:getWidth(v.id)/2+12, v.y*24+5)
			else
				love.graphics.setColor(0.85,0.85,0.85)
				love.graphics.rectangle("fill", (x-1)*24, (y-1)*24, 24, 24)
				love.graphics.setColor(0.2,0.2,0.2,1)
				love.graphics.rectangle("line", (x-1)*24, (y-1)*24, 24, 24)
			end
		end
	end
	love.graphics.setCanvas()
end

return pixel_map
