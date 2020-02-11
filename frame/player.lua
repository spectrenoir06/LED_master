require "lib.luafft"

local player = {}

local abs = math.abs
local new = complex.new

local mic_sample_size = 2081
local mic_sample_rate = 48000
local mic_depth = 8
local fft_bin = 1024

function f_map(x,  in_min,  in_max,  out_min,  out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function spectro_up_mic(obj, sdata, size, mic)
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
		if i + fft_bin > MusicSize then i = MusicSize/2 end

		if sdata:getChannelCount()==1 then
			List[#List+1] = new(sdata:getSample(i), 0)
		else
			List[#List+1] = new(sdata:getSample(i*2), 0)
		end
	end
	return fft(List, false)
end

function player:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Player")

	local lx, ly = love.graphics.getDimensions()
	if love.system.getOS() == "Android" then
		lx, ly = ly, lx
	end
	frame:SetSize(lx, 230)

	frame:SetPos(0,280)
	frame:SetAlwaysUpdate(true)
	frame:SetScreenLocked(true)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(230)
	frame:SetMinWidth(200)
	frame:SetMinHeight(230)

	frame:SetDockable(true)

	local tabs = loveframes.Create("tabs", frame)
	tabs:SetPos(4, 30)
	tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	tabs.Update = function(object, dt)
		tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	end

	local panel_video = loveframes.Create("panel")
	local panel_shader = loveframes.Create("panel")
	local panel_music = loveframes.Create("panel")
	local panel_script = loveframes.Create("panel")
	local panel_setting = loveframes.Create("panel")

	local video = love.graphics.newVideo("ressource/video/bebop.ogv", {audio=true})
	local video_source = video:getSource()


---------------------------- Shader --------------------------------------------

	tabs:AddTab("Shader", panel_shader, nil)
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

	local slider_bright = loveframes.Create("slider", panel_shader)
	slider_bright:SetPos(100, 100)
	slider_bright:SetWidth(panel_shader:GetWidth()-100-8)
	slider_bright:SetMinMax(0.0, 1)
	slider_bright:SetValue(1)

	local text2 = loveframes.Create("text", panel_shader)
	text2:SetPos(8, 100)
	text2:SetText("Bright: "..slider_bright:GetValue())

	slider_bright.OnValueChanged = function(object)
		text2:SetText("Bright: "..math.floor(slider_bright:GetValue()*100)/100)
		shaders_param.bright = slider_bright:GetValue()
		love.thread.getChannel('bright'):push(slider_bright:GetValue())
	end

	for k,v in ipairs(shaders) do
		choice_shader:AddChoice(v.name)
	end

	panel_shader.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_shader:SetSize(panel_shader:GetWidth()-16, 25)
		slider_speed:SetWidth(panel_shader:GetWidth()-100-8)
		slider_density:SetWidth(panel_shader:GetWidth()-100-8)
		slider_bright:SetWidth(panel_shader:GetWidth()-100-8)

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

	-- local soundData = love.sound.newSoundData("ressource/music/8bit.mp3")

	local record_list = love.audio.getRecordingDevices()
	local mic = record_list[1]

	local slider_lerp = loveframes.Create("slider", panel_music)
	tabs:AddTab("Music", panel_music, nil, nil, function() if sound then sound:play() end end, function() if sound then sound:pause() end end)
	slider_lerp:SetPos(100, 70)
	slider_lerp:SetWidth(panel_music:GetWidth()-100-8)
	slider_lerp:SetMinMax(0.01, 1)
	slider_lerp:SetValue(0.3)

	local text1 = loveframes.Create("text", panel_music)
	text1:SetPos(8, 70)
	text1:SetText("Lerp: "..slider_lerp:GetValue())

	slider_lerp.OnValueChanged = function(object)
		text1:SetText("Lerp: "..slider_lerp:GetValue())
	end

	local slider_amp = loveframes.Create("slider", panel_music)

	slider_amp:SetPos(100, 100)
	slider_amp:SetWidth(panel_music:GetWidth()-100-8)
	slider_amp:SetMinMax(0.1, 100)
	slider_amp:SetValue(1)

	local text2 = loveframes.Create("text", panel_music)
	text2:SetPos(8, 100)
	text2:SetText("Amp: "..slider_amp:GetValue())

	slider_amp.OnValueChanged = function(object)
		text2:SetText("Amp: "..math.floor(slider_amp:GetValue()*100)/100)
	end

	local progressbar = loveframes.Create("slider", panel_music)
	progressbar:SetPos(100, 40)
	progressbar:SetWidth(panel_music:GetWidth()-100-8)

	progressbar.OnValueChanged = function(object)
		-- progressbar:SetValue(math.floor(sound:tell("seconds")))
		-- self.value = math.floor(sound:tell("seconds"))
		sound:seek(progressbar:GetValue(), "seconds")
	end

	local checkbox = loveframes.Create("checkbox", panel_music)
	checkbox:SetText("Audio in")
	checkbox:SetPos(8, 140)

	local t = {}
	local timer = 0
	local spectre = {}

	local choice_music = loveframes.Create("multichoice", panel_music)
	choice_music:SetPos(100, 8)
	choice_music:SetSize(panel_music:GetWidth()-16, 25)

	local list = love.filesystem.getDirectoryItems("ressource/music/")
	local musics = {}

	choice_music.OnChoiceSelected = function(object, choice)
		print("choice_music", choice)
		sound:stop()

		soundData = musics[choice].soundData
		sound = musics[choice].sound
		sound:play()
		progressbar:SetMinMax(0, math.floor(sound:getDuration()))
	end

	print("Load music:")
	for k,v in ipairs(list) do
		print("    "..v)
		musics[v] = {}
		musics[v].soundData = love.sound.newSoundData("ressource/music/"..v)
		musics[v].sound = love.audio.newSource(musics[v].soundData)
		-- scripts[v] = require("ressource/mu/"..v:gsub(".lua",""))
		musics[v].name = v
		choice_music:AddChoice(v)
		if k == 1 then
			soundData = musics[v].soundData
			sound = musics[v].sound
			choice_music:SelectChoice(v)
			sound:stop()
		end
	end

	local choice_mic = loveframes.Create("multichoice", panel_music)
	choice_mic:SetPos(100, 135)
	choice_mic:SetSize(panel_music:GetWidth()-130-8, 25)

	print("Load audio in:")
	for k,v in ipairs(record_list) do
		print("    "..v:getName())
		choice_mic:AddChoice(v:getName())
		choice_mic:SelectChoice(v:getName())
	end

	choice_mic.OnChoiceSelected = function(object, choice)
		mic:stop()
		for k,v in ipairs(record_list) do
			if v:getName() == choice then
				mic = v
				print("mic start")
				mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
				break
			end
		end
	end



	local music_button = loveframes.Create("button", panel_music)
	music_button:SetPos(8, 8)
	music_button:SetSize(75, 25)
	music_button:SetText("Pause")
	music_button.OnClick = function(object, x, y)
		if sound:isPlaying() then
			sound:pause()
			object:SetText("Play")
		else
			sound:play()
			object:SetText("Pause")
		end
	end


	panel_music.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_music:SetSize(panel_music:GetWidth()-8-100, 25)
		progressbar:SetSize(panel_music:GetWidth()-8-100, 25)
		slider_lerp:SetSize(panel_music:GetWidth()-8-100, 25)
		slider_amp:SetSize(panel_music:GetWidth()-8-100, 25)
		choice_mic:SetSize(panel_music:GetWidth()-8-100, 25)

		if sound:isPlaying() then
			music_button:SetText("Pause")
		else
			music_button:SetText("Play")
		end

		timer = timer + dt
		local div = 2
		local l = 1
		local size = canvas:getWidth()
		if checkbox:GetChecked() then
			if not mic:isRecording() then
				local test = mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
				assert(test)
			end
			s = spectro_up_mic(sound, soundData, fft_bin, mic)
			spectre = s or spectre
		else
			spectre = spectro_up(sound, soundData, fft_bin)
		end

		love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
			-- local lx = (canvas:getWidth() / size) * l
			love.graphics.setColor(0, 0, 0)
			-- love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

			local band_size = math.max(math.floor(fft_bin / canvas:getWidth() / 2 * l), 1)
			for i = 0, canvas:getWidth()/l-1 do
				local pos = math.floor(band_size * i / div)
				-- print(band_size, pos)

				local sum = 0
				for j=1, band_size do
					sum = sum + spectre[pos+j]:abs() * slider_amp:GetValue() / 1000 * canvas:getHeight()
				end
				sum = sum

				t[pos+1] = lerp(t[pos+1] or 0, sum, slider_lerp:GetValue())


				local x = i*l --(i*lx + canvas:getWidth()/2)%canvas:getWidth()

				local r,g,b = hslToRgb((timer+(x/canvas:getWidth()))%1,1,0.5)
				love.graphics.setColor(r,g,b)

				-- local color = math.min(t[i+1],canvas:getHeight())/canvas:getHeight()
				-- love.graphics.setColor(1,1-color,0)


				-- love.graphics.rectangle("fill", x, canvas:getHeight(), l, -math.floor(t[pos+1]))

				love.graphics.rectangle("fill", x, canvas:getHeight()/2+math.floor(t[pos+1])/2, l, -math.floor(t[pos+1]))

				-- love.graphics.rectangle("fill", (x+canvas:getWidth()/2)%canvas:getWidth(), canvas:getHeight(), lx, -math.floor(t[i+1]))
				-- love.graphics.rectangle("fill", canvas:getWidth()/2-(i+1)*lx, canvas:getHeight(), lx, -math.floor(t[i+1]))
			end
			-- progressbar:SetValue(math.floor(sound:tell("seconds")))
			-- self.value = math.floor(sound:tell("seconds"))
		love.graphics.setCanvas()
	end

---------------------------- Video ---------------------------------------------

	tabs:AddTab("Video", panel_video, nil, nil, function() video:play() end, function() video:pause() end)
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
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		video_progressbar:SetWidth(object:GetWidth()-8-68)

		love.graphics.setCanvas(canvas)
			love.graphics.draw(video, 0, 0, 0, canvas:getWidth()/video:getWidth(), canvas:getHeight()/video:getHeight())
			video_progressbar:SetValue(math.floor(video_source:tell("seconds")))
		love.graphics.setCanvas()
	end

---------------------------- Script --------------------------------------------

	tabs:AddTab("Script", panel_script)
	local choice_script = loveframes.Create("multichoice", panel_script)
	choice_script:SetPos(8, 8)
	choice_script:SetSize(panel_script:GetWidth()-16, 25)

	local list = love.filesystem.getDirectoryItems("ressource/script/")
	local scripts = {}
	print("Load scripts:")
	for k,v in ipairs(list) do
		print("    "..v)
		scripts[v] = require("ressource/script/"..v:gsub(".lua",""))
		scripts[v].name = v
	end

	for k,v in pairs(scripts) do
		choice_script:AddChoice(v.name)
	end
	choice_script:SelectChoice("42.lua")


	panel_script.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_script:SetWidth(object:GetWidth()-16)

		love.graphics.setCanvas(canvas)
		scripts[choice_script:GetChoice()]:update(dt, canvas:getWidth(), canvas:getHeight())
		love.graphics.setCanvas()
	end

---------------------------- Setting -------------------------------------------


	local font = love.graphics.newFont("ressource/font/Code_8x8.ttf", 8, "normal")
	font:setFilter("nearest","nearest")
	local lx, ly = canvas:getDimensions()

	tabs:AddTab("Setting", panel_setting, nil, nil, function() love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight()) end, function() love.keyboard.setTextInput(false) end)
	local numberbox_x = loveframes.Create("numberbox", panel_setting)
	numberbox_x:SetPos(5, 5)
	numberbox_x:SetSize(200, 25)
	numberbox_x:SetMinMax(1, 512)
	numberbox_x:SetValue(lx)

	numberbox_x.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(value, canvas:getHeight(), {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end


	local numberbox_y = loveframes.Create("numberbox", panel_setting)
	numberbox_y:SetPos(5, 40)
	numberbox_y:SetSize(200, 25)
	numberbox_y:SetMinMax(1, 512)
	numberbox_y:SetValue(ly)

	numberbox_y.OnValueChanged = function(object, value)
		canvas = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(canvas:getWidth(), value, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
	end

	panel_setting.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		numberbox_x:SetWidth(object:GetWidth()-10)
		numberbox_y:SetWidth(object:GetWidth()-10)

		love.graphics.setCanvas(canvas)
			love.graphics.setFont(font)
			love.graphics.clear(0,0,0,1)
				local lx, ly = canvas:getDimensions()
				love.graphics.print("x "..lx, 0, 0)
				love.graphics.print("y "..ly, 0, 10)
		love.graphics.setCanvas()
	end

-------------------------------------------------------------------------------

end

return player
