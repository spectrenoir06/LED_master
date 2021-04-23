local music = require "UI.player.music"
local shader = require "UI.player.shader"
local video = require "UI.player.video"
local script = require "UI.player.script"


local player = {}

function player:load(loveframes, nb)
	local frame = loveframes.Create("frame")
	frame:SetName("Player")

	local lx, ly = love.graphics.getDimensions()

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
	-- tabs:SetAlwaysUpdate(true)
	tabs.Update = function(object, dt)
		tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	end

	local start_y = 8
	local step_y = 34

	shader:load(loveframes, frame, tabs, start_y, step_y)
	music:load(loveframes, frame, tabs, start_y, step_y)
	video:load(loveframes, frame, tabs, start_y, step_y)
	script:load(loveframes, frame, tabs, start_y, step_y)

	tabs:SwitchToTab(tonumber(nb) or 1)
	-- script.choice_script:SelectChoice("snake.lua")

	frame.Update = function(obj, dt)
		music:spectre_update(dt)
	end

	frame.OnClose = function(object)
		print("The frame Player was closed.")
		print(video)
		if video.video_stream then video.video_stream:pause() end
		if sound then sound:pause() end
		if mic then mic:stop() end
	end

	return frame

-------------------------------------------------------------------------------

end

return player
