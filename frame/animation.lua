local animation = {}

function animation:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("Animation")
	frame:SetSize(300, 300)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	local panel = loveframes.Create("panel", frame)
	panel:SetPos(4, 28)
	panel:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)

	panel.Draw = function(object)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(
			canvas,
			object:GetX(),
			object:GetY(),
			0,
			(object:GetWidth())/lx,
			(object:GetHeight())/ly
		)
	end

	panel.Update = function(object)
		object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
	end
end

return animation
