local player = {}

function player:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("Player")
	frame:SetSize(300, 300)
	frame:SetPos(300,0)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	local multichoice = loveframes.Create("multichoice", frame)
	multichoice:SetPos(5, 30)



	for k,v in ipairs(shaders) do
		multichoice:AddChoice(v.name)
	end
	multichoice:AddChoice("Music")


	multichoice.OnChoiceSelected = function(object, choice)
		print(choice .. " was selected.")
		if choice == "Music" then

			return
		else

		end
		for k,v in ipairs(shaders) do
			if v.name == choice then
				shader_nb = k
			end
		end
	end
	-- object:SetChoice(choice[string])

	frame.Update = function(object, dt)
		-- print(1/dt)
		love.graphics.setColor(1,1,1,1)
		love.graphics.setCanvas(canvas)
			-- love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.setShader(shaders[shader_nb].shader)
				love.graphics.draw(canvas_test,0,0)
			love.graphics.setShader()
		love.graphics.setCanvas()
	end

end

return player
