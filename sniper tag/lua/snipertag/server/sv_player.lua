-- Sniper Tag - Server Player Management
-- Handles player-specific server-side logic

if CLIENT then return end

-- Network strings
util.AddNetworkString("SniperTag_OpenMenu")

-- Player initialization
hook.Add("PlayerInitialSpawn", "SniperTag_PlayerInit", function(ply)
	ply:SetNWInt("SniperTag_Role", SniperTag.Config.Roles.NONE)
	
	-- Send current game state
	timer.Simple(1, function()
		if IsValid(ply) then
			net.Start("SniperTag_UpdateGameState")
			net.WriteInt(SniperTag.Round.State, 8)
			net.Send(ply)
			
			-- If round is active, send timer
			if SniperTag.Round.State == SniperTag.Config.GameState.ACTIVE then
				net.Start("SniperTag_UpdateTimer")
				net.WriteFloat(math.max(0, SniperTag.Round.EndTime - CurTime()))
				net.Send(ply)
			end
		end
	end)
end)

-- Player disconnect
hook.Add("PlayerDisconnected", "SniperTag_PlayerDisconnect", function(ply)
	-- If a key player disconnects during active round, end it
	if SniperTag.Round.State == SniperTag.Config.GameState.ACTIVE then
		if ply == SniperTag.Round.Sniper then
			SniperTag.Round:EndRound(SniperTag.Round.Hider, "Sniper disconnected!")
		elseif ply == SniperTag.Round.Hider then
			SniperTag.Round:EndRound(SniperTag.Round.Sniper, "Hider disconnected!")
		end
	end
	
	-- Clear role assignments
	if ply == SniperTag.Round.Sniper then
		SniperTag.Round.Sniper = nil
	elseif ply == SniperTag.Round.Hider then
		SniperTag.Round.Hider = nil
	end
end)

-- Console commands for role assignment
concommand.Add("snipertag_assign_sniper", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can assign roles!")
		return
	end
	
	if SniperTag.Round.State ~= SniperTag.Config.GameState.WAITING then
		ply:ChatPrint("Cannot assign roles while round is active!")
		return
	end
	
	if #args < 1 then
		ply:ChatPrint("Usage: snipertag_assign_sniper <player_name>")
		return
	end
	
	local targetName = table.concat(args, " ")
	local target = nil
	
	for _, p in ipairs(player.GetAll()) do
		if string.find(string.lower(p:Nick()), string.lower(targetName)) then
			target = p
			break
		end
	end
	
	if not IsValid(target) then
		ply:ChatPrint("Player not found!")
		return
	end
	
	SniperTag.Round:AssignSniper(target)
	ply:ChatPrint(target:Nick() .. " assigned as Sniper!")
	PrintMessage(HUD_PRINTTALK, "[Sniper Tag] " .. target:Nick() .. " is now the Sniper!")
end)

concommand.Add("snipertag_assign_hider", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can assign roles!")
		return
	end
	
	if SniperTag.Round.State ~= SniperTag.Config.GameState.WAITING then
		ply:ChatPrint("Cannot assign roles while round is active!")
		return
	end
	
	if #args < 1 then
		ply:ChatPrint("Usage: snipertag_assign_hider <player_name>")
		return
	end
	
	local targetName = table.concat(args, " ")
	local target = nil
	
	for _, p in ipairs(player.GetAll()) do
		if string.find(string.lower(p:Nick()), string.lower(targetName)) then
			target = p
			break
		end
	end
	
	if not IsValid(target) then
		ply:ChatPrint("Player not found!")
		return
	end
	
	SniperTag.Round:AssignHider(target)
	ply:ChatPrint(target:Nick() .. " assigned as Hider!")
	PrintMessage(HUD_PRINTTALK, "[Sniper Tag] " .. target:Nick() .. " is now the Hider!")
end)

concommand.Add("snipertag_start", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can start rounds!")
		return
	end
	
	local success = SniperTag.Round:Start()
	if not success then
		ply:ChatPrint("Failed to start round! Make sure roles are assigned and at least 2 players are present.")
	end
end)

concommand.Add("snipertag_stop", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can stop rounds!")
		return
	end
	
	if SniperTag.Round.State ~= SniperTag.Config.GameState.ACTIVE then
		ply:ChatPrint("No round is currently active!")
		return
	end
	
	SniperTag.Round:EndRound(nil, "Round stopped by admin!")
end)

concommand.Add("snipertag_setduration", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can change round duration!")
		return
	end
	
	if #args < 1 then
		ply:ChatPrint("Usage: snipertag_setduration <minutes>")
		return
	end
	
	local minutes = tonumber(args[1])
	if not minutes or minutes < 5 or minutes > 60 then
		ply:ChatPrint("Duration must be between 5 and 60 minutes!")
		return
	end
	
	SniperTag.Round.Duration = minutes * 60
	ply:ChatPrint("Round duration set to " .. minutes .. " minutes!")
	PrintMessage(HUD_PRINTTALK, "[Sniper Tag] Round duration set to " .. minutes .. " minutes")
end)

concommand.Add("snipertag_menu", function(ply, cmd, args)
	if not IsValid(ply) then return end
	
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only admins can open the menu!")
		return
	end
	
	-- Send menu open signal to client
	net.Start("SniperTag_OpenMenu")
	net.Send(ply)
end)

print("[Sniper Tag] Player management loaded!")
