local twitch = {}
local path = ...

require(path.."/irc")

local nick    = "spectrenoir06_bot"
local oauth   = ""
local channel = "spectrenoir06"

local div = 1

local http = require 'socket.http'

local function hex(hex) 
	local r,g,
	b=hex:match('#(..)(..)(..)')
	if r and g and b then
		return tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255
	else
		return 0,0,0
	end
end

love.filesystem.createDirectory("cache")
love.filesystem.createDirectory("cache/emotes")

function twitch:load(lx, ly)
	self.irc = irc.new{nick = nick}

	self.font = love.graphics.newFont(ly*0.9/div)
	self.font:setFilter("nearest","nearest")

	self.messages = {}
	self.emotes_img = {}

	self.irc:hook("OnChat_id",
		function(user, channel, message)
			print(("[%s] %s: %s"):format(channel, user, message))

			for k,v in pairs(user.emotes_t) do
				-- print(v.str, k)
				if not self.emotes_img[v.str] then
					local file = love.filesystem.read("cache/emotes/"..k..".png")
					if not file then
						local url = "http://antoine.doussaud.org/twitch_proxy/emoticons/v1/"..k.."/2.0"
						file = http.request(url)
						if file then
							print("load from twitch", url)
							love.filesystem.write("cache/emotes/"..k..".png", file)
						else
							print("can't load from twitch", url)
						end
					else
						print("load from cache", "cache/emotes/"..k..".png")
					end
					if file then 
						local file_data = love.filesystem.newFileData(file, '')
						if file_data:getSize() > 0 then
							local img_data = love.image.newImageData(file_data)
							local img = love.graphics.newImage(img_data)
							local ky = ly / img:getHeight() / div
							self.emotes_img[v.str] = {
								img = img,
								img_data = img_data,
								lx = img:getWidth() * ky,
								ly = img:getHeight() * ky,
								k = ky
							}
						end
					end
				end
			end

			local msg = {
				nick = user.nick,
				data = {},
				emotes_by_pos = user.emotes_by_pos
			}

			local pos_c = 1
			local pos   = 0

			local nick = string.format("%s: ", user.nick)
			local r,g,b = hex(user.color or "#000000")

			table.insert(msg.data, {
				text = {
					{r,g,b},
					nick
				},
				pos = pos
			})
			pos = pos + self.font:getWidth(nick)

			for k,v in ipairs(msg.emotes_by_pos) do
				if (pos_c < v.pos[1]) then
					local text = message:sub(pos_c, v.pos[1])
					table.insert(msg.data, {
						text = text,
						pos = pos
					})
					pos = pos + self.font:getWidth(text)
				end
				pos_c = v.pos[2]+2
				local em = self.emotes_img[v.str]
				table.insert(msg.data, {
					em = self.emotes_img[v.str],
					pos = pos
				})
				pos = pos + em.lx
			end
			local text = message:sub(pos_c)
			table.insert(msg.data, {
				text = text,
				pos = pos
			})
			pos = pos + self.font:getWidth(text)
			msg.size = pos
			table.insert(self.messages, msg)
		end
	)

	self.irc:connect({
		host = "irc.chat.twitch.tv",
		password = "oauth:"..oauth,
	}, 6667)
	print("connect")
	
	self.irc:join("#"..channel)
	self.irc:send("CAP REQ :twitch.tv/tags twitch.tv/commands")
	self.irc:think()
	
	-- self.irc:sendChat("#"..channel, "bonsoir @"..channel)
end

function twitch:update(dt, lx, ly)
	self.irc:think()
	love.graphics.setFont(self.font)
	love.graphics.clear(0,0,0,1)
	
	if self.messages[1] then
		local msg = self.messages[1]
		if not msg.x then msg.x = lx end 

		for k, v in ipairs(msg.data) do
			if v.em then
				love.graphics.draw(v.em.img, math.floor(v.pos+ msg.x), 0, 0, v.em.k, v.em.k)
			elseif v.text then
				love.graphics.print(v.text, math.floor(v.pos+msg.x), 0)
			end
		end

		msg.x = msg.x - dt*80
		if msg.x < -msg.size then
			table.remove( self.messages, 1)
		end
	end
end

return twitch
