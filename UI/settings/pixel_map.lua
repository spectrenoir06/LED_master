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
	for k,v in ipairs(mapping.map) do
		local ur,ug,ub = hslToRgb((v.uni/7)%1,1,0.6)
		local ir,ig,ib = hslToRgb(v.id/100,1,0.4)
		-- local text = {
		-- 	{color = {ur, ug, ub}, font = small_font},
		-- 	"Uni:"..v.uni,
		-- 	{color = {ir, ig, ib}, font = small_font},
		-- 	"\nID:"..v.id,
		-- }
		-- local text1 = loveframes.Create("text")
		-- text1:SetText(text)

		love.graphics.setColor(ur, ug, ub)
		love.graphics.rectangle("fill", v.x*24, v.y*24, 24, 24)
		-- love.graphics.print("Uni:"..v.uni, v.x*24, v.y*24)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("line", v.x*24, v.y*24, 24, 24)
		-- love.graphics.setColor(ir, ig, ib)
		love.graphics.print(v.id, v.x*24-small_font:getWidth(v.id)/2+12, v.y*24+5)
	end
	love.graphics.setCanvas()
end

return pixel_map
