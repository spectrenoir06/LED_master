require "lib.luafft"

local music = {}

local abs = math.abs
local new = complex.new
local floor = math.floor

local mic_sample_size = 2081
local mic_sample_rate = 48000
local mic_depth = 8
local fft_bin = 1024

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function spectro_up_mic(obj, sdata, size, mic)
	if mic:getSampleCount() > size then
		local List = {}
		local data = mic:getData()
		for i= 0, size-1 do
			List[#List+1] = new(data:getSample(i), 0)
		end
		return fft(List, false)
	end
end

local function spectro_up(obj, sdata, size)
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


function music:load(loveframes, frame, tabs, start_y, step_y)

	local small_font = love.graphics.newFont(10)
	local icons_play = love.graphics.newImage("ressource/icons/control.png")
	local icons_pause = love.graphics.newImage("ressource/icons/control-pause.png")


	local panel_music = loveframes.Create("panel")

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
	slider_amp:SetValue(30)

	local slider_amp_text = loveframes.Create("text", panel_music)
	slider_amp_text:SetPos(8, start_y+step_y*3+4)
	slider_amp_text:SetText("Amp: "..slider_amp:GetValue())
	slider_amp_text:SetFont(small_font)

	slider_amp.OnValueChanged = function(object)
		slider_amp_text:SetText("Amp: "..floor(slider_amp:GetValue()*100)/100)
	end

	local progressbar = loveframes.Create("slider", panel_music)
	progressbar:SetPos(100, start_y+step_y*1)
	progressbar:SetWidth(panel_music:GetWidth()-100-8)

	progressbar.OnValueChanged = function(object)
		-- progressbar:SetValue(floor(sound:tell("seconds")))
		sound:pause()
		sound:seek(progressbar:GetValue(), "seconds")
		-- self.value = floor(sound:tell("seconds"))
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

	canvas_fft = love.graphics.newCanvas( 512, height )

	panel_music.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_music:SetSize(panel_music:GetWidth()-8-100, 25)
		progressbar:SetSize(panel_music:GetWidth()-8-100, 25)
		slider_lerp:SetSize(panel_music:GetWidth()-8-100, 25)
		slider_amp:SetSize(panel_music:GetWidth()-8-100, 25)
		choice_mic:SetSize(panel_music:GetWidth()-8-100, 25)


		progressbar_text:SetText(floor(sound:tell("seconds")).." / "..floor(sound:getDuration()))
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
		elseif sound:isPlaying() then
			spectre = spectro_up(sound, soundData, fft_bin)
			-- spectre[1] = new(0, 0)
		end

		love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
			if spectre then
				local band_size = math.max(floor(fft_bin / canvas:getWidth() / 2 * l), 1)
				for i = 0, canvas:getWidth()/l-1 do
					local pos = floor(band_size * i / div)
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

					local v = floor(t[pos+1])

					love.graphics.rectangle("fill", x, canvas:getHeight(), l, -v)

					-- love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), l, floor(v/2))
					-- love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), l, -floor(v/2))
					-- love.graphics.rectangle("fill", x, floor(x)(canvas:getHeight()/2-(v/2)), l, v)

					-- love.graphics.rectangle("fill", (x+canvas:getWidth()/2)%canvas:getWidth(), canvas:getHeight(), lx, -floor(t[i+1]))
					-- love.graphics.rectangle("fill", canvas:getWidth()/2-(i+1)*lx, canvas:getHeight(), lx, -floor(t[i+1]))
				end
			end
		love.graphics.setCanvas()
	end
end

return music
