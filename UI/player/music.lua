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

function music:spectro_up_mic(obj, sdata, size, mic)
	if mic:getSampleCount() > size then
		local List = {}
		local data = mic:getData()
		for i= 0, size-1 do
			List[#List+1] = new(data:getSample(i), 0)
		end

		local sum = 0
		for k,v in ipairs(List) do
			sum = sum + v
		end
		local mean = sum / size
		-- print(mean)
		for k,v in ipairs(List) do
			List[k] = List[k] - mean
		end

		for i=0, size-1 do
			local multiplier = 0.5 * (1 - math.cos(2*math.pi*i/(size-1)));
			List[i+1] = multiplier * List[i+1]
		end

		return fft(List, false)
	end
end

function music:spectro_up(obj, sdata, size, music_pos)
	local MusicPos = music_pos or obj:tell("samples")
	local MusicSize = sdata:getSampleCount()
	local List = {}

	for i=MusicPos, MusicPos+(size-1) do
		if i + size > MusicSize then i = MusicSize/2 end
		if sdata:getChannelCount()==1 then
			List[#List+1] = new(sdata:getSample(i), 0)
		else
			List[#List+1] = new(sdata:getSample(i*2), 0)
		end
	end

	local sum = 0
	for k,v in ipairs(List) do
		sum = sum + v
	end
	local mean = sum / size
	-- print(mean)
	for k,v in ipairs(List) do
		List[k] = List[k] - mean
	end

	for i=0, size-1 do
		local multiplier = 0.5 * (1 - math.cos(2*math.pi*i/(size-1)));
		List[i+1] = multiplier * List[i+1]
	end
	return fft(List, false)

end

function music:fft(dt)
	local fps_fft = 60
	if self.fft_timer > (1/fps_fft) then
		if self.mic_checkbox:GetChecked() and self.mic then
			if not self.mic:isRecording() then
				local test = self.mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
			end
			s = self:spectro_up_mic(sound, soundData, fft_bin, self.mic)
			spectre = s or spectre
		elseif sound:isPlaying() then
			spectre = self:spectro_up(sound, soundData, fft_bin)
				-- print(spectre[1]:abs())
			-- spectre[1] = new(0, 0)
		end
		if spectre then
			if shaders[shader_nb] then
				if shaders[shader_nb].shader:hasUniform('fft') then
					self.fft_canvas:renderTo(function()
						love.graphics.clear(0,0,0,0)
						for i = 0, self.fft_canvas:getWidth()-1 do
							local c = spectre[i+1]:abs() * self.slider_amp:GetValue() / 255
							self.t_canvas[i+1] = lerp(self.t_canvas[i+1] or 0, c, self.slider_lerp:GetValue())
							love.graphics.setColor(self.t_canvas[i+1],self.t_canvas[i+1],self.t_canvas[i+1])
							love.graphics.points(i+0.5,0.5)
						end
					end)
						shaders[shader_nb].shader:send('fft', self.fft_canvas)
					end
				-- canvas:renderTo(function()
				-- 	love.graphics.setColor(1,1,1,1)
				-- 	love.graphics.draw(self.fft_canvas, 0, self.pos_spectre%canvas:getHeight())
				-- 	self.pos_spectre = self.pos_spectre + 1
				-- end)
			end
		end
		self.fft_timer = self.fft_timer - (1/fps_fft)
	end
	self.fft_timer = self.fft_timer + dt

end

function music:load(loveframes, frame, tabs, start_y, step_y)

	local small_font = love.graphics.newFont(10)
	local icons_play = love.graphics.newImage("ressource/icons/control.png")
	local icons_pause = love.graphics.newImage("ressource/icons/control-pause.png")

	self.fft_canvas = love.graphics.newCanvas(512, 1)


	local panel_music = loveframes.Create("panel")

	local record_list = love.audio.getRecordingDevices()
	self.mic = record_list[1]

	self.slider_lerp = loveframes.Create("slider", panel_music)
	tabs:AddTab("Music", panel_music, nil, "ressource/icons/music.png")
	self.slider_lerp:SetPos(100, start_y+step_y*2)
	self.slider_lerp:SetWidth(panel_music:GetWidth()-100-8)
	self.slider_lerp:SetMinMax(0.01, 1)
	self.slider_lerp:SetValue(0.3)

	self.slider_lerp_text = loveframes.Create("text", panel_music)
	self.slider_lerp_text:SetPos(8, start_y+step_y*2+4)
	self.slider_lerp_text:SetText("Lerp: "..self.slider_lerp:GetValue())
	self.slider_lerp_text:SetFont(small_font)

	self.slider_lerp.OnValueChanged = function(object)
		self.slider_lerp_text:SetText("Lerp: "..self.slider_lerp:GetValue())
	end

	self.slider_amp = loveframes.Create("slider", panel_music)

	self.slider_amp:SetPos(100, start_y+step_y*3)
	self.slider_amp:SetWidth(panel_music:GetWidth()-100-8)
	self.slider_amp:SetMinMax(0.1, 100)
	self.slider_amp:SetValue(30)

	self.slider_amp_text = loveframes.Create("text", panel_music)
	self.slider_amp_text:SetPos(8, start_y+step_y*3+4)
	self.slider_amp_text:SetText("Amp: "..self.slider_amp:GetValue())
	self.slider_amp_text:SetFont(small_font)

	self.slider_amp.OnValueChanged = function(object)
		self.slider_amp_text:SetText("Amp: "..floor(self.slider_amp:GetValue()*100)/100)
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
		-- print("The slider button has been released.")
		sound:play()
	end

	local progressbar_text = loveframes.Create("text", panel_music)
	progressbar_text:SetPos(8, start_y+step_y*1+4)
	progressbar_text:SetText(progressbar:GetValue().."/0")
	progressbar_text:SetFont(small_font)

	self.mic_checkbox = loveframes.Create("checkbox", panel_music)
	self.mic_checkbox:SetPos(8, start_y+step_y*4+4)
	self.mic_checkbox:SetText("Audio in")
	self.mic_checkbox:SetFont(small_font)

	local t = {}
	local t2 = {}
	self.t_canvas = {}
	local timer = 0

	self.fft_timer = 0

	local choice_music = loveframes.Create("multichoice", panel_music)
	choice_music:SetPos(100, start_y+step_y*0)
	choice_music:SetSize((panel_music:GetWidth()-8-100)/2, 25)

	local list = love.filesystem.getDirectoryItems("ressource/music/")
	local musics = {}

	local choice_render = loveframes.Create("multichoice", panel_music)
	choice_render:SetPos(100+4+(panel_music:GetWidth()-8-100)/2, start_y+step_y*0)
	choice_render:SetSize((panel_music:GetWidth()-8-100)/2, 25)

	for i=1, 3 do
		choice_render:AddChoice(tostring(i))
	end
	choice_render:SelectChoice("1")

	choice_music.OnChoiceSelected = function(object, choice)
		-- print("choice_music", choice)
		if sound then sound:stop() end

		soundData = love.sound.newSoundData("ressource/music/"..choice)
		print(soundData:getFFIPointer())
		print(soundData:getBitDepth(), soundData:getSampleRate())
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
		self.mic_checkbox:SetEnabled(false)
		self.mic_checkbox:SetVisible(false)
	else
		for k,v in ipairs(record_list) do
			print("    "..v:getName())
			choice_mic:AddChoice(v:getName())
			choice_mic:SelectChoice(v:getName())
		end
	end

	choice_mic.OnChoiceSelected = function(object, choice)
		if self.mic then
			self.mic:stop()
			for k,v in ipairs(record_list) do
				if v:getName() == choice then
					self.mic = v
					if self.mic_checkbox:GetChecked() then
						self.mic:start(mic_sample_size, mic_sample_rate, mic_depth, 1)
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

	-- canvas_fft = love.graphics.newCanvas( 512, height )
	self.pos_spectre = 0

	panel_music.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		choice_music:SetSize((panel_music:GetWidth()-8-100)/2, 25)
		choice_render:SetSize((panel_music:GetWidth()-8-100)/2, 25)
		progressbar:SetSize(panel_music:GetWidth()-8-100, 25)
		self.slider_lerp:SetSize(panel_music:GetWidth()-8-100, 25)
		self.slider_amp:SetSize(panel_music:GetWidth()-8-100, 25)
		choice_mic:SetSize(panel_music:GetWidth()-8-100, 25)

		choice_render:SetPos(100+4+(panel_music:GetWidth()-8-100)/2, start_y)


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

		love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
			if spectre then
				local band_size = math.max(floor(fft_bin / canvas:getWidth() / 2 * l), 1)
				for i = 0, canvas:getWidth()/l-1 do
					local pos = floor(band_size * i / div)
					-- print(band_size, pos)

					local sum = 0
					for j=math.floor(-band_size/2), math.floor(band_size/2+1) do
						-- print(j)
						if spectre[pos+j] then
							sum = sum + spectre[pos+j]:abs() * self.slider_amp:GetValue() / 100 * canvas:getHeight()
						else
						end
					end
					sum = sum / band_size

					t[pos+1] = lerp(t[pos+1] or 0, sum, self.slider_lerp:GetValue())

					local x = i*l --(i*lx + canvas:getWidth()/2)%canvas:getWidth()

					local r,g,b = hslToRgb((timer/4+(x/canvas:getWidth()))%1,1,0.5)
					love.graphics.setColor(r,g,b)

					-- local color = math.min(t[i+1],canvas:getHeight())/canvas:getHeight()
					-- love.graphics.setColor(1,1-color,0)

					local v = floor(t[pos+1])
					local choice = choice_render:GetChoice()
					if choice == "1" then
						love.graphics.rectangle("fill", x, canvas:getHeight(), l, -v)
					elseif choice == "2" then
						love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), l, floor(v/2))
						love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), l, -floor(v/2))
					elseif choice == "3" then
						-- for y=0, canvas:getHeight()-1 do
							-- if t2[y+1] then
								-- print(pos,y)
								-- love.graphics.setColor(1,1,1,t2[y+1][pos+1])
								-- love.graphics.rectangle("fill", x, y, l, 1)
								-- love.graphics.points(pos+.5, y+.5)
							-- end
						-- end
					end
				end
			end
		love.graphics.setCanvas()
	end
	self.panel_music = panel_music
end

return music
