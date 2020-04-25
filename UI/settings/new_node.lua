
local new_node = {}

local small_font = love.graphics.newFont(10)

function new_numberbox(text, x, y, min, max, parent, loveframes)

	local numberbox = loveframes.Create("numberbox", parent)
	numberbox:SetPos(x+70, y)
	numberbox:SetWidth(parent:GetWidth()-16-70)
	numberbox:SetSize(70, 25)
	numberbox:SetMinMax(min, max)
	numberbox:SetValue(0)

	numberbox_text = loveframes.Create("text", parent)
	numberbox_text:SetPos(x, y+6)
	numberbox_text:SetText(text)
	numberbox_text:SetFont(small_font)

	numberbox:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, parent:GetX(), parent:GetY(), parent:GetWidth(), parent:GetHeight())
	end

	numberbox:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end
	return numberbox
end

function new_node:load(loveframes, frame, tabs, start_y, step_y, parent)
	local panel_node_new = loveframes.Create("panel", frame)

	panel_node_new:SetPos(8, 30)
	panel_node_new:SetSize(frame:GetWidth()-16, frame:GetHeight()-8-30)

	self.numberbox_net = new_numberbox("Net", 8, start_y+step_y*0, 0, 127, panel_node_new, loveframes)
	self.numberbox_sub = new_numberbox("Sub-net", 8, start_y+step_y*1, 0, 255, panel_node_new, loveframes)
	self.numberbox_port = new_numberbox("Port", 8, start_y+step_y*3, 0, 65535, panel_node_new, loveframes)
	self.numberbox_LED_nb = new_numberbox("LED nb", 8, start_y+step_y*6, 0, 65535, panel_node_new, loveframes)


	self.ip_textinput = loveframes.Create("textinput", panel_node_new)
	self.ip_textinput:SetPos(70+8, start_y+step_y*2)
	self.ip_textinput:SetWidth(panel_node_new:GetWidth()-16-70)
	self.ip_textinput:SetFont(love.graphics.newFont(12))

	self.ip_textinput.OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, panel_node_new:GetX(), panel_node_new:GetY(), panel_node_new:GetWidth(), panel_node_new:GetHeight())
	end

	self.ip_textinput.OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	local ip_textinput_text = loveframes.Create("text", panel_node_new)
	ip_textinput_text:SetPos(8, start_y+step_y*2+6)
	ip_textinput_text:SetText("IP adresse")
	ip_textinput_text:SetFont(small_font)


	self.choice_protocol = loveframes.Create("multichoice", panel_node_new)
	self.choice_protocol:SetPos(70+8, start_y+step_y*4)
	self.choice_protocol:SetWidth(panel_node_new:GetWidth()-16-70)
	self.choice_protocol:AddChoice("artnet")
	self.choice_protocol:AddChoice("artnet_big")
	self.choice_protocol:AddChoice("RGB888")
	self.choice_protocol:AddChoice("RGB565")
	self.choice_protocol:AddChoice("RLE888")
	self.choice_protocol:AddChoice("BRO888")
	self.choice_protocol:AddChoice("Z888")
	self.choice_protocol:SelectChoice("artnet")

	local choice_protocol_text = loveframes.Create("text", panel_node_new)
	choice_protocol_text:SetPos(8, start_y+step_y*4+6)
	choice_protocol_text:SetText("Protocol:")
	choice_protocol_text:SetFont(small_font)

	self.rgbw_checkbox = loveframes.Create("checkbox", panel_node_new)
	self.rgbw_checkbox:SetPos(70+8, start_y+step_y*5+4)
	self.rgbw_checkbox:SetFont(love.graphics.newFont(12))

	local rgbw_checkbox_text = loveframes.Create("text", panel_node_new)
	rgbw_checkbox_text:SetPos(8, start_y+step_y*5+6)
	rgbw_checkbox_text:SetText("RGBW")
	rgbw_checkbox_text:SetFont(small_font)

	local lx = panel_node_new:GetWidth()

	local add_button = loveframes.Create("button", panel_node_new)
	add_button:SetPos(lx/4, start_y+step_y*8)
	add_button:SetText("Save node")
	add_button:SetImage("ressource/icons/node-insert-next.png")

	local cancel_button = loveframes.Create("button", panel_node_new)
	cancel_button:SetPos(lx/3*2, start_y+step_y*8)
	cancel_button:SetText("Cancel")
	cancel_button:SetImage("ressource/icons/cross.png")

	cancel_button.OnClick = function()
		panel_node_new:SetVisible(false)
		tabs:SetVisible(true)
	end

	self.edit = 0

	add_button.OnClick = function()
		local t = {}
		t.net = self.numberbox_net:GetValue()
		t.uni = self.numberbox_sub:GetValue()
		t.ip = self.ip_textinput:GetText()
		t.port = self.numberbox_port:GetValue()
		t.rgbw = self.rgbw_checkbox:GetChecked()
		t.protocol = self.choice_protocol:GetChoice()
		t.led_nb = self.numberbox_LED_nb:GetValue()

		if self.edit == 0 then
			table.insert(mapping.nodes, t)
		else
			mapping.nodes[self.edit] = t
		end

		parent.node_map:reload()
		panel_node_new:SetVisible(false)
		tabs:SetVisible(true)
	end


	frame.Update = function(object, dt)
		panel_node_new:SetSize(frame:GetWidth()-16, frame:GetHeight()-8-30)
	end

	panel_node_new.Update = function(object, dt)
		local lx = object:GetWidth()
		self.numberbox_net:SetWidth(lx-16-70)
		self.numberbox_sub:SetWidth(lx-16-70)
		self.ip_textinput:SetWidth(lx-16-70)
		self.numberbox_port:SetWidth(lx-16-70)
		self.choice_protocol:SetWidth(lx-16-70)
		self.numberbox_LED_nb:SetWidth(lx-16-70)

		local px = lx/4
		local sx = lx/2.5

		add_button:SetPos(px-(sx/2), start_y+step_y*8)
		add_button:SetWidth(sx)
		cancel_button:SetPos(px*3-(sx/2), start_y+step_y*8)
		cancel_button:SetWidth(sx)
	end
	self.panel_node_new = panel_node_new
	return panel_node_new
end

function new_node:reload(net, sub, ip, port, protocol, rgbw, led_nb)
	print(net, sub, ip, port, protocol, rgbw, led_nb)
	self.numberbox_net:SetValue(net or 0)
	self.numberbox_sub:SetValue(sub or 0)
	self.ip_textinput:SetText(ip or "192.168.1.1")
	self.numberbox_port:SetValue(port or 6454)
	self.choice_protocol:SelectChoice(protocol)
	self.rgbw_checkbox:SetChecked(false)
	self.numberbox_LED_nb:SetValue(led_nb or 170)
end

return new_node
