local script = {}

function script:load(loveframes, frame, tabs, start_y, step_y, select)

	local panel_script = loveframes.Create("panel")

	tabs:AddTab("Script", panel_script, nil, "ressource/icons/script-code.png")
	self.choice_script = loveframes.Create("multichoice", panel_script)
	self.choice_script:SetPos(8, 8)
	self.choice_script:SetSize(panel_script:GetWidth()-16, 25)

	local list = love.filesystem.getDirectoryItems("ressource/script/")
	local scripts = {}
	print("\nLoad scripts:")
	for k,v in ipairs(list) do
		print("    "..v)
		local name = v:gsub(".lua", "")
		-- print(name)
		scripts[name] = require("ressource/script/"..name)
		scripts[name].name = name
	end

	for k,v in pairs(scripts) do
		self.choice_script:AddChoice(v.name)
	end

	self.choice_script.OnChoiceSelected = function(object, choice)
		if scripts[choice].load then
			scripts[choice]:load(canvas:getWidth(), canvas:getHeight())
		end
	end

	self.choice_script:SelectChoice(select or "42")


	panel_script.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.choice_script:SetWidth(object:GetWidth()-16)

		love.graphics.setCanvas(canvas)
			love.graphics.setColor(1,1,1,1)
			-- print(self.choice_script:GetChoice())
			scripts[self.choice_script:GetChoice()]:update(dt, canvas:getWidth(), canvas:getHeight())
		love.graphics.setCanvas()
	end

end

return script
