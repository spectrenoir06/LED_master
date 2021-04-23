local shader = {}

function shader:load(loveframes, frame, tabs, start_y, step_y)

	local small_font = love.graphics.newFont(10)

	panel_shader = loveframes.Create("panel")
	

	tabs:AddTab("Shader", panel_shader, nil, "ressource/icons/spectrum.png")
	local choice_shader = loveframes.Create("multichoice", panel_shader)
	choice_shader:SetPos(8, start_y+step_y*0)
	choice_shader:SetSize(panel_shader:GetWidth()-16, 25)
	
	self.param_panel = loveframes.Create("panel", panel_shader)
	self.param_panel:SetPos(0, start_y+step_y*1)
	self.param_panel:SetSize(panel_shader:GetWidth(), panel_shader:GetHeight()-(start_y+step_y*0))

	-- local slider_density = loveframes.Create("slider", panel_shader)
	-- slider_density:SetPos(100, start_y+step_y*2)
	-- slider_density:SetWidth(panel_shader:GetWidth()-100-8)
	-- slider_density:SetMinMax(0.0, 4)
	-- slider_density:SetValue(1)

	-- local slider_density_text = loveframes.Create("text", panel_shader)
	-- slider_density_text:SetPos(8, start_y+step_y*2+4)
	-- slider_density_text:SetText("Density: "..slider_density:GetValue())
	-- slider_density_text:SetFont(small_font)

	-- slider_density.OnValueChanged = function(object)
	-- 	slider_density_text:SetText("Density: "..math.floor(slider_density:GetValue()*100)/100)
	-- 	shaders_param.density = slider_density:GetValue()
	-- end

	for k,v in ipairs(shaders) do
		choice_shader:AddChoice(v.name)
	end

	panel_shader.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_shader:SetSize(panel_shader:GetWidth()-16, 25)
		-- slider_speed:SetWidth(panel_shader:GetWidth()-100-8)
		-- slider_density:SetWidth(panel_shader:GetWidth()-100-8)
		self.param_panel:SetSize(panel_shader:GetWidth(), panel_shader:GetHeight()-(start_y+step_y*1))

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
				self.param_panel:Remove()
				self.param_panel = loveframes.Create("panel", panel_shader)
				self.param_panel:SetPos(0, start_y+step_y*1)

				for i,j in ipairs(v.param) do
					-- print(i,j)
					j.param_text = loveframes.Create("text", self.param_panel)
					j.param_text:SetPos(8, step_y*(i-1)+4)
					j.param_text:SetText(j.name..": "..math.floor(j.value*100)/100)
					j.param_text:SetFont(small_font)
					
					j.param_slider = loveframes.Create("slider", self.param_panel)
					j.param_slider:SetPos(100, step_y*(i-1)+4)
					j.param_slider:SetWidth(self.param_panel:GetWidth()-100-8)
						-- j.param_slider:SetMinMax(0.0, 10)
					j.param_slider:SetMax(j.max or 100)
					j.param_slider:SetMin(j.min or 0)
					j.param_slider:SetValue(j.default or 1)

					j.param_slider.OnValueChanged = function(object)
						-- print("OnValueChanged", object, j, j.value)
						j.value = object:GetValue()
						j.param_text:SetText(j.name..": "..math.floor(object:GetValue()*100)/100)
					end
				end
			end
		end
	end
	choice_shader:SelectChoice("distord.glsl")


end

return shader
