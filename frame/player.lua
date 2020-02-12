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
	frame:SetSize(lx, 240)

	frame:SetPos(0,280)
	frame:SetAlwaysUpdate(true)
	frame:SetScreenLocked(true)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(240)
	frame:SetMinWidth(200)
	frame:SetMinHeight(240)

	frame:SetDockable(true)

	frame:SetIcon("ressource/icons/remote-control.png")

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

	local icons_play = love.graphics.newImage("ressource/icons/control.png")
	local icons_pause = love.graphics.newImage("ressource/icons/control-pause.png")

	local small_font = love.graphics.newFont(10)


---------------------------- Shader --------------------------------------------

	local start_y = 8
	local step_y = 34

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

	local slider_bright = loveframes.Create("slider", panel_shader)
	slider_bright:SetPos(100, start_y+step_y*3)
	slider_bright:SetWidth(panel_shader:GetWidth()-100-8)
	slider_bright:SetMinMax(0.0, 1)
	slider_bright:SetValue(1)

	local slider_bright_text = loveframes.Create("text", panel_shader)
	slider_bright_text:SetPos(8, start_y+step_y*3+4)
	slider_bright_text:SetText("Bright: "..slider_bright:GetValue())
	slider_bright_text:SetFont(small_font)

	slider_bright.OnValueChanged = function(object)
		slider_bright_text:SetText("Bright: "..math.floor(slider_bright:GetValue()*100)/100)
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
	tabs:AddTab("Music", panel_music, nil, "ressource/icons/music.png")
	slider_lerp:SetPos(100, start_y+step_y*2)
	slider_lerp:SetWidth(panel_music:GetWidth()-100-8)
	slider_lerp:SetMinMax(0.01, 1)
	slider_lerp:SetValue(0.3)

	local slider_lerp_text = loveframes.Create("text", panel_music)
	slider_lerp_text:SetPos(8, start_y+step_y*2+4)
	slider_lerp_text:SetText("Lerp: "..slider_lerp:GetValue())
	slider_lerp_text:SetFont(small_font)

	slider_lerp.OnValueChanged = function(object)
		slider_lerp_text:SetText("Lerp: "..slider_lerp:GetValue())
	end

	local slider_amp = loveframes.Create("slider", panel_music)

	slider_amp:SetPos(100, start_y+step_y*3)
	slider_amp:SetWidth(panel_music:GetWidth()-100-8)
	slider_amp:SetMinMax(0.1, 100)
	slider_amp:SetValue(1)

	local slider_amp_text = loveframes.Create("text", panel_music)
	slider_amp_text:SetPos(8, start_y+step_y*3+4)
	slider_amp_text:SetText("Amp: "..slider_amp:GetValue())
	slider_amp_text:SetFont(small_font)

	slider_amp.OnValueChanged = function(object)
		slider_amp_text:SetText("Amp: "..math.floor(slider_amp:GetValue()*100)/100)
	end

	local progressbar = loveframes.Create("slider", panel_music)
	progressbar:SetPos(100, start_y+step_y*1)
	progressbar:SetWidth(panel_music:GetWidth()-100-8)

	progressbar.OnValueChanged = function(object)
		-- progressbar:SetValue(math.floor(sound:tell("seconds")))
		sound:pause()
		sound:seek(progressbar:GetValue(), "seconds")
		-- self.value = math.floor(sound:tell("seconds"))
	end

	progressbar.OnRelease = function(object)
		print("The slider button has been released.")
		sound:play()
	end

	local progressbar_text = loveframes.Create("text", panel_music)
	progressbar_text:SetPos(8, start_y+step_y*1+4)
	progressbar_text:SetText(progressbar:GetValue().."/0")
	progressbar_text:SetFont(small_font)

	local mic_checkbox = loveframes.Create("checkbox", panel_music)
	mic_checkbox:SetPos(8, start_y+step_y*4+4)
	mic_checkbox:SetText("Audio in")

	local t = {}
	local timer = 0
	local spectre = {}

	local choice_music = loveframes.Create("multichoice", panel_music)
	choice_music:SetPos(100, start_y+step_y*0)
	choice_music:SetSize(panel_music:GetWidth()-8-100, 25)

	local list = love.filesystem.getDirectoryItems("ressource/music/")
	local musics = {}

	choice_music.OnChoiceSelected = function(object, choice)
		print("choice_music", choice)
		if sound then sound:stop() end

		soundData = love.sound.newSoundData("ressource/music/"..choice)
		sound = love.audio.newSource(soundData)
		sound:play()
		progressbar:SetMinMax(0, sound:getDuration("seconds"))
	end

	print("Load music:")
	for k,v in ipairs(list) do
		print("    "..v)
		musics[v] = {}
		-- scripts[v] = require("ressource/mu/"..v:gsub(".lua",""))
		musics[v].name = v
		choice_music:AddChoice(v)
		if k == 1 then
			-- soundData = musics[v].soundData
			-- sound = musics[v].sound
			choice_music:SelectChoice(v)
			sound:stop()
		end
	end

	local choice_mic = loveframes.Create("multichoice", panel_music)
	choice_mic:SetPos(100, start_y+step_y*4)
	choice_mic:SetSize(panel_music:GetWidth()-130-8, 25)

	print("Load audio in:")
	if #record_list == 0 then
		choice_mic:AddChoice("No audio in")
		choice_mic:SelectChoice("No audio in")
		choice_mic:SetEnabled(false)
		mic_checkbox:SetEnabled(false)
		mic_checkbox:SetVisible(false)
	else
		for k,v in ipairs(record_list) do
			print("    "..v:getName())
			choice_mic:AddChoice(v:getName())
			choice_mic:SelectChoice(v:getName())
		end
	end

	choice_mic.OnChoiceSelected = function(object, choice)
		if mic then
			mic:stop()
			for k,v in ipairs(record_list) do
				if v:getName() == choice then
					mic = v
					if mic_checkbox:GetChecked() then
						mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
					end
					break
				end
			end
		end
	end

	local music_button = loveframes.Create("button", panel_music)
	music_button:SetPos(8, start_y+step_y*0)
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


		progressbar_text:SetText(math.floor(sound:tell("seconds")).." / "..math.floor(sound:getDuration()))
		progressbar:SetValue(sound:tell("seconds"))

		if sound:isPlaying() then
			music_button:SetText("Pause")
			music_button:SetImage(icons_pause)
		else
			music_button:SetText("Play")
			music_button:SetImage(icons_play)
		end

		timer = timer + dt
		local div = 2
		local l = 1
		local size = canvas:getWidth()
		if mic_checkbox:GetChecked() and mic then
			if not mic:isRecording() then
				local test = mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
			end
			s = spectro_up_mic(sound, soundData, fft_bin, mic)
			spectre = s or spectre
		else
			spectre = spectro_up(sound, soundData, fft_bin)
		end

		love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
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

	tabs:AddTab("Video", panel_video, nil, "ressource/icons/film.png")
	local video_progressbar = loveframes.Create("progressbar", panel_video)
	video_progressbar:SetPos(100, start_y+step_y*1)
	video_progressbar:SetSize(panel_video:GetWidth()-8-100, 25)

	local video_button = loveframes.Create("button", panel_video)
	video_button:SetPos(8, start_y+step_y*0)
	video_button:SetSize(75, 25)
	video_button:SetText("Pause")
	video_button:SetImage(icons_play)
	video_button.OnClick = function(object, x, y)
		if video:isPlaying() then
			video:pause()
			object:SetText("Play")
		else
			video:play()
			object:SetText("Pause")
		end
	end

	local choice_video = loveframes.Create("multichoice", panel_video)
	choice_video:SetPos(100, start_y+step_y*0)
	choice_video:SetSize(panel_video:GetWidth()-8-100, 25)

	local list = love.filesystem.getDirectoryItems("ressource/video/")
	local videos = {}

	choice_video.OnChoiceSelected = function(object, choice)
		print("choice_video", choice)
		if video then video:pause() end


		video_source = videos[choice].source
		video = videos[choice].video
		video:play()
		video_progressbar:SetMinMax(0, math.floor(video_source:getDuration()))
		-- progressbar:SetMinMax(0, math.floor(video:getDuration()))
	end

	print("Load Video:")
	for k,v in ipairs(list) do
		print("    "..v)
		videos[v] = {}
		videos[v].video = love.graphics.newVideo("ressource/video/"..v, {audio=true})
		videos[v].source = videos[v].video:getSource()
		videos[v].name = v
		choice_video:AddChoice(v)
		if k == 1 then
			choice_video:SelectChoice(v)
			video:pause()
		end
	end

	panel_video.Update = function(object, dt)

		if video:isPlaying() then
			video_button:SetText("Pause")
			video_button:SetImage(icons_pause)
		else
			video_button:SetText("Play")
			video_button:SetImage(icons_play)
		end

		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		video_progressbar:SetSize(panel_video:GetWidth()-8-100, 25)
		choice_video:SetSize(panel_video:GetWidth()-8-100, 25)

		love.graphics.setCanvas(canvas)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(video, 0, 0, 0, canvas:getWidth()/video:getWidth(), canvas:getHeight()/video:getHeight())
			video_progressbar:SetValue(math.floor(video_source:tell("seconds")))
		love.graphics.setCanvas()
	end

---------------------------- Script --------------------------------------------

	tabs:AddTab("Script", panel_script, nil, "ressource/icons/script-code.png")
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
			love.graphics.setColor(1,1,1,1)
			scripts[choice_script:GetChoice()]:update(dt, canvas:getWidth(), canvas:getHeight())
		love.graphics.setCanvas()
	end

---------------------------- Setting -------------------------------------------


	local font = love.graphics.newFont("ressource/font/Code_8x8.ttf", 8, "normal")
	font:setFilter("nearest","nearest")
	local lx, ly = canvas:getDimensions()

	tabs:AddTab("Setting", panel_setting, nil, "ressource/icons/wrench.png", function() love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight()) end, function() love.keyboard.setTextInput(false) end)
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
			love.graphics.setColor(1,1,1,1)
				local lx, ly = canvas:getDimensions()
				love.graphics.print("x "..lx, 1, 0)
				love.graphics.print("y "..ly, 1, 10)
		love.graphics.setCanvas()
	end

	frame.OnClose = function(object)
		print("The frame Player was closed.")
		if video then video:pause() end
		if sound then sound:pause() end
		if mic then mic:stop() end
	end

	return frame

-------------------------------------------------------------------------------

end

return player
