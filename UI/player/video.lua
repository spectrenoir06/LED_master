local video = {}

function video:load(loveframes, frame, tabs, start_y, step_y)

	local panel_video = loveframes.Create("panel")

	local icons_play = love.graphics.newImage("ressource/icons/control.png")
	local icons_pause = love.graphics.newImage("ressource/icons/control-pause.png")

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
		if video_stream:isPlaying() then
			video_stream:pause()
			object:SetText("Play")
		else
			video_stream:play()
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
		if video_stream then video_stream:pause() end


		video_source = videos[choice].source
		video_stream = videos[choice].video
		video_stream:play()
		video_progressbar:SetMinMax(0, math.floor(video_source:getDuration()))
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
			video_stream:pause()
		end
	end

	panel_video.Update = function(object, dt)

		if video_stream:isPlaying() then
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
			love.graphics.draw(video_stream, 0, 0, 0, canvas:getWidth()/video_stream:getWidth(), canvas:getHeight()/video_stream:getHeight())
			video_progressbar:SetValue(math.floor(video_source:tell("seconds")))
		love.graphics.setCanvas()
	end

end

return video
