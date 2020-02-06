require "lib.luafft"

local music = {}

local abs = math.abs
local new = complex.new

local wave_size=8
local color = {0,200,0}
local Size = 80

local t = {}

for i=1, Size do t[i] = 0 end


function map(x,  in_min,  in_max,  out_min,  out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function spectro_up(obj, sdata)
	local MusicPos = obj:tell("samples")
	local MusicSize = sdata:getSampleCount()

	local List = {}
	for i= MusicPos, MusicPos + (Size-1) do
		CopyPos = i
		if i + 2048 > MusicSize then i = MusicSize/2 end

		if sdata:getChannelCount()==1 then
			List[#List+1] = new(sdata:getSample(i), 0)
		else
			List[#List+1] = new(sdata:getSample(i*2), 0)
		end

	end
	spectrum = fft(List, false)
	for i,v in ipairs(spectrum) do
		spectrum[i] = spectrum[i] * wave_size
	end
end


function music:load(loveframes, lx, ly)
	local frame = loveframes.Create("frame")
	frame:SetName("music")
	frame:SetSize(300, 300)
	frame:SetPos(300,0)

	local soundData = love.sound.newSoundData("ressource/tecdream.mp3")
	local sound = love.audio.newSource(soundData)
	sound:play()

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	local panel = loveframes.Create("panel", frame)
	panel:SetPos(4, 28)
	panel:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)

	panel.Draw = function(object)
		local lx = (object:GetWidth() / Size)*2
		local ly = (object:GetHeight() / 20)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

		for i = 0, #spectrum/2-1 do
			local r,g,b = hslToRgb((time+i/100)%1,1,0.5)
			love.graphics.setColor(r,g,b)
			local v = wave_size*(spectrum[i+1]:abs())
			v = math.min(v,200)
			local m = map(v, 0, 200, 0, 20)
			t[i+1] = (t[i+1] + m) / 2
			love.graphics.rectangle("fill", object:GetX()+i*lx, object:GetY()+object:GetHeight(), lx, -math.floor(t[i+1]*ly))
		end
	end

	panel.Update = function(object)
		object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
		spectro_up(sound,soundData)
	end
end

return music
