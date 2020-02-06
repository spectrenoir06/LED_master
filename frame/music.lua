require "lib.luafft"

local music = {}

local abs = math.abs
local new = complex.new

local wave_size=8
local color = {0,200,0}

local t = {}

function map(x,  in_min,  in_max,  out_min,  out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
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
	spectrum = fft(List, false)
	-- for i,v in ipairs(spectrum) do
	-- 	spectrum[i] = spectrum[i] * wave_size
	-- end
end

function lerp(a, b, t)
	return a + (b - a) * t
end


function music:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("music")
	frame:SetSize(300, 300)
	frame:SetPos(300,0)

	local soundData = love.sound.newSoundData("ressource/8bit.mp3")
	local sound = love.audio.newSource(soundData)
	sound:play()

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	local slider1 = loveframes.Create("slider", frame)
	slider1:SetPos(5, 50)
	slider1:SetWidth(290)
	slider1:SetMinMax(0.05, 1)
	slider1:SetValue(0.4)

	local text1 = loveframes.Create("text", frame)
	text1:SetPos(50, 30)
	text1:SetText("Lerp: "..slider1:GetValue())

	slider1.Update = function(object, dt)
		text1:SetText("Lerp: "..slider1:GetValue())
	end

	local progressbar = loveframes.Create("progressbar", frame)
	progressbar:SetPos(5, 80)
	progressbar:SetWidth(290)
	progressbar:SetMinMax(0, math.floor(sound:getDuration()))

	frame.Update = function(object)
		--object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
		local size = canvas:getWidth()
		spectro_up(sound,soundData, size*2)

		love.graphics.setCanvas(canvas)
		love.graphics.clear(0,0,0,1)
		local lx = (canvas:getWidth() / size)*1
		local ly = (canvas:getHeight() / 20)
		love.graphics.setColor(0, 0, 0)
		-- love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

		for i = 0, #spectrum/2-1 do
			local r,g,b = hslToRgb((time+i/20)%1,1,0.5)
			love.graphics.setColor(r,g,b)
			local v = 100*(spectrum[i+1]:abs())
			v = math.min(v,200)
			local m = map(v, 0, 200, 0, 20)
			t[i+1] = lerp(t[i+1] or 0, m, slider1:GetValue())
			love.graphics.rectangle("fill", i*lx, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
			-- love.graphics.rectangle("fill", canvas:getWidth()-i*lx, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
		end
		progressbar:SetValue(math.floor(sound:tell("seconds")))
		love.graphics.setCanvas()

	end
end

return music
