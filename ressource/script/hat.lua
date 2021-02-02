local hat = {}

local files = love.filesystem.getDirectoryItems("ressource/image/hat")
local select = 1
local imgs = {}
local is_down = false


for k,v in ipairs(files) do
	table.insert(imgs, love.graphics.newImage("ressource/image/hat/"..v))
end


function hat:update(dt, lx, ly)
	local kx = lx / imgs[select]:getWidth()
	local ky = ly / imgs[select]:getHeight()
	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(imgs[select], 0, 0, 0, kx, ky)

	if love.keyboard.isDown("q") and select > 1 then
		if not is_down then
			select = select - 1
		end
		is_down = true
	elseif love.keyboard.isDown("w") and select < #imgs then
		if not is_down then
			select = select + 1
		end
		is_down = true
	else
		is_down = false
	end

end

return hat
