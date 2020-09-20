require "lib.dither"

local animation = {}

function animation:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Animation")

	local lx, ly = love.graphics.getDimensions()

	frame:SetSize(lx, 250)

	frame:SetPos(0, 30)
	frame:SetScreenLocked(true)
	frame:SetAlwaysUpdate(true)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	frame:SetDockable(true)

	frame:SetIcon("ressource/icons/television-test.png")

	low_fps = love.graphics.newImage("ressource/icons/dashboard--exclamation.png")

	local panel = loveframes.Create("panel", frame)
	panel:SetPos(4, 28)
	panel:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)

	panel.Draw = function(object)
		-- local b = 0.5 + shaders_param.bright / 2
		local b = 1
		local img = nil
		if false then
			local data = canvas:newImageData()
			dither_fs(data, 5, 6, 5)
			img = love.graphics.newImage(data)
		end

		love.graphics.setColor(b, b, b)
		love.graphics.draw(
			img or canvas,
			object:GetX(),
			object:GetY(),
			0,
			(object:GetWidth())/canvas:getWidth(),
			(object:GetHeight())/canvas:getHeight()
		)
		local lx, ly = canvas:getDimensions()
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(lx.."x"..ly.." FPS: "..love.timer.getFPS(), object:GetX()+5+1, object:GetY()+5+1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(lx.."x"..ly.." FPS: "..love.timer.getFPS(), object:GetX()+5, object:GetY()+5)

		if love.timer.getFPS() < mapping.fps-2 then
			love.graphics.draw(low_fps, object:GetX()+object:GetWidth()-low_fps:getWidth()*2-8, object:GetY()+8,0,2,2)
		end
	end

	panel.Update = function(object)
		object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
	end


end

return animation
