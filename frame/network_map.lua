local network_map = {}

function network_map:load(loveframes)
	local frame = loveframes.Create("frame")
	frame:SetName("Network Map")
	frame:SetSize(600, 200)
	frame:SetPos(0, 600)

	frame:SetResizable(true)
	frame:SetMaxWidth(1000)
	frame:SetMaxHeight(1000)
	frame:SetMinWidth(200)
	frame:SetMinHeight(200)

	frame:SetDockable(true)

	network_map = loveframes.Create("columnlist", frame)
	network_map:SetPos(5, 30)
	network_map:SetSize(frame:GetWidth()-10, frame:GetHeight()-30-5)
	network_map:AddColumn("net")
	network_map:AddColumn("subnet")
	network_map:AddColumn("ip")
	network_map:AddColumn("port")
	network_map:AddColumn("Sync")
	network_map:AddColumn("On")

	for i=0,8 do
		network_map:AddRow(
			0,
			i,
			"192.168.1."..i,
			6454,
			nb_port,
			bindIndex,
			"False",
			"True"
		)
	end
end

return network_map
