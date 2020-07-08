require "lib.luafft"
local ffi = require("ffi")

local music = {}

local abs = math.abs
local new = complex.new
local floor = math.floor
local pow = math.pow

local function lerp(a, b, t)
	-- return a + (b - a) * t
	return (1 - t) * a + t * b
end

function music:fft(sdata, start, size, dec)
		-- if sdata:getBitDepth() == 16 then
		-- 	-- 16-bit data is stored as signed values internally.
		-- 	local pointer = ffi.cast("int16_t*", sdata:getFFIPointer())
		-- 	print(pointer[MusicPos] / 0x7FFF, sdata:getSample(MusicPos))
		-- else
		-- -- 8-bit data is stored as unsigned values internally.
		-- 	local pointer = ffi.cast("uint8_t*", sdata:getFFIPointer())
		-- 	print((pointer[MusicPos] - 128 ) / 127, sdata:getSample(MusicPos))fi
		-- end

	local List = {}

	for i=0, size-1 do
		local pos = start+i*(dec or 1)
		if pos >= sdata:getSampleCount() then pos = sdata:getSampleCount()-1 end
		List[#List+1] = new(sdata:getSample(pos, 1), 0)
	end

	-- local a = 0.97
	local a = 0.90
	for i=size, 2, -1 do
		List[i] = List[i] - a * List[i-1] -- Pre-Emphasis
	end

	for i=1, size do
		List[i] = List[i] * self.multiplier[i+1] -- Window
	end

	local r = fft(List, false)

	-- for i=1, size/2 do
	-- 	r[i] = pow(r[i], 0.8)
	-- end

	return r
end

function music:spectre_update(dt)


	self.canvas_timer = self.canvas_timer + dt
	self.fft_timer = self.fft_timer + dt

	if self.fft_timer > (1/self.fft_fps) then
		if self.mic_checkbox:GetChecked() and self.mic then
			if self.mic:getSampleCount() >= self.fft_bin then
				-- self.spectre_old = self.spectre
				self.spectre = self:fft(self.mic:getData(), 0, self.fft_bin, 1)
				self.fft_timer = 0
			else
				-- print("wait mic")
				-- return
			end
		elseif self.sound:isPlaying() then
			-- self.spectre_old = self.spectre
			self.spectre = self:fft(self.soundData, self.sound:tell("samples"), self.fft_bin, self.fft_dec)
			self.fft_timer = 0


			-- fbank = numpy.zeros((
			-- 	nfilt,
			-- 	int(numpy.floor(NFFT / 2 + 1))
			-- ))
			-- for m in range(1, nfilt + 1):
			-- f_m_minus = int(bin[m - 1])   # left
			-- f_m = int(bin[m])             # center
			-- f_m_plus = int(bin[m + 1])    # right
			--
			-- for k in range(f_m_minus, f_m):
			-- 	fbank[m - 1, k] = (k - bin[m - 1]) / (bin[m] - bin[m - 1])
			-- for k in range(f_m, f_m_plus):
			-- 	fbank[m - 1, k] = (bin[m + 1] - k) / (bin[m + 1] - bin[m])

		end
	end

	if self.canvas_timer  > (1/mapping.fps) then
		for i=0, self.fft_bin/2-1 do
			self.spectre_disp[i+1] = lerp(self.spectre_disp[i+1], self.spectre[i+1] * self.slider_amp:GetValue() / 100, self.slider_lerp:GetValue())
		end

		local max= -1
		local id = -1
		for i=2, self.fft_bin/2 do
			if self.spectre_disp[i] > max then
				max = self.spectre_disp[i]
				id = i
			end
		end

		-- if self.mic_checkbox:GetChecked() and self.mic then
		-- 	print(id, max, (id-1) * self.mic:getSampleRate() / self.fft_bin / 2)
		-- else
		-- 	print(id, max, (id-1) * self.soundData:getSampleRate() / self.fft_bin /2)
		-- end

		self.fft_canvas:renderTo(function()
			love.graphics.clear(0,0,0,0)
			for i = 0, self.fft_canvas:getWidth()-1 do
				local c = self.spectre_disp[i+1]
				love.graphics.setColor(c,c,c)
				love.graphics.points(i+0.5,0.5)
			end
		end)

		if shaders[shader_nb] and shaders[shader_nb].shader:hasUniform('fft') then
			shaders[shader_nb].shader:send('fft', self.fft_canvas)
		end

		if self.tabs:GetTabNumber() == 2 then -- music mode
			self.timer = self.timer + dt
			local div = 1

			love.graphics.setCanvas(canvas)

			love.graphics.clear(0,0,0,1)

			local band_size = math.max(floor(self.fft_bin / 2 / canvas:getWidth()), 1)
			for x = 0, canvas:getWidth()-1 do
				local pos = floor(band_size * x / div)
				-- print(band_size, pos)

				if x<self.fft_bin/2 then
					local max = 0
					for j=1, math.floor(band_size) do
						local val = self.spectre_disp[pos+j]
						if val > max then
							max = val
						end
					end
					max = max * canvas:getHeight()

					self.t[pos+1] = lerp(self.t[pos+1] or 0, max, self.slider_lerp:GetValue())

					local r,g,b = hslToRgb((self.timer/4+(x/canvas:getWidth()))%1,1,0.5)
					love.graphics.setColor(r,g,b)

					local v = floor(self.t[pos+1])

					local choice = self.choice_render:GetChoice()
					if choice == "1" then
						love.graphics.rectangle("fill", x, canvas:getHeight(), 1, -v)
					elseif choice == "2" then
						love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), 1, floor(v/2))
						love.graphics.rectangle("fill", x, floor(canvas:getHeight()/2), 1, -floor(v/2))
					end
				end
			end

			love.graphics.setCanvas()

			if self.choice_render:GetChoice() == "3" then
				spectre2d_canvas:renderTo(function()
					love.graphics.setColor(1,1,1,1)
					love.graphics.draw(self.fft_canvas, 0, self.pos_spectre, 0, spectre2d_canvas:getWidth()/self.fft_canvas:getWidth(), 1)
					self.pos_spectre = (self.pos_spectre + 1)%spectre2d_canvas:getHeight()
				end)
				canvas:renderTo(function()
					love.graphics.setColor(1,1,1,1)
					love.graphics.draw(spectre2d_canvas, 0, -self.pos_spectre, 0, 1, 1)
					love.graphics.draw(spectre2d_canvas, 0, -self.pos_spectre+spectre2d_canvas:getHeight(), 0, 1, 1)
					-- self.pos_spectre = (self.pos_spectre)%spectre2d_canvas:getHeight()
				end)
			end
		end
		self.canvas_timer = 0
	end

end

function music:load(loveframes, frame, tabs, start_y, step_y)

	local panel_music = loveframes.Create("panel")

	tabs:AddTab("Music", panel_music, nil, "ressource/icons/music.png")
	self.tabs = tabs

	local small_font = love.graphics.newFont(10)
	local icons_play = love.graphics.newImage("ressource/icons/control.png")
	local icons_pause = love.graphics.newImage("ressource/icons/control-pause.png")

	self:reload()

	local record_list = love.audio.getRecordingDevices()
	self.mic = record_list[1]

	self.slider_lerp = loveframes.Create("slider", panel_music)
	self.slider_lerp:SetPos(100, start_y+step_y*2)
	self.slider_lerp:SetWidth(panel_music:GetWidth()-100-8)
	self.slider_lerp:SetMinMax(0.01, 1)
	self.slider_lerp:SetValue(0.8)

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


	self.progressbar = loveframes.Create("slider", panel_music)
	self.progressbar:SetPos(100, start_y+step_y*1)
	self.progressbar:SetWidth(panel_music:GetWidth()-100-8)

	self.progressbar.OnValueChanged = function(object)
		self.sound:pause()
		self.sound:seek(self.progressbar:GetValue(), "seconds")
	end

	self.progressbar.OnRelease = function(object)
		self.sound:play()
	end

	self.progressbar_text = loveframes.Create("text", panel_music)
	self.progressbar_text:SetPos(8, start_y+step_y*1+4)
	self.progressbar_text:SetText(self.progressbar:GetValue().."/0")
	self.progressbar_text:SetFont(small_font)


	self.mic_checkbox = loveframes.Create("checkbox", panel_music)
	self.mic_checkbox:SetPos(8, start_y+step_y*4+4)
	self.mic_checkbox:SetText("Audio in")
	self.mic_checkbox:SetFont(small_font)

	self.t = {}
	self.timer = 0

	self.fft_timer = 0
	self.canvas_timer = 0

	self.choice_music = loveframes.Create("multichoice", panel_music)
	self.choice_music:SetPos(100, start_y+step_y*0)
	self.choice_music:SetSize((panel_music:GetWidth()-8-100)/2, 25)

	local list = love.filesystem.getDirectoryItems("ressource/music/")
	local musics = {}

	self.choice_render = loveframes.Create("multichoice", panel_music)
	self.choice_render:SetPos(100+4+(panel_music:GetWidth()-8-100)/2, start_y+step_y*0)
	self.choice_render:SetSize((panel_music:GetWidth()-8-100)/2, 25)

	for i=1, 3 do
		self.choice_render:AddChoice(tostring(i))
	end
	self.choice_render:SelectChoice("1")

	self.choice_music.OnChoiceSelected = function(object, choice)
		-- print("self.choice_music", choice)
		if self.sound then self.sound:stop() end

		self.soundData = love.sound.newSoundData("ressource/music/"..choice)
		--print(self.soundData:getBitDepth(), self.soundData:getSampleRate(), self.soundData:getChannelCount())
		self.sound = love.audio.newSource(self.soundData)
		self.sound:play()
		self.progressbar:SetMinMax(0, self.sound:getDuration("seconds"))

		-- for i=0, self.fft_bin/2 do
		-- 	print(i * self.soundData:getSampleRate() / self.fft_bin) -- frequency bin
		-- end
	end

	print("Load music:")
	for k,v in ipairs(list) do
		print("    "..v)
		musics[v] = {}
		-- scripts[v] = require("ressource/mu/"..v:gsub(".lua",""))
		musics[v].name = v
		self.choice_music:AddChoice(v)
		if k == 1 then
			-- self.soundData = musics[v].self.soundData
			-- sound = musics[v].sound
			self.choice_music:SelectChoice(v)
			self.sound:stop()
		end
	end

	self.choice_mic = loveframes.Create("multichoice", panel_music)
	self.choice_mic:SetPos(100, start_y+step_y*4)
	self.choice_mic:SetSize(panel_music:GetWidth()-130-8, 25)

	print("Load audio in:")
	if #record_list == 0 then
		self.choice_mic:AddChoice("No audio in")
		self.choice_mic:SelectChoice("No audio in")
		self.choice_mic:SetEnabled(false)
		self.mic_checkbox:SetEnabled(false)
		self.mic_checkbox:SetVisible(false)
	else
		for k,v in ipairs(record_list) do
			print("    "..v:getName())
			self.choice_mic:AddChoice(v:getName())
			if k == 1 then self.choice_mic:SelectChoice(v:getName()) end
		end
	end

	function select_mic(obj, v)
		if self.mic then
			self.mic:stop()
			for k,v in ipairs(record_list) do
				if v:getName() == self.choice_mic:GetValue() then
					self.mic = v
					if self.mic_checkbox:GetChecked() then
						self.mic:start(self.mic_sample_size, self.mic_sample_rate, self.mic_depth, 1)
					end
					break
				end
			end
		end
	end

	self.choice_mic.OnChoiceSelected = select_mic
	self.mic_checkbox.OnChanged = select_mic

	self.music_button = loveframes.Create("button", panel_music)
	self.music_button:SetPos(8, start_y+step_y*0)
	self.music_button:SetSize(75, 25)
	self.music_button:SetText("Pause")
	self.music_button.OnClick = function(object, x, y)
		if self.sound:isPlaying() then
			self.sound:pause()
			object:SetText("Play")
		else
			self.sound:play()
			object:SetText("Pause")
		end
	end

	self.pos_spectre = 0

	self.spectre = {}
	self.spectre_disp = {}
	for i=1, self.fft_bin do
		self.spectre[i] = 0
		self.spectre_disp[i] = 0
	end

	panel_music.Update = function(object, dt)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		self.choice_music:SetSize((panel_music:GetWidth()-8-100)/2, 25)
		self.choice_render:SetSize((panel_music:GetWidth()-8-100)/2, 25)
		self.progressbar:SetSize(panel_music:GetWidth()-8-100, 25)
		self.slider_lerp:SetSize(panel_music:GetWidth()-8-100, 25)
		self.slider_amp:SetSize(panel_music:GetWidth()-8-100, 25)
		self.choice_mic:SetSize(panel_music:GetWidth()-8-100, 25)

		self.choice_render:SetPos(100+4+(panel_music:GetWidth()-8-100)/2, start_y)

		self.progressbar_text:SetText(floor(self.sound:tell("seconds")).." / "..floor(self.sound:getDuration()))
		self.progressbar:SetValue(self.sound:tell("seconds"))

		if self.sound:isPlaying() then
			self.music_button:SetText("Pause")
			self.music_button:SetImage(icons_pause)
		else
			self.music_button:SetText("Play")
			self.music_button:SetImage(icons_play)
		end
	end
	self.panel_music = panel_music
end

function music:reload()

	self.fft_bin = 1024
	self.fft_fps = 60

	local os = love.system.getOS()
	if os == "Android" or  os == "iOS" then
		self.fft_dec = 2
		self.mic_sample_size = 2081
		self.mic_sample_rate = 48000
		self.mic_depth = 8
	else
		self.fft_dec = 2
		self.mic_sample_size = self.fft_bin
		self.mic_sample_rate = 44100/self.fft_dec
		self.mic_depth = 16
		print("self.mic_sample_size", self.mic_sample_size, self.mic_sample_rate/self.mic_sample_size)
	end

	self.fft_canvas = love.graphics.newCanvas(self.fft_bin/2, 1)

	self.multiplier = {}
	for i=0, self.fft_bin do
		self.multiplier[i+1] = .5 * (1 - math.cos(2*math.pi*i/(self.fft_bin-1))) -- Hamming Window
	end
end

return music
