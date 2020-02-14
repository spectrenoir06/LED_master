
local player = {}

function player:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Settings")

	local lx, ly = love.graphics.getDimensions()
	if love.system.getOS() == "Android" then
		lx, ly = ly, lx
	end

	frame:SetPos(0, 290+230)
	frame:SetSize(lx, 318+30)

	frame:SetResizable(true)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)
	frame:SetMaxWidth(5000)
	frame:SetMaxHeight(5000)
	frame:SetScreenLocked(true)

	frame:SetDockable(true)

	frame:SetIcon("ressource/icons/toolbox.png")


	local tabs = loveframes.Create("tabs", frame)
	tabs:SetPos(4, 30)
	tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	tabs.Update = function(object, dt)
		tabs:SetSize(frame:GetWidth()-8, frame:GetHeight()-26-4)
	end

	local start_y = 8
	local step_y = 34

	self.node_scan = require "UI.settings.node_scan"
	self.node_map  = require "UI.settings.node_map"
	self.pixel_map = require "UI.settings.pixel_map"
	self.load_save = require "UI.settings.load_save"
	self.canva_set = require "UI.settings.setting"

	self.node_scan:load(loveframes, frame, tabs, start_y, step_y)
	self.node_map:load(loveframes, frame, tabs, start_y, step_y)
	self.pixel_map:load(loveframes, frame, tabs, start_y, step_y)
	self.load_save:load(loveframes, frame, tabs, start_y, step_y)
	self.canva_set:load(loveframes, frame, tabs, start_y, step_y)


	return frame
end

return player
