-- Sniper Tag - Server Round Management
-- Beheert ronde lifecycle, timers, en win conditions

if CLIENT then return end

SniperTag = SniperTag or {}
SniperTag.Round = SniperTag.Round or {}

-- Round state
SniperTag.Round.State = SniperTag.Config.GameState.WAITING
SniperTag.Round.StartTime = 0
SniperTag.Round.EndTime = 0
SniperTag.Round.Duration = SniperTag.Config.RoundDuration

SniperTag.Round.Sniper = nil
SniperTag.Round.Hider = nil

-- Network strings
util.AddNetworkString("SniperTag_UpdateGameState")
util.AddNetworkString("SniperTag_RoundStart")
util.AddNetworkString("SniperTag_RoundEnd")
util.AddNetworkString("SniperTag_UpdateTimer")
util.AddNetworkString("SniperTag_UpdateRole")

-- Start een nieuwe ronde
function SniperTag.Round:Start()
	if self.State ~= SniperTag.Config.GameState.WAITING then
		print("[Sniper Tag] Cannot start - round already in progress!")
		return false
	end
	
	-- Check if we have enough players
	local players = player.GetAll()
	if #players < 2 then
		print("[Sniper Tag] Need at least 2 players to start!")
		return false
	end
	
	-- Check if roles are assigned
	if not IsValid(self.Sniper) or not IsValid(self.Hider) then
		print("[Sniper Tag] Roles not assigned! Please assign Sniper and Hider first.")
		return false
	end
	
	self.State = SniperTag.Config.GameState.STARTING
	self:BroadcastGameState()
	
	-- Countdown
	timer.Simple(3, function()
		if self.State == SniperTag.Config.GameState.STARTING then
			self:StartRound()
		end
	end)
	
	return true
end

-- Start de ronde daadwerkelijk
function SniperTag.Round:StartRound()
	self.State = SniperTag.Config.GameState.ACTIVE
	self.StartTime = CurTime()
	self.EndTime = self.StartTime + self.Duration
	
	-- Clear any existing timers
	timer.Remove("SniperTag_RoundTimer")
	
	-- Setup players
	self:SetupSniper(self.Sniper)
	self:SetupHider(self.Hider)
	
	-- Spawn players at random locations far apart
	self:SpawnPlayers()
	
	-- Broadcast start
	net.Start("SniperTag_RoundStart")
	net.WriteFloat(self.EndTime)
	net.Broadcast()
	
	-- Start round timer
	timer.Create("SniperTag_RoundTimer", 1, 0, function()
		if SniperTag.Round.State ~= SniperTag.Config.GameState.ACTIVE then
			timer.Remove("SniperTag_RoundTimer")
			return
		end
		
		-- Check if time is up
		if CurTime() >= SniperTag.Round.EndTime then
			SniperTag.Round:EndRound(SniperTag.Round.Hider, "Time's up! Hider survived!")
		end
		
		-- Update clients
		net.Start("SniperTag_UpdateTimer")
		net.WriteFloat(SniperTag.Round.EndTime - CurTime())
		net.Broadcast()
	end)
	
	self:BroadcastGameState()
	
	print("[Sniper Tag] Round started! Duration: " .. self.Duration .. " seconds")
	PrintMessage(HUD_PRINTTALK, "[Sniper Tag] Round has started! Sniper: " .. self.Sniper:Nick() .. " | Hider: " .. self.Hider:Nick())
end

-- Setup Sniper
function SniperTag.Round:SetupSniper(ply)
	if not IsValid(ply) then return end
	
	ply:StripWeapons()
	ply:SetHealth(SniperTag.Config.SniperHP)
	ply:SetMaxHealth(SniperTag.Config.SniperHP)
	
	-- Give weapons
	ply:Give(SniperTag.Config.Weapons.Sniper.Primary)
	ply:Give(SniperTag.Config.Weapons.Sniper.Secondary)
	ply:Give(SniperTag.Config.Weapons.Sniper.Melee)
	
	-- Set role
	ply:SetNWInt("SniperTag_Role", SniperTag.Config.Roles.SNIPER)
	
	-- Reset states
	ply.ThermalActiveEnd = nil
	ply.ThermalCooldownEnd = nil
	
	net.Start("SniperTag_UpdateRole")
	net.WriteInt(SniperTag.Config.Roles.SNIPER, 8)
	net.Send(ply)
	
	ply:ChatPrint("=== YOU ARE THE SNIPER ===")
	ply:ChatPrint("Hunt down the Hider before time runs out!")
end

-- Setup Hider
function SniperTag.Round:SetupHider(ply)
	if not IsValid(ply) then return end
	
	ply:StripWeapons()
	ply:SetHealth(SniperTag.Config.HiderHP)
	ply:SetMaxHealth(SniperTag.Config.HiderHP)
	
	-- Give weapons
	ply:Give(SniperTag.Config.Weapons.Hider.Primary)
	ply:Give(SniperTag.Config.Weapons.Hider.Secondary)
	ply:Give(SniperTag.Config.Weapons.Hider.Melee)
	
	-- Set role
	ply:SetNWInt("SniperTag_Role", SniperTag.Config.Roles.HIDER)
	
	-- Reset states
	ply.CloakActiveEnd = nil
	ply.CloakCooldownEnd = nil
	ply.CampPosition = nil
	ply.CampStartTime = nil
	ply.CampWarned = false
	
	net.Start("SniperTag_UpdateRole")
	net.WriteInt(SniperTag.Config.Roles.HIDER, 8)
	net.Send(ply)
	
	ply:ChatPrint("=== YOU ARE THE HIDER ===")
	ply:ChatPrint("Survive until the timer runs out! HP: " .. SniperTag.Config.HiderHP)
end

-- Spawn players ver van elkaar
function SniperTag.Round:SpawnPlayers()
	local spawns = {}
	
	-- Collect all spawn points
	for _, ent in ipairs(ents.FindByClass("info_player_*")) do
		table.insert(spawns, ent:GetPos())
	end
	
	-- If no spawn points, create them across the map
	if #spawns == 0 then
		print("[Sniper Tag] Warning: No spawn points found! Creating distributed positions.")
		-- Create a grid of potential spawn points
		for x = -5000, 5000, 1000 do
			for y = -5000, 5000, 1000 do
				table.insert(spawns, Vector(x, y, 0))
			end
		end
	end
	
	-- Find two spawns as far apart as possible
	local sniperPos, hiderPos
	local maxDistance = 0
	local attempts = 0
	local maxAttempts = math.min(#spawns * #spawns, 1000) -- Limit attempts but be thorough
	
	-- Try multiple combinations to find the furthest apart spawns
	for i = 1, math.min(#spawns, 50) do
		local pos1 = spawns[math.random(1, #spawns)]
		
		for j = 1, math.min(#spawns, 50) do
			local pos2 = spawns[math.random(1, #spawns)]
			local distance = pos1:Distance(pos2)
			
			if distance > maxDistance then
				maxDistance = distance
				sniperPos = pos1
				hiderPos = pos2
			end
			
			-- If we found a good distance, use it
			if distance >= SniperTag.Config.MinSpawnDistance then
				sniperPos = pos1
				hiderPos = pos2
				break
			end
		end
		
		if maxDistance >= SniperTag.Config.MinSpawnDistance then
			break
		end
	end
	
	-- Fallback: use furthest points found
	if not sniperPos or not hiderPos then
		sniperPos = spawns[1] or Vector(0, 0, 0)
		hiderPos = spawns[#spawns] or Vector(3000, 3000, 0)
	end
	
	print("[Sniper Tag] Spawn distance: " .. math.floor(sniperPos:Distance(hiderPos)) .. " units")
	
	-- Spawn players
	if IsValid(self.Sniper) then
		self.Sniper:SetPos(sniperPos + Vector(0, 0, 10)) -- Slight Z offset to prevent stuck
		self.Sniper:SetEyeAngles(Angle(0, math.random(0, 360), 0))
		self.Sniper:SetVelocity(Vector(0, 0, 0))
	end
	
	if IsValid(self.Hider) then
		self.Hider:SetPos(hiderPos + Vector(0, 0, 10))
		self.Hider:SetEyeAngles(Angle(0, math.random(0, 360), 0))
		self.Hider:SetVelocity(Vector(0, 0, 0))
	end
end

-- Einde van de ronde
function SniperTag.Round:EndRound(winner, reason)
	if self.State ~= SniperTag.Config.GameState.ACTIVE then return end
	
	self.State = SniperTag.Config.GameState.ENDING
	
	-- Stop timers
	timer.Remove("SniperTag_RoundTimer")
	timer.Remove("SniperTag_CampingCheck")
	
	-- Broadcast end
	local winnerName = IsValid(winner) and winner:Nick() or "Nobody"
	
	net.Start("SniperTag_RoundEnd")
	net.WriteString(winnerName)
	net.WriteString(reason or "Round ended")
	net.Broadcast()
	
	PrintMessage(HUD_PRINTTALK, "[Sniper Tag] " .. reason .. " Winner: " .. winnerName)
	
	-- Reset after delay
	timer.Simple(10, function()
		self:Reset()
	end)
	
	self:BroadcastGameState()
end

-- Reset de ronde
function SniperTag.Round:Reset()
	self.State = SniperTag.Config.GameState.WAITING
	self.StartTime = 0
	self.EndTime = 0
	
	-- Reset players
	for _, ply in ipairs(player.GetAll()) do
		-- Clear role
		ply:SetNWInt("SniperTag_Role", SniperTag.Config.Roles.NONE)
		
		-- Clear states
		ply.ThermalActiveEnd = nil
		ply.ThermalCooldownEnd = nil
		ply.CloakActiveEnd = nil
		ply.CloakCooldownEnd = nil
		ply.CampPosition = nil
		ply.CampStartTime = nil
		ply.CampWarned = nil
		ply.NextCampCheck = nil
		
		-- Reset visibility
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:SetColor(Color(255, 255, 255, 255))
		ply:SetMaterial("")
		
		-- Reset all weapons
		for _, wep in ipairs(ply:GetWeapons()) do
			if IsValid(wep) then
				wep:SetRenderMode(RENDERMODE_NORMAL)
				wep:SetColor(Color(255, 255, 255, 255))
			end
		end
		
		-- Respawn player
		ply:Spawn()
	end
	
	self:BroadcastGameState()
	
	print("[Sniper Tag] Round reset. Ready for new game.")
end

-- Assign roles
function SniperTag.Round:AssignSniper(ply)
	if not IsValid(ply) then return false end
	
	self.Sniper = ply
	print("[Sniper Tag] " .. ply:Nick() .. " assigned as Sniper")
	return true
end

function SniperTag.Round:AssignHider(ply)
	if not IsValid(ply) then return false end
	
	self.Hider = ply
	print("[Sniper Tag] " .. ply:Nick() .. " assigned as Hider")
	return true
end

-- Broadcast game state to all clients
function SniperTag.Round:BroadcastGameState()
	net.Start("SniperTag_UpdateGameState")
	net.WriteInt(self.State, 8)
	net.Broadcast()
end

-- Player death hook
hook.Add("PlayerDeath", "SniperTag_PlayerDeath", function(victim, inflictor, attacker)
	if SniperTag.Round.State ~= SniperTag.Config.GameState.ACTIVE then return end
	
	local victimRole = victim:GetNWInt("SniperTag_Role", 0)
	
	if victimRole == SniperTag.Config.Roles.HIDER then
		-- Hider died, Sniper wins
		SniperTag.Round:EndRound(SniperTag.Round.Sniper, "Sniper eliminated the Hider!")
	elseif victimRole == SniperTag.Config.Roles.SNIPER then
		-- Sniper died (unlikely but possible), Hider wins
		SniperTag.Round:EndRound(SniperTag.Round.Hider, "Hider eliminated the Sniper!")
	end
end)

-- Prevent players from spawning incorrectly during round
hook.Add("PlayerSpawn", "SniperTag_RespawnHandler", function(ply)
	if SniperTag.Round.State == SniperTag.Config.GameState.ACTIVE then
		local role = ply:GetNWInt("SniperTag_Role", 0)
		
		-- Small delay to ensure spawn happens properly
		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			
			if role == SniperTag.Config.Roles.SNIPER then
				SniperTag.Round:SetupSniper(ply)
			elseif role == SniperTag.Config.Roles.HIDER then
				SniperTag.Round:SetupHider(ply)
			end
		end)
	end
end)

-- Prevent players from picking up weapons during active round
hook.Add("PlayerCanPickupWeapon", "SniperTag_WeaponPickup", function(ply, wep)
	if SniperTag.Round.State == SniperTag.Config.GameState.ACTIVE then
		local role = ply:GetNWInt("SniperTag_Role", 0)
		
		-- Only allow picking up assigned weapons
		if role == SniperTag.Config.Roles.SNIPER or role == SniperTag.Config.Roles.HIDER then
			return false -- Prevent picking up other weapons
		end
	end
end)

-- Prevent damage between wrong players
hook.Add("EntityTakeDamage", "SniperTag_DamageControl", function(target, dmg)
	if SniperTag.Round.State ~= SniperTag.Config.GameState.ACTIVE then return end
	if not target:IsPlayer() then return end
	
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	
	local targetRole = target:GetNWInt("SniperTag_Role", 0)
	local attackerRole = attacker:GetNWInt("SniperTag_Role", 0)
	
	-- Sniper can only damage Hider
	if attackerRole == SniperTag.Config.Roles.SNIPER and targetRole ~= SniperTag.Config.Roles.HIDER then
		return true -- Block damage
	end
	
	-- Hider can only damage Sniper (with knife)
	if attackerRole == SniperTag.Config.Roles.HIDER and targetRole ~= SniperTag.Config.Roles.SNIPER then
		return true -- Block damage
	end
	
	-- Prevent Hider from damaging Sniper with marker gun (it's just a troll weapon)
	local weapon = attacker:GetActiveWeapon()
	if IsValid(weapon) and weapon:GetClass() == "weapon_marker" then
		return true -- Block damage (marker gun does no damage)
	end
end)

print("[Sniper Tag] Round management loaded!")
