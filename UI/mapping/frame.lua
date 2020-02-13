local node_scan = require "UI.mapping.node_scan"
local node_map = require "UI.mapping.node_map"
local pixel_map = require "UI.mapping.pixel_map"

local player = {}

function player:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Mapping")

	local lx, ly = love.graphics.getDimensions()
	if love.system.getOS() == "Android" then
		lx, ly = ly, lx
	end

	frame:SetPos(0, 290+230)
	frame:SetSize(lx, 318+30)

	frame:SetResizable(true)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)
	frame:SetScreenLocked(true)

	frame:SetDockable(true)

	-- frame:SetIcon("ressource/icons/network-ethernet.png")


	local tabs = loveframes.Create("tabs", frame)
	tabs:SetPos(4, 30)
	tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	tabs.Update = function(object, dt)
		tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	end

	local start_y = 8
	local step_y = 34

	node_scan:load(loveframes, frame, tabs, start_y, step_y)
	node_map:load(loveframes, frame, tabs, start_y, step_y)
	pixel_map:load(loveframes, frame, tabs, start_y, step_y)



	return frame

-------------------------------------------------------------------------------

end

return player
