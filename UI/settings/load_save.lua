local json = require("lib.json")

local load_save = {}

function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function load_save:load(loveframes, frame, tabs, start_y, step_y)
	-- local step_y = 15

	self.panel_load_save = loveframes.Create("panel")
	tabs:AddTab("Load/Save", self.panel_load_save, nil, "ressource/icons/json.png", function() self:reload() end)

	-- self.choice_file = loveframes.Create("multichoice", self.panel_load_save)
	-- self.choice_file:SetPos(8, 8)
	-- self.choice_file:SetSize(self.panel_load_save:GetWidth()-16, 25)

	self.list = loveframes.Create("columnlist", self.panel_load_save)
	self.list:SetPos(8, 8)
	self.list:SetSize((self.panel_load_save:GetWidth()-16)-230, self.panel_load_save:GetHeight()-16)
	self.list:AddColumn("Name").children[1].width = 120
	self.list:AddColumn("lx").children[2].width = 30
	self.list:AddColumn("ly").children[3].width = 30
	self.list:AddColumn("fps").children[4].width = 30
	self.list:AddColumn("nodes").children[5].width = 40
	self.list:AddColumn("pixels").children[6].width = 50
	self.list:AddColumn("change").children[7].width = 40
	--
	self.list:SetSelectionEnabled(true)
	-- self.list:SelectRow(1)

	-- self.choice_file:SelectChoice("42.map")

	self.panel_load_save:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)

	self.panel_load_save.Update = function(object)
		object:SetSize(frame:GetWidth()-16, frame:GetHeight()-60-4)
		-- self.choice_file:SetWidth(object:GetWidth()-16)
		self.list:SetSize((object:GetWidth()-16)-230, object:GetHeight()-16)

		self.panel_load_setting:SetSize(230-8, self.panel_load_save:GetHeight()-16)
		self.panel_load_setting:SetPos(self.panel_load_save:GetWidth()-230,8)
	end

	self.panel_load_setting = loveframes.Create("panel", self.panel_load_save)
	self.panel_load_setting:SetSize(230-8, self.panel_load_save:GetHeight()-16)
	self.panel_load_setting:SetPos(self.panel_load_save:GetWidth()-230,8)


	self.textinput_name = loveframes.Create("textinput", self.panel_load_setting)
	self.textinput_name:SetPos(8, start_y+step_y*0)
	self.textinput_name:SetWidth(230-16-8)
	-- self.textinput_name:SetFont(love.graphics.newFont(12))

	self.textinput_name.OnTextChanged = function(object, text)
		print(object:GetValue()..".map", mapping.name)
		self:checkChange()
	end


	self.button_save = loveframes.Create("button", self.panel_load_setting)
	self.button_save:SetWidth(60)
	self.button_save:SetText("Save")
	self.button_save:SetImage("ressource/icons/disk.png")
	self.button_save:SetPos(8, start_y+step_y*1)

	self.button_save.OnClick = function(object, x, y)
		if (self.textinput_name:GetValue()..".map") ~= mapping.name then
			local name = self.row_selected[1]
			local new_name = self.textinput_name:GetValue()..".map"
			print("remove", name)
			maps[name] = nil
			love.filesystem.remove("ressource/map/"..name)
			mapping.name = new_name
			maps[new_name] = mapping
			self.row_selected[1] = mapping.name
		end

		mapping.lx = self.lx:GetValue()
		mapping.ly = self.ly:GetValue()
		mapping.fps = self.fps:GetValue()

		local data = gen_map_file(mapping)
		love.filesystem.write("ressource/map/"..mapping.name, data)
		self:reload()
	end


	self.button_clone = loveframes.Create("button", self.panel_load_setting)
	self.button_clone:SetWidth(60)
	self.button_clone:SetText("Clone")
	self.button_clone:SetImage("ressource/icons/disks.png")
	self.button_clone:SetPos(60+8+8, start_y+step_y*1)

	self.button_clone.OnClick = function(object, x, y)
		local name = self.textinput_name:GetText()..".map"
		name = (name == ".map") and "_.map" or name
		print("Clone", name)
		local new_name = name
		if maps[new_name] then
			local nb = 2
			while (maps[new_name]) do
				new_name = name:match("^(.+).map$").."_"..nb..".map"
				nb = nb + 1
			end
		end

		maps[new_name] = copy(maps[self.row_selected[1]])
		maps[new_name].name = new_name

		-- local data = gen_map_file(maps[new_name])
		-- love.filesystem.write("ressource/map/"..new_name, data)

		self.list:AddRow(maps[new_name].name, maps[new_name].lx, maps[new_name].ly, maps[new_name].fps, #maps[new_name].nodes, #maps[new_name].map, false)
		self.list:SelectRow(self.list.internals[1].children[#self.list.internals[1].children])

		self:reload()
	end


	self.button_delete = loveframes.Create("button", self.panel_load_setting)
	self.button_delete:SetWidth(60)
	self.button_delete:SetText("Delete")
	self.button_delete:SetImage("ressource/icons/disk--minus.png")
	self.button_delete:SetPos(120+8+8+8, start_y+step_y*1)

	self.button_delete.OnClick = function(object, x, y)
		local name = self.row_selected[1]
		print("remove", name)
		maps[name] = nil
		love.filesystem.remove("ressource/map/"..name)
		self:load_list()
		self:reload()
	end


	self.button_undo = loveframes.Create("button", self.panel_load_setting)
	self.button_undo:SetWidth(60)
	self.button_undo:SetText("Undo")
	self.button_undo:SetImage("ressource/icons/clock-history-frame.png")
	self.button_undo:SetPos(8, start_y+step_y*2)

	self.button_undo.OnClick = function(object, x, y)
		local name = self.row_selected[1]
		print("undo", name)
		maps[name] = json.decode(love.filesystem.read("ressource/map/"..name))
		self.textinput_name:SetText(name:match("^(.+).map$"))
		self.row_selected[7] = "false"
		self.lx:SetValue(maps[name].lx)
		self.ly:SetValue(maps[name].ly)
		self.button_save:SetEnabled(false)
		self.button_undo:SetEnabled(false)
	end


	self.lx = loveframes.Create("numberbox", self.panel_load_setting)
	self.lx:SetPos(8, start_y+step_y*4)
	self.lx:SetSize(100, 25)
	self.lx:SetWidth(60)
	self.lx:SetMinMax(1, 9999)
	self.lx:SetValue(0)

	self.lx_text = loveframes.Create("text", self.panel_load_setting)
	self.lx_text:SetPos(8, start_y+step_y*3+16)
	self.lx_text:SetText("lx:")
	-- self.lx_text:SetFont(small_font)

	self.lx.OnValueChanged = function(obj, nb)
		mapping.lx = nb
		self:checkChange()
	end

	self.lx:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.lx:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end


	self.ly = loveframes.Create("numberbox", self.panel_load_setting)
	self.ly:SetPos(8+60+8, start_y+step_y*4)
	self.ly:SetSize(60, 25)
	self.ly:SetMinMax(1, 9999)
	self.ly:SetValue(0)

	self.ly_text = loveframes.Create("text", self.panel_load_setting)
	self.ly_text:SetPos(8+60+8, start_y+step_y*3+16)
	self.ly_text:SetText("ly:")
	-- self.ly_text:SetFont(small_font)

	self.ly.OnValueChanged = function(obj, nb)
		mapping.ly = nb
		self:checkChange()
	end


	self.ly:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.ly:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end




	self.fps = loveframes.Create("numberbox", self.panel_load_setting)
	self.fps:SetPos(8+60+8+60+8, start_y+step_y*4)
	self.fps:SetSize(60, 25)
	self.fps:SetMinMax(1, 2048)
	self.fps:SetValue(mapping.fps)

	self.fps_text = loveframes.Create("text", self.panel_load_setting)
	self.fps_text:SetPos(8+60+8+60+8, start_y+step_y*3+16)
	self.fps_text:SetText("FPS:")
	-- self.fps_text:SetFont(small_font)

	self.fps:GetInternals()[1].OnFocusGained = function(object, value)
		love.keyboard.setTextInput(true, frame:GetX(), frame:GetY(), frame:GetWidth(), frame:GetHeight())
	end

	self.fps:GetInternals()[1].OnFocusLost = function(object, value)
		love.keyboard.setTextInput(false)
	end

	self.fps.OnValueChanged = function(object)
		mapping.fps = self.fps:GetValue()
		self:checkChange()
	end


	self.row_selected = nil

	self.list.OnRowSelected = function(object, row, data)
		print("OnRowSelected", data[1])
		mapping = maps[data[1]]
		local channel_data = love.thread.getChannel("data")
		channel_data:supply({type = "map", data = mapping.map})
		channel_data:supply({type = "nodes", data = mapping.nodes})

		canvas = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas_test = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		spectre2d_canvas = love.graphics.newCanvas(mapping.lx, mapping.ly, {dpiscale = 1, mipmaps = "none"})
		canvas:setFilter("nearest", "nearest")
		canvas_test:setFilter("nearest", "nearest")
		spectre2d_canvas:setFilter("nearest", "nearest")

		self.button_save:SetEnabled(data[7] == "true")
		self.button_undo:SetEnabled(data[7] == "true")
		self.row_selected = data
		self.textinput_name:SetText(data[1]:match("^(.+).map$"))

		self.lx:SetValue(mapping.lx)
		self.ly:SetValue(mapping.ly)
		self.fps:SetValue(mapping.fps)
	end

	self:load_list()

end

function load_save:load_list()
	self.list:Clear()
	for k,v in pairs(maps) do
		self.list:AddRow(v.name, v.lx, v.ly, v.fps, #v.nodes, #v.map, false)
	end
	self.list.internals[1]:Sort(1, true)
	self.list:SelectRow(self.list.internals[1].children[1])
end

function load_save:checkChange()
	if mapping.lx   ~= tonumber(self.row_selected[2])
	or mapping.ly   ~= tonumber(self.row_selected[3])
	or mapping.fps  ~= tonumber(self.row_selected[4])
	or mapping.name ~= (self.textinput_name:GetValue()..".map")
	or self.row_selected[7] == "true"
	then
		self.button_save:SetEnabled(true)
		self.button_undo:SetEnabled(true)
	else
		self.button_save:SetEnabled(false)
		self.button_undo:SetEnabled(false)
	end
end

function load_save:reload()
	for k,v in ipairs(self.list.internals[1].children) do
		local name = v.columndata[1]
		local diff = (gen_map_file(maps[name]) ~= love.filesystem.read("ressource/map/"..name))
		v.columndata[2] = tostring(maps[name].lx)
		v.columndata[3] = tostring(maps[name].ly)
		v.columndata[4] = tostring(maps[name].fps)
		v.columndata[7] = tostring(diff)
	end
	self:checkChange()
end

return load_save
