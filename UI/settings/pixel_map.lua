local pixel_map = {}

function pixel_map:load(loveframes, frame, tabs, start_y, step_y)

	self.panel_pixel_map = loveframes.Create("panel")
	self.panel_test = loveframes.Create("panel", self.panel_pixel_map)

	tabs:AddTab("Pixel map", self.panel_pixel_map, nil, "ressource/icons/map.png", function() self:reload() end)


	-- self:reload()


	self.panel_test.draw = function(object)
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

		love.graphics.setStencilTest()
	end

	self.panel_pixel_map:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
	self.panel_test:SetSize(self.panel_pixel_map:GetWidth(), self.panel_pixel_map:GetHeight())

	self.panel_pixel_map.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.panel_test:SetSize(object:GetWidth(), object:GetHeight())
	end

end

function pixel_map:reload()
	local small_font = love.graphics.newFont(10)
	love.graphics.setFont(small_font)
	self.cv = love.graphics.newCanvas(24*mapping.lx, 24*mapping.ly)
	love.graphics.setCanvas(self.cv)
	local l = 0.8
	for k,v in ipairs(mapping.map) do
		local ur,ug,ub = hslToRgb((v.uni/8)%1,1,l-( (v.id%170)/170) * (l * 0.8) )

		love.graphics.setColor(ur, ug, ub)
		love.graphics.rectangle("fill", v.x*24, v.y*24, 24, 24)
		love.graphics.setColor(0.2,0.2,0.2,1)
		love.graphics.rectangle("line", v.x*24, v.y*24, 24, 24)
		love.graphics.setColor(0,0,0,1)
		love.graphics.print(v.id, v.x*24-small_font:getWidth(v.id)/2+12+1, v.y*24+5+1)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(v.id, v.x*24-small_font:getWidth(v.id)/2+12, v.y*24+5)
	end
	love.graphics.setCanvas()
end

return pixel_map
