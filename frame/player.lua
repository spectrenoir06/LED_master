require "lib.luafft"

local player = {}

local abs = math.abs
local new = complex.new

function f_map(x,  in_min,  in_max,  out_min,  out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function spectro_up_mic(obj, sdata, size)
	if mic:getSampleCount() > size then
		local List = {}
		local data = mic:getData()
		for i= 0, size-1 do
			List[#List+1] = new(data:getSample(i), 0)
		end
		return fft(List, false)
	end
end

function spectro_up(obj, sdata, size)
	local MusicPos = obj:tell("samples")
	local MusicSize = sdata:getSampleCount()
	local List = {}

	for i= MusicPos, MusicPos + (size-1) do
		CopyPos = i
		if i + 2048 > MusicSize then i = MusicSize/2 end

		if sdata:getChannelCount()==1 then
			List[#List+1] = new(sdata:getSample(i), 0)
		else
			List[#List+1] = new(sdata:getSample(i*2), 0)
		end
	end
	return fft(List, false)
end

function player:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("Player")
	frame:SetSize(300, 300)
	frame:SetPos(600,0)
	frame:SetAlwaysUpdate(true)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	frame:SetDockable(true)

	local tabs = loveframes.Create("tabs", frame)
	tabs:SetPos(4, 30)
	tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)

	local panel_video = loveframes.Create("panel")
	local panel_shader = loveframes.Create("panel")
	local panel_music = loveframes.Create("panel")
	local panel_scripte = loveframes.Create("panel")

	local video = love.graphics.newVideo("ressource/bebop.ogv", {audio=true})
	local video_source = video:getSource()
	-- local soundData = love.sound.newSoundData("ressource/8bit.mp3")
	local soundData = love.sound.newSoundData("ressource/tecdream.mp3")
	local sound = love.audio.newSource(soundData)

	local list = love.audio.getRecordingDevices()

	for k,v in ipairs(list) do
		print(k,v:getName())
	end

	mic = list[1]
	mic:start(200, 8000)
	spectre = {}

	tabs:AddTab("Shader", panel_shader, nil)
	tabs:AddTab("Music", panel_music, nil, nil, function() sound:play() end, function() sound:pause() end)
	tabs:AddTab("Video", panel_video, nil, nil, function() video:play() end, function() video:pause() end)
	tabs:AddTab("Script", panel_scripte)

---------------------------- Video ---------------------------------------------

	local video_progressbar = loveframes.Create("progressbar", panel_video)
	video_progressbar:SetPos(68, 8)
	video_progressbar:SetWidth(210)
	video_progressbar:SetMinMax(0, math.floor(video_source:getDuration()))

	local video_button = loveframes.Create("button", panel_video)
	video_button:SetPos(8, 8)
	video_button:SetSize(50, 25)
	video_button:SetText("Pause")
	video_button.OnClick = function(object, x, y)
		if video:isPlaying() then
			video:pause()
			object:SetText("Play")
		else
			video:play()
			object:SetText("Pause")
		end
	end

	panel_video.Update = function(object, dt)
		love.graphics.setCanvas(canvas)
			love.graphics.draw(video, 0, 0, 0, canvas:getWidth()/video:getWidth(), canvas:getHeight()/video:getHeight())
			video_progressbar:SetValue(math.floor(video_source:tell("seconds")))
		love.graphics.setCanvas()
	end

---------------------------- Shader --------------------------------------------

	local choice_shader = loveframes.Create("multichoice", panel_shader)
	choice_shader:SetPos(8, 8)
	choice_shader:SetSize(panel_shader:GetWidth()-16, 25)

	local slider_speed = loveframes.Create("slider", panel_shader)
	slider_speed:SetPos(100, 40)
	slider_speed:SetWidth(panel_shader:GetWidth()-100-8)
	slider_speed:SetMinMax(0.0, 10)
	slider_speed:SetValue(1)

	local slider_speed_text = loveframes.Create("text", panel_shader)
	slider_speed_text:SetPos(8, 40)
	slider_speed_text:SetText("Speed: "..slider_speed:GetValue())

	slider_speed.OnValueChanged = function(object)
		slider_speed_text:SetText("Speed: "..math.floor(slider_speed:GetValue()*100)/100)
		shaders_param.speed = slider_speed:GetValue()
	end

	local slider_density = loveframes.Create("slider", panel_shader)
	slider_density:SetPos(100, 70)
	slider_density:SetWidth(panel_shader:GetWidth()-100-8)
	slider_density:SetMinMax(0.0, 4)
	slider_density:SetValue(1)

	local text1 = loveframes.Create("text", panel_shader)
	text1:SetPos(8, 70)
	text1:SetText("Density: "..slider_density:GetValue())

	slider_density.OnValueChanged = function(object)
		text1:SetText("Density: "..math.floor(slider_density:GetValue()*100)/100)
		shaders_param.density = slider_density:GetValue()
	end

	for k,v in ipairs(shaders) do
		choice_shader:AddChoice(v.name)
	end

	panel_shader.Update = function(object, dt)
		love.graphics.setCanvas(canvas)
			love.graphics.setColor(1,1,1,1)
			-- love.graphics.setColor(0.2, 0.2, 0.2)
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
	choice_shader:SelectChoice("distord.glsl")

---------------------------- Music ---------------------------------------------

	local slider1 = loveframes.Create("slider", panel_music)
	slider1:SetPos(100, 8)
	slider1:SetWidth(panel_music:GetWidth()-100-8)
	slider1:SetMinMax(0.05, 1)
	slider1:SetValue(0.4)

	local text1 = loveframes.Create("text", panel_music)
	text1:SetPos(8, 9)
	text1:SetText("Lerp: "..slider1:GetValue())

	slider1.OnValueChanged = function(object)
		text1:SetText("Lerp: "..slider1:GetValue())
	end

	local progressbar = loveframes.Create("slider", panel_music)
	progressbar:SetPos(8, 34)
	progressbar:SetWidth(panel_music:GetWidth()-16)
	progressbar:SetMinMax(0, math.floor(sound:getDuration()))

	progressbar.OnValueChanged = function(object)
		-- progressbar:SetValue(math.floor(sound:tell("seconds")))
		-- self.value = math.floor(sound:tell("seconds"))
		sound:seek(progressbar:GetValue(), "seconds")
	end

	local checkbox = loveframes.Create("checkbox", panel_music)
	checkbox:SetText("Checkbox")
	checkbox:SetPos(5, 100)
	local t = {}
	local timer = 0
	spectre = {}

	panel_music.Update = function(object, dt)
		timer = timer + dt
		local l = 1
		local div = 2
		--object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
		local size = canvas:getWidth()
		if checkbox:GetChecked() then
			spectre = spectro_up(sound, soundData, size*div/l)
		else
			s = spectro_up_mic(sound, soundData, size*div/l)
			spectre = s or spectre
		end

		love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
			local lx = (canvas:getWidth() / size) * l
			local ly = (canvas:getHeight() / 20)
			love.graphics.setColor(0, 0, 0)
			-- love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

			for i = 0, #spectre/div-1 do
				local v = 100*(spectre[i+1]:abs())
				v = math.min(v,200)
				local m = f_map(v, 0, 200, 0, 20)
				t[i+1] = lerp(t[i+1] or 0, m, slider1:GetValue())

				local x = i*lx --(i*lx + canvas:getWidth()/2)%canvas:getWidth()
				local r,g,b = hslToRgb((timer+(x/canvas:getWidth()))%1,1,0.5)
				-- local r,g,b = hslToRgb((i/50)%1,1,0.5)
				love.graphics.setColor(r,g,b)

				love.graphics.rectangle("fill", x, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
				-- love.graphics.rectangle("fill", (x+canvas:getWidth()/2)%canvas:getWidth(), canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
				-- love.graphics.rectangle("fill", canvas:getWidth()-(i+1)*lx, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
			end
			-- progressbar:SetValue(math.floor(sound:tell("seconds")))
			-- self.value = math.floor(sound:tell("seconds"))
		love.graphics.setCanvas()
	end

---------------------------- Test ----------------------------------------------

	local choice_scripte = loveframes.Create("multichoice", panel_scripte)
	choice_scripte:SetPos(8, 8)
	choice_scripte:SetSize(panel_scripte:GetWidth()-16, 25)

	local list = love.filesystem.getDirectoryItems("scripte/")
	local scriptes = {}
	print("Load scripts:")
	for k,v in ipairs(list) do
		print("    "..v)
		scriptes[v] = require("scripte/"..v:gsub(".lua",""))
		scriptes[v].name = v
	end

	for k,v in pairs(scriptes) do
		choice_scripte:AddChoice(v.name)
	end
	choice_scripte:SelectChoice("test.lua")


	panel_scripte.Update = function(object, dt)
		love.graphics.setCanvas(canvas)
		scriptes[choice_scripte:GetChoice()]:update(dt, canvas:getWidth(), canvas:getHeight())
		love.graphics.setCanvas()
	end

-------------------------------------------------------------------------------

end

return player
