local shader = {}

function shader:load(loveframes, frame, tabs, start_y, step_y)

	local small_font = love.graphics.newFont(10)

	local panel_shader = loveframes.Create("panel")

	tabs:AddTab("Shader", panel_shader, nil, "ressource/icons/spectrum.png")
	local choice_shader = loveframes.Create("multichoice", panel_shader)
	choice_shader:SetPos(8, start_y+step_y*0)
	choice_shader:SetSize(panel_shader:GetWidth()-16, 25)

	local slider_speed = loveframes.Create("slider", panel_shader)
	slider_speed:SetPos(100, start_y+step_y*1)
	slider_speed:SetWidth(panel_shader:GetWidth()-100-8)
	slider_speed:SetMinMax(0.0, 10)
	slider_speed:SetValue(1)

	local slider_speed_text = loveframes.Create("text", panel_shader)
	slider_speed_text:SetPos(8, start_y+step_y*1+4)
	slider_speed_text:SetText("Speed: "..slider_speed:GetValue())
	slider_speed_text:SetFont(small_font)

	slider_speed.OnValueChanged = function(object)
		slider_speed_text:SetText("Speed: "..math.floor(slider_speed:GetValue()*100)/100)
		shaders_param.speed = slider_speed:GetValue()
	end

	local slider_density = loveframes.Create("slider", panel_shader)
	slider_density:SetPos(100, start_y+step_y*2)
	slider_density:SetWidth(panel_shader:GetWidth()-100-8)
	slider_density:SetMinMax(0.0, 4)
	slider_density:SetValue(1)

	local slider_density_text = loveframes.Create("text", panel_shader)
	slider_density_text:SetPos(8, start_y+step_y*2+4)
	slider_density_text:SetText("Density: "..slider_density:GetValue())
	slider_density_text:SetFont(small_font)

	slider_density.OnValueChanged = function(object)
		slider_density_text:SetText("Density: "..math.floor(slider_density:GetValue()*100)/100)
		shaders_param.density = slider_density:GetValue()
	end

	for k,v in ipairs(shaders) do
		choice_shader:AddChoice(v.name)
	end

	panel_shader.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_shader:SetSize(panel_shader:GetWidth()-16, 25)
		slider_speed:SetWidth(panel_shader:GetWidth()-100-8)
		slider_density:SetWidth(panel_shader:GetWidth()-100-8)

		love.graphics.setCanvas(canvas)
			love.graphics.setColor(1,1,1,1)
			love.graphics.setShader(shaders[shader_nb].shader)
				love.graphics.draw(canvas_test,0,0)
			love.graphics.setShader()
		love.graphics.setCanvas()
	end

	choice_shader.OnChoiceSelected = function(object, choice)
		for k,v in ipairs(shaders) do
			if v.name == choice then
				shader_nb = k
			end
		end
	end
	choice_shader:SelectChoice("julia.glsl")


end

return shader
