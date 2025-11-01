-- Sniper Tag - Client Menu (Q-Menu Integration)
-- Provides admin interface for configuring and starting rounds

if SERVER then return end

-- Network message to request menu open
net.Receive("SniperTag_OpenMenu", function()
	OpenSniperTagMenu()
end)

-- Create menu
function OpenSniperTagMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 600)
	frame:Center()
	frame:SetTitle("Sniper Tag Settings")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	
	local y = 40
	
	-- Title
	local title = vgui.Create("DLabel", frame)
	title:SetPos(20, y)
	title:SetSize(460, 30)
	title:SetText("Configure Sniper Tag Round")
	title:SetFont("DermaLarge")
	title:SetTextColor(Color(255, 255, 255))
	y = y + 40
	
	-- Divider
	local divider1 = vgui.Create("DPanel", frame)
	divider1:SetPos(20, y)
	divider1:SetSize(460, 2)
	divider1.Paint = function(self, w, h)
		surface.SetDrawColor(100, 100, 100)
		surface.DrawRect(0, 0, w, h)
	end
	y = y + 15
	
	-- Round Duration Slider
	local durationLabel = vgui.Create("DLabel", frame)
	durationLabel:SetPos(20, y)
	durationLabel:SetSize(200, 20)
	durationLabel:SetText("Round Duration (minutes):")
	y = y + 25
	
	local durationValue = vgui.Create("DLabel", frame)
	durationValue:SetPos(400, y)
	durationValue:SetSize(80, 20)
	durationValue:SetText("10")
	durationValue:SetContentAlignment(6)
	
	local durationSlider = vgui.Create("DNumSlider", frame)
	durationSlider:SetPos(20, y)
	durationSlider:SetSize(350, 20)
	durationSlider:SetMin(5)
	durationSlider:SetMax(60)
	durationSlider:SetDecimals(0)
	durationSlider:SetValue(10)
	durationSlider.OnValueChanged = function(self, value)
		durationValue:SetText(math.floor(value))
	end
	durationSlider.Label:SetVisible(false)
	durationSlider.TextArea:SetVisible(false)
	y = y + 35
	
	-- Divider
	local divider2 = vgui.Create("DPanel", frame)
	divider2:SetPos(20, y)
	divider2:SetSize(460, 2)
	divider2.Paint = function(self, w, h)
		surface.SetDrawColor(100, 100, 100)
		surface.DrawRect(0, 0, w, h)
	end
	y = y + 15
	
	-- Sniper Selection
	local sniperLabel = vgui.Create("DLabel", frame)
	sniperLabel:SetPos(20, y)
	sniperLabel:SetSize(200, 20)
	sniperLabel:SetText("Select Sniper:")
	y = y + 25
	
	local sniperComboBox = vgui.Create("DComboBox", frame)
	sniperComboBox:SetPos(20, y)
	sniperComboBox:SetSize(460, 25)
	sniperComboBox:SetValue("-- Select Player --")
	
	for _, ply in ipairs(player.GetAll()) do
		sniperComboBox:AddChoice(ply:Nick(), ply)
	end
	y = y + 35
	
	-- Hider Selection
	local hiderLabel = vgui.Create("DLabel", frame)
	hiderLabel:SetPos(20, y)
	hiderLabel:SetSize(200, 20)
	hiderLabel:SetText("Select Hider:")
	y = y + 25
	
	local hiderComboBox = vgui.Create("DComboBox", frame)
	hiderComboBox:SetPos(20, y)
	hiderComboBox:SetSize(460, 25)
	hiderComboBox:SetValue("-- Select Player --")
	
	for _, ply in ipairs(player.GetAll()) do
		hiderComboBox:AddChoice(ply:Nick(), ply)
	end
	y = y + 45
	
	-- Divider
	local divider3 = vgui.Create("DPanel", frame)
	divider3:SetPos(20, y)
	divider3:SetSize(460, 2)
	divider3.Paint = function(self, w, h)
		surface.SetDrawColor(100, 100, 100)
		surface.DrawRect(0, 0, w, h)
	end
	y = y + 15
	
	-- Info Box
	local infoBox = vgui.Create("DPanel", frame)
	infoBox:SetPos(20, y)
	infoBox:SetSize(460, 120)
	infoBox.Paint = function(self, w, h)
		surface.SetDrawColor(50, 50, 50, 200)
		surface.DrawRect(0, 0, w, h)
		
		draw.SimpleText("Game Rules:", "DermaDefault", 10, 5, Color(255, 255, 100))
		draw.SimpleText("• Sniper: Hunt the Hider (100 HP, Sniper Rifle, Thermal)", "DermaDefault", 10, 25, Color(255, 255, 255))
		draw.SimpleText("• Hider: Survive until timer runs out (11 HP, Cloak, Knife)", "DermaDefault", 10, 40, Color(255, 255, 255))
		draw.SimpleText("• Thermal: 20s duration, 20s cooldown", "DermaDefault", 10, 60, Color(200, 200, 255))
		draw.SimpleText("• Cloak: 60s duration, 3min cooldown", "DermaDefault", 10, 75, Color(200, 200, 255))
		draw.SimpleText("• Anti-Camping: Hider revealed if stationary >60s", "DermaDefault", 10, 95, Color(255, 200, 200))
	end
	y = y + 130
	
	-- Start Button
	local startButton = vgui.Create("DButton", frame)
	startButton:SetPos(20, y)
	startButton:SetSize(220, 50)
	startButton:SetText("START ROUND")
	startButton:SetFont("DermaLarge")
	startButton.DoClick = function()
		-- Set duration
		local duration = math.floor(durationSlider:GetValue())
		RunConsoleCommand("snipertag_setduration", tostring(duration))
		
		-- Assign roles
		local sniperText, sniperPly = sniperComboBox:GetSelected()
		local hiderText, hiderPly = hiderComboBox:GetSelected()
		
		if IsValid(sniperPly) then
			RunConsoleCommand("snipertag_assign_sniper", sniperPly:Nick())
		end
		
		if IsValid(hiderPly) then
			RunConsoleCommand("snipertag_assign_hider", hiderPly:Nick())
		end
		
		-- Small delay before starting
		timer.Simple(0.5, function()
			RunConsoleCommand("snipertag_start")
		end)
		
		frame:Close()
		
		notification.AddLegacy("Starting Sniper Tag round...", NOTIFY_GENERIC, 3)
	end
	startButton.Paint = function(self, w, h)
		if self:IsHovered() then
			surface.SetDrawColor(0, 150, 0)
		else
			surface.SetDrawColor(0, 100, 0)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	
	-- Stop Button
	local stopButton = vgui.Create("DButton", frame)
	stopButton:SetPos(260, y)
	stopButton:SetSize(220, 50)
	stopButton:SetText("STOP ROUND")
	stopButton:SetFont("DermaLarge")
	stopButton.DoClick = function()
		RunConsoleCommand("snipertag_stop")
		frame:Close()
		notification.AddLegacy("Stopping round...", NOTIFY_GENERIC, 3)
	end
	stopButton.Paint = function(self, w, h)
		if self:IsHovered() then
			surface.SetDrawColor(150, 0, 0)
		else
			surface.SetDrawColor(100, 0, 0)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

-- Add to Q-Menu (Utilities tab)
hook.Add("PopulateToolMenu", "SniperTag_AddMenu", function()
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "SniperTag", "Sniper Tag", "", "", function(panel)
		panel:ClearControls()
		
		panel:Help("Sniper Tag Gamemode")
		panel:Help("A competitive hide-and-seek gamemode between a Sniper and a Hider.")
		
		panel:Button("Open Settings", "snipertag_menu")
		
		panel:Help("")
		panel:Help("Quick Commands:")
		
		panel:Help("Assign Sniper:")
		local sniperEntry = panel:TextEntry("Player Name")
		panel:Button("Set as Sniper", "").DoClick = function()
			RunConsoleCommand("snipertag_assign_sniper", sniperEntry:GetValue())
		end
		
		panel:Help("Assign Hider:")
		local hiderEntry = panel:TextEntry("Player Name")
		panel:Button("Set as Hider", "").DoClick = function()
			RunConsoleCommand("snipertag_assign_hider", hiderEntry:GetValue())
		end
		
		panel:Help("")
		panel:Button("Start Round", "snipertag_start")
		panel:Button("Stop Round", "snipertag_stop")
	end)
end)

print("[Sniper Tag] Client menu loaded!")
