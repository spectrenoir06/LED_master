local pixel_map = {}
local small_font = love.graphics.newFont(10)

function pixel_map:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_pixel_map = loveframes.Create("panel")
	self.panel_pixel = loveframes.Create("map", self.panel_pixel_map)
	self.panel_setting = loveframes.Create("panel", self.panel_pixel_map)

	tabs:AddTab("Pixel map", self.panel_pixel_map, nil, "ressource/icons/map.png", function() self:map_to_2d() self:reload() if(self.tabs_settings:GetTabNumber()==2) then self.pixel_map_auto:preview() end end)

	self.select_x = 0
	self.select_y = 0
	self.select_lx = 10
	self.select_ly = 10
	local step_y = 25
	local setting_lx = 180

	self.panel_pixel_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_setting:SetSize(setting_lx, self.panel_pixel_map:GetHeight())
	self.panel_pixel:SetSize(self.panel_pixel_map:GetWidth(), self.panel_pixel_map:GetHeight())

	self.tabs_settings = loveframes.Create("tabs", self.panel_setting)
	self.tabs_settings:SetPos(4, 4)
	self.tabs_settings:SetSize(self.panel_setting:GetWidth()-8, self.panel_setting:GetHeight()-26-4)
	self.tabs_settings.Update = function(object, dt)
		self.tabs_settings:SetSize(self.panel_setting:GetWidth()-8, self.panel_setting:GetHeight()-26-4)
	end

	-- local panel = loveframes.Create("panel")
	-- self.tabs_settings:AddTab("Manual", panel, nil, "ressource/icons/map.png")
	-- self.tabs_settings:AddTab("Auto", panel, nil, "ressource/icons/map.png")

	self:map_to_2d()
	self:reload()

	self.pixel_map_manual	= require "UI.settings.pixel_map_manual"
	self.pixel_map_auto		= require "UI.settings.pixel_map_auto"

	self.pixel_map_manual:load(loveframes, frame, self.tabs_settings, start_y, step_y, self)
	self.pixel_map_auto:load(loveframes, frame, self.tabs_settings, start_y, step_y, self)

	self.panel_pixel_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.panel_pixel:SetSize(object:GetWidth()-setting_lx, object:GetHeight())
		self.panel_setting:SetPos(self.panel_pixel:GetWidth(), 0)
		self.panel_setting:SetSize(setting_lx, self.panel_pixel_map:GetHeight())
	end

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
			local tab_nb = self.tabs_settings:GetTabNumber()
			if tab_nb == 1 then
				love.graphics.rectangle("fill", x+self.select_x*24+1, y+self.select_y*24+1, 24-2, 24-2)
			elseif tab_nb == 2 then
				love.graphics.rectangle("fill", x+self.select_x*24+1, y+self.select_y*24+1, 24*self.select_lx-2, 24*self.select_ly-2)
			end
		love.graphics.setStencilTest()
	end

	self.panel_pixel.OnPixelClick = function(obj,x,y)
		if x>=0 and y >=0 and x < mapping.lx and y < mapping.ly then
			self.select_x = x
			self.select_y = y
			local tab_nb = self.tabs_settings:GetTabNumber()
			if tab_nb == 1 then
				self.pixel_map_manual:click(x,y)
			elseif tab_nb == 2 then
				self.pixel_map_auto:click(x,y)
			end
		end
	end

	self:map_to_2d()
	self:reload()
end

function pixel_map:map_from_2d()
	mapping.map = {}
	for y=1,mapping.ly do
		for x=1,mapping.lx do
			local v
			if self.map[x] then
				v = self.map[x][y]
			end
			if v and v.id ~= -1 then
				table.insert(mapping.map, v)
			end
		end
	end
end

function pixel_map:map_to_2d()
	self.map = {}
	for k,v in ipairs(mapping.map) do
		if not self.map[v.x+1] then
			self.map[v.x+1] = {}
		end
		self.map[v.x+1][v.y+1] = v
	end
end

function pixel_map:reload()
	love.graphics.setFont(small_font)
	self.cv = love.graphics.newCanvas(24*mapping.lx, 24*mapping.ly)
	love.graphics.setCanvas(self.cv)
	local l = 0.8

	local channel_data = love.thread.getChannel("data")
	channel_data:push({type = "map", data = mapping.map})

	for x=1,mapping.lx do
		for y=1,mapping.ly do
			local v
			if self.map[x] then
				v = self.map[x][y]
			end
			if v and v.id ~=-1 then
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
