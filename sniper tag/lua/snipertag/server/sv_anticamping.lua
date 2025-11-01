-- Sniper Tag - Anti-Camping System
-- Tracks Hider's position and warns/reveals if camping

if CLIENT then return end

util.AddNetworkString("SniperTag_CampWarning")
util.AddNetworkString("SniperTag_CampReveal")

-- Initialize camping check on round start
hook.Add("Think", "SniperTag_CampingCheck", function()
	if SniperTag.Round.State ~= SniperTag.Config.GameState.ACTIVE then return end
	
	local hider = SniperTag.Round.Hider
	if not IsValid(hider) or not hider:Alive() then return end
	
	-- Only check once per second
	hider.NextCampCheck = hider.NextCampCheck or 0
	if CurTime() < hider.NextCampCheck then return end
	hider.NextCampCheck = CurTime() + 1
	
	local currentPos = hider:GetPos()
	
	-- Initialize camping tracking
	if not hider.CampPosition then
		hider.CampPosition = currentPos
		hider.CampStartTime = CurTime()
		hider.CampWarned = false
		print("[Sniper Tag] Anti-camp: Started tracking for " .. hider:Nick())
		return
	end
	
	-- Check if player moved outside camp radius
	local distance = currentPos:Distance(hider.CampPosition)
	
	if distance > SniperTag.Config.CampRadius then
		-- Player moved, reset tracking
		hider.CampPosition = currentPos
		hider.CampStartTime = CurTime()
		hider.CampWarned = false
		return
	end
	
	-- Player is within camp radius
	local campTime = CurTime() - hider.CampStartTime
	local timeUntilReveal = SniperTag.Config.CampTime - campTime
	
	-- Debug info
	if math.floor(campTime) % 5 == 0 then
		print("[Sniper Tag] Anti-camp: " .. hider:Nick() .. " camping for " .. math.floor(campTime) .. "s (distance moved: " .. math.floor(distance) .. " units)")
	end
	
	-- Send warning at 10 seconds remaining
	if timeUntilReveal <= SniperTag.Config.CampWarningTime and not hider.CampWarned then
		hider.CampWarned = true
		
		net.Start("SniperTag_CampWarning")
		net.WriteInt(SniperTag.Config.CampWarningTime, 16)
		net.Send(hider)
		
		hider:ChatPrint("⚠️ WARNING: Move or your position will be revealed in " .. SniperTag.Config.CampWarningTime .. " seconds!")
		hider:EmitSound("buttons/button10.wav", 75, 80)
		
		print("[Sniper Tag] Anti-camp: Warning sent to " .. hider:Nick())
	end
	
	-- Reveal position if camping too long
	if campTime >= SniperTag.Config.CampTime then
		local sniper = SniperTag.Round.Sniper
		
		print("[Sniper Tag] Anti-camp: REVEALING " .. hider:Nick() .. "'s position!")
		
		if IsValid(sniper) then
			-- Send position to Sniper
			net.Start("SniperTag_CampReveal")
			net.WriteVector(currentPos)
			net.Send(sniper)
			
			sniper:ChatPrint("⚠️ HIDER LOCATION REVEALED - They camped for too long!")
			sniper:EmitSound("buttons/button9.wav", 75, 120)
			
			-- Create temporary marker in world
			local marker = ents.Create("prop_physics")
			if IsValid(marker) then
				marker:SetModel("models/hunter/blocks/cube025x025x025.mdl")
				marker:SetPos(currentPos + Vector(0, 0, 50))
				marker:SetAngles(Angle(0, 0, 0))
				marker:SetColor(Color(255, 0, 0, 200))
				marker:SetRenderMode(RENDERMODE_TRANSALPHA)
				marker:SetCollisionGroup(COLLISION_GROUP_WORLD)
				marker:SetMaterial("models/debug/debugwhite")
				marker:Spawn()
				
				local phys = marker:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
				
				-- Remove marker after 10 seconds
				timer.Simple(10, function()
					if IsValid(marker) then
						marker:Remove()
					end
				end)
			end
		end
		
		-- Notify hider
		hider:ChatPrint("⚠️ YOUR POSITION HAS BEEN REVEALED TO THE SNIPER!")
		hider:EmitSound("ambient/alarms/warningbell1.wav", 75, 100)
		
		-- Reset camping detection with grace period
		hider.CampPosition = currentPos
		hider.CampStartTime = CurTime() + 30 -- Grace period before next detection
		hider.CampWarned = false
	end
end)

print("[Sniper Tag] Anti-camping system loaded!")
