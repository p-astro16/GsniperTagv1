-- Sniper Tag - Client HUD
-- Displays round timer, cooldowns, warnings, and role information

if SERVER then return end

SniperTag = SniperTag or {}
SniperTag.HUD = SniperTag.HUD or {}

-- HUD State
SniperTag.HUD.GameState = SniperTag.Config.GameState.WAITING
SniperTag.HUD.TimeRemaining = 0
SniperTag.HUD.PlayerRole = SniperTag.Config.Roles.NONE
SniperTag.HUD.CampWarning = false
SniperTag.HUD.CampWarningEnd = 0

-- Network receivers
net.Receive("SniperTag_UpdateGameState", function()
	SniperTag.HUD.GameState = net.ReadInt(8)
end)

net.Receive("SniperTag_UpdateTimer", function()
	SniperTag.HUD.TimeRemaining = net.ReadFloat()
end)

net.Receive("SniperTag_UpdateRole", function()
	SniperTag.HUD.PlayerRole = net.ReadInt(8)
end)

net.Receive("SniperTag_RoundStart", function()
	local endTime = net.ReadFloat()
	SniperTag.HUD.GameState = SniperTag.Config.GameState.ACTIVE
	
	-- Play start sound
	surface.PlaySound("HL1/fvox/activated.wav")
	
	-- Show notification
	notification.AddLegacy("Round Started!", NOTIFY_GENERIC, 5)
end)

net.Receive("SniperTag_RoundEnd", function()
	local winner = net.ReadString()
	local reason = net.ReadString()
	
	SniperTag.HUD.GameState = SniperTag.Config.GameState.ENDING
	
	-- Play end sound
	surface.PlaySound("HL1/fvox/deactivated.wav")
	
	-- Show notification
	notification.AddLegacy("Round Ended! Winner: " .. winner, NOTIFY_GENERIC, 10)
	
	-- Show big message
	timer.Simple(0.5, function()
		chat.AddText(Color(255, 255, 0), "==================")
		chat.AddText(Color(255, 100, 100), "ROUND ENDED!")
		chat.AddText(Color(100, 255, 100), "Winner: ", Color(255, 255, 255), winner)
		chat.AddText(Color(150, 150, 255), reason)
		chat.AddText(Color(255, 255, 0), "==================")
	end)
end)

net.Receive("SniperTag_CampWarning", function()
	local warningTime = net.ReadInt(16)
	SniperTag.HUD.CampWarning = true
	SniperTag.HUD.CampWarningEnd = CurTime() + warningTime
	
	surface.PlaySound("buttons/button10.wav")
end)

net.Receive("SniperTag_CampReveal", function()
	local pos = net.ReadVector()
	
	-- Visual indicator on screen
	notification.AddLegacy("Hider position revealed on your HUD!", NOTIFY_HINT, 5)
	surface.PlaySound("buttons/button9.wav")
	
	-- Store position for HUD rendering
	SniperTag.HUD.RevealedPosition = pos
	SniperTag.HUD.RevealedPositionEnd = CurTime() + 10
end)

-- Format time as MM:SS
local function FormatTime(seconds)
	seconds = math.max(0, seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d", mins, secs)
end

-- Draw HUD
hook.Add("HUDPaint", "SniperTag_DrawHUD", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Only draw during active round
	if SniperTag.HUD.GameState ~= SniperTag.Config.GameState.ACTIVE then
		-- Draw waiting message
		if SniperTag.HUD.GameState == SniperTag.Config.GameState.WAITING then
			draw.SimpleText("Waiting for round to start...", "DermaLarge", scrW / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		return
	end
	
	-- Draw round timer (top center)
	local timerText = "Time: " .. FormatTime(SniperTag.HUD.TimeRemaining)
	draw.RoundedBox(8, scrW / 2 - 100, 10, 200, 50, SniperTag.Config.Colors.Black)
	draw.SimpleText(timerText, "DermaLarge", scrW / 2, 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	-- Draw role indicator (top left)
	local roleText = "Role: "
	local roleColor = Color(255, 255, 255)
	
	if SniperTag.HUD.PlayerRole == SniperTag.Config.Roles.SNIPER then
		roleText = roleText .. "SNIPER"
		roleColor = SniperTag.Config.Colors.Sniper
	elseif SniperTag.HUD.PlayerRole == SniperTag.Config.Roles.HIDER then
		roleText = roleText .. "HIDER"
		roleColor = SniperTag.Config.Colors.Hider
	else
		roleText = roleText .. "SPECTATOR"
	end
	
	draw.RoundedBox(8, 10, 10, 150, 40, SniperTag.Config.Colors.Black)
	draw.SimpleText(roleText, "DermaDefault", 85, 30, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	-- Draw HP (top left, below role)
	draw.RoundedBox(8, 10, 60, 150, 30, SniperTag.Config.Colors.Black)
	local hpColor = ply:Health() > 50 and Color(100, 255, 100) or Color(255, 100, 100)
	draw.SimpleText("HP: " .. ply:Health(), "DermaDefault", 85, 75, hpColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	-- Draw Thermal Camera status (for Sniper)
	if SniperTag.HUD.PlayerRole == SniperTag.Config.Roles.SNIPER then
		local yPos = 100
		
		if ply.ThermalActive and ply.ThermalEndTime and CurTime() < ply.ThermalEndTime then
			-- Thermal is active
			local timeLeft = math.ceil(ply.ThermalEndTime - CurTime())
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(0, 100, 0, 200))
			draw.SimpleText("🔥 Thermal: " .. timeLeft .. "s", "DermaDefault", 100, yPos + 15, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif ply.ThermalCooldownEnd and CurTime() < ply.ThermalCooldownEnd then
			-- Thermal on cooldown
			local timeLeft = math.ceil(ply.ThermalCooldownEnd - CurTime())
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(100, 0, 0, 200))
			draw.SimpleText("🔥 Cooldown: " .. timeLeft .. "s", "DermaDefault", 100, yPos + 15, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			-- Thermal ready
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(0, 50, 0, 200))
			draw.SimpleText("🔥 Thermal: READY", "DermaDefault", 100, yPos + 15, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	-- Draw Cloak Device status (for Hider)
	if SniperTag.HUD.PlayerRole == SniperTag.Config.Roles.HIDER then
		local yPos = 100
		
		if ply.CloakActive and ply.CloakActiveEnd and CurTime() < ply.CloakActiveEnd then
			-- Cloak is active - GROTE COUNTDOWN IN HET MIDDEN
			local timeLeft = math.ceil(ply.CloakActiveEnd - CurTime())
			
			-- Small indicator in top left
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(0, 100, 200, 230))
			draw.SimpleText("👻 Cloak: ACTIVE", "DermaDefault", 100, yPos + 15, Color(150, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- BIG COUNTDOWN in center of screen
			local centerY = scrH / 2 - 100
			
			-- Pulsing effect
			local pulse = math.abs(math.sin(CurTime() * 2))
			local boxSize = 300 + pulse * 20
			local fontSize = 80 + pulse * 10
			
			-- Semi-transparent background
			draw.RoundedBox(16, scrW / 2 - boxSize / 2, centerY - 60, boxSize, 120, Color(0, 0, 50, 180))
			
			-- Outer glow
			draw.RoundedBox(16, scrW / 2 - boxSize / 2 - 4, centerY - 64, boxSize + 8, 128, Color(100, 150, 255, 50 + pulse * 50))
			
			-- Timer text
			surface.SetFont("DermaLarge")
			local text = "INVISIBLE: " .. timeLeft .. "s"
			local textW, textH = surface.GetTextSize(text)
			
			-- Draw with glow effect
			for i = 1, 3 do
				local offset = i * 2
				draw.SimpleText(text, "DermaLarge", scrW / 2, centerY, Color(100, 150, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			-- Main text
			draw.SimpleText(text, "DermaLarge", scrW / 2, centerY, Color(150, 200, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- Warning when time is low
			if timeLeft <= 10 then
				local warningAlpha = math.abs(math.sin(CurTime() * 6)) * 255
				draw.SimpleText("⚠ CLOAK ENDING SOON ⚠", "DermaDefault", scrW / 2, centerY + 40, Color(255, 200, 0, warningAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
		elseif ply.CloakCooldownEnd and CurTime() < ply.CloakCooldownEnd then
			-- Cloak on cooldown
			local timeLeft = math.ceil(ply.CloakCooldownEnd - CurTime())
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(100, 0, 0, 200))
			draw.SimpleText("👻 Cooldown: " .. FormatTime(timeLeft), "DermaDefault", 100, yPos + 15, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			-- Cloak ready
			draw.RoundedBox(8, 10, yPos, 180, 30, Color(0, 100, 0, 200))
			draw.SimpleText("👻 Cloak: READY", "DermaDefault", 100, yPos + 15, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		-- Draw camping warning
		if SniperTag.HUD.CampWarning and CurTime() < SniperTag.HUD.CampWarningEnd then
			local timeLeft = math.ceil(SniperTag.HUD.CampWarningEnd - CurTime())
			local alpha = math.abs(math.sin(CurTime() * 5)) * 255
			
			draw.RoundedBox(8, scrW / 2 - 200, scrH - 150, 400, 60, Color(150, 0, 0, 200))
			draw.SimpleText("⚠️ MOVE NOW! ⚠️", "DermaLarge", scrW / 2, scrH - 135, Color(255, 255, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("Position revealed in: " .. timeLeft .. "s", "DermaDefault", scrW / 2, scrH - 105, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			SniperTag.HUD.CampWarning = false
		end
	end
	
	-- Draw revealed position indicator (for Sniper)
	if SniperTag.HUD.PlayerRole == SniperTag.Config.Roles.SNIPER and SniperTag.HUD.RevealedPosition then
		if CurTime() < SniperTag.HUD.RevealedPositionEnd then
			local pos = SniperTag.HUD.RevealedPosition:ToScreen()
			
			if pos.visible then
				local distance = LocalPlayer():GetPos():Distance(SniperTag.HUD.RevealedPosition)
				local alpha = math.abs(math.sin(CurTime() * 3)) * 255
				
				draw.SimpleText("⚠ HIDER LOCATION ⚠", "DermaLarge", pos.x, pos.y - 30, Color(255, 0, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(math.floor(distance / 50) .. "m", "DermaDefault", pos.x, pos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				-- Draw circle around position
				surface.DrawCircle(pos.x, pos.y, 20, 255, 0, 0, alpha)
			end
		else
			SniperTag.HUD.RevealedPosition = nil
		end
	end
end)

-- Helper function to draw circles
function surface.DrawCircle(x, y, radius, r, g, b, a)
	local circle = {}
	local segments = 32
	
	for i = 0, segments do
		local angle = math.rad((i / segments) * 360)
		table.insert(circle, {
			x = x + math.cos(angle) * radius,
			y = y + math.sin(angle) * radius
		})
	end
	
	surface.SetDrawColor(r, g, b, a or 255)
	
	for i = 1, #circle - 1 do
		surface.DrawLine(circle[i].x, circle[i].y, circle[i + 1].x, circle[i + 1].y)
	end
end

print("[Sniper Tag] Client HUD loaded!")
