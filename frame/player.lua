require "lib.luafft"

local player = {}

local abs = math.abs
local new = complex.new

function map(x,  in_min,  in_max,  out_min,  out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function lerp(a, b, t)
	return a + (b - a) * t
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
	frame:SetPos(300,0)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	frame:SetDockable(true)

	local multichoice = loveframes.Create("multichoice", frame)
	multichoice:SetPos(5, 30)



	for k,v in ipairs(shaders) do
		multichoice:AddChoice(v.name)
	end
	multichoice:AddChoice("Music")
	multichoice:AddChoice("Video")

	local soundData = love.sound.newSoundData("ressource/8bit.mp3")
	local sound = love.audio.newSource(soundData)

	local video = love.graphics.newVideo("ressource/bebop.ogv", {audio=true})

	multichoice.OnChoiceSelected = function(object, choice)
		print(choice .. " was selected.")
		sound:pause()
		video:pause()
		if choice == "Music" then
			sound:play()
		elseif choice == "Video" then
			video:play()
		else
			for k,v in ipairs(shaders) do
				if v.name == choice then
					shader_nb = k
				end
			end
		end
	end
	multichoice:SetChoice("color.glsl")

	local slider1 = loveframes.Create("slider", frame)
	slider1:SetPos(5, 100)
	slider1:SetWidth(290)
	slider1:SetMinMax(0.05, 1)
	slider1:SetValue(0.4)

	local text1 = loveframes.Create("text", frame)
	text1:SetPos(100, 70)
	text1:SetText("Lerp: "..slider1:GetValue())

	slider1.Update = function(object, dt)
		text1:SetText("Lerp: "..slider1:GetValue())
	end

	local progressbar = loveframes.Create("progressbar", frame)
	progressbar:SetPos(5, 150)
	progressbar:SetWidth(290)
	progressbar:SetMinMax(0, math.floor(sound:getDuration()))

	local t = {}

	frame.Update = function(object, dt)
		if multichoice:GetChoice() == "Music" then
			local l = 1
			--object:SetSize(frame:GetWidth()-8, frame:GetHeight()-28-4)
			local size = canvas:getWidth()
			local spectre = spectro_up(sound, soundData, size*2/l)

			love.graphics.setCanvas(canvas)
			love.graphics.clear(0,0,0,1)
			local lx = (canvas:getWidth() / size) * l
			local ly = (canvas:getHeight() / 20)
			love.graphics.setColor(0, 0, 0)
			-- love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

			for i = 0, #spectre/2-1 do
				local r,g,b = hslToRgb((time+i/20)%1,1,0.5)
				-- local r,g,b = hslToRgb((i/50)%1,1,0.5)
				love.graphics.setColor(r,g,b)
				local v = 100*(spectre[i+1]:abs())
				v = math.min(v,200)
				local m = map(v, 0, 200, 0, 20)
				t[i+1] = lerp(t[i+1] or 0, m, slider1:GetValue())
				love.graphics.rectangle("fill", i*lx, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
				-- love.graphics.rectangle("fill", canvas:getWidth()-(i+1)*lx, canvas:getHeight(), lx, -math.floor(t[i+1]*ly))
			end
			progressbar:SetValue(math.floor(sound:tell("seconds")))
			love.graphics.setCanvas()

		elseif multichoice:GetChoice() == "Video" then
			love.graphics.setCanvas(canvas)

			love.graphics.draw(video, 0, 0, 0, canvas:getWidth()/video:getWidth(), canvas:getHeight()/video:getHeight())
			love.graphics.setCanvas()
		else
			love.graphics.setColor(1,1,1,1)
			love.graphics.setCanvas(canvas)
				-- love.graphics.setColor(0.5, 0.5, 0.5)
				love.graphics.setShader(shaders[shader_nb].shader)
					love.graphics.draw(canvas_test,0,0)
				love.graphics.setShader()

				love.graphics.setColor(1,0,0,1)
				-- love.graphics.rectangle("fill", 23	, 5, 1, 1)
			love.graphics.setCanvas()


		end
	end
end

return player
