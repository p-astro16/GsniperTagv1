-- Cloak Device Weapon
-- Maakt de Hider 1 minuut onzichtbaar
-- Cooldown van 3 minuten

SWEP.PrintName = "Cloak Device"
SWEP.Author = "Sniper Tag"
SWEP.Instructions = "Left Click: Activate cloak (60s duration, 3min cooldown)"
SWEP.Category = "Sniper Tag"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.UseHands = true

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	-- Check if on cooldown
	if ply.CloakCooldownEnd and CurTime() < ply.CloakCooldownEnd then
		local timeLeft = math.ceil(ply.CloakCooldownEnd - CurTime())
		ply:ChatPrint("Cloak device on cooldown! " .. timeLeft .. " seconds remaining.")
		return
	end
	
	-- Check if already active
	if ply.CloakActiveEnd and CurTime() < ply.CloakActiveEnd then
		ply:ChatPrint("Cloak device is already active!")
		return
	end
	
	-- Activate cloak
	ply.CloakActiveEnd = CurTime() + SniperTag.Config.CloakDuration
	ply.CloakCooldownEnd = ply.CloakActiveEnd + SniperTag.Config.CloakCooldown
	
	-- Make player invisible
	ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetColor(Color(255, 255, 255, 0))
	ply:SetMaterial("sprites/heatwave")
	
	-- Hide all weapons
	for _, wep in ipairs(ply:GetWeapons()) do
		if IsValid(wep) then
			wep:SetRenderMode(RENDERMODE_TRANSALPHA)
			wep:SetColor(Color(255, 255, 255, 0))
		end
	end
	
	net.Start("SniperTag_ActivateCloak")
	net.WriteFloat(ply.CloakActiveEnd)
	net.WriteFloat(ply.CloakCooldownEnd)
	net.Send(ply)
	
	self:EmitSound("ambient/energy/weld1.wav", 75, 150)
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	-- Deactivate cloak early
	if CLIENT then return end
	
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	if ply.CloakActiveEnd and CurTime() < ply.CloakActiveEnd then
		-- Deactivate
		ply.CloakActiveEnd = CurTime()
		
		-- Make player visible again
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:SetColor(Color(255, 255, 255, 255))
		ply:SetMaterial("")
		
		-- Show all weapons
		for _, wep in ipairs(ply:GetWeapons()) do
			if IsValid(wep) then
				wep:SetRenderMode(RENDERMODE_NORMAL)
				wep:SetColor(Color(255, 255, 255, 255))
			end
		end
		
		net.Start("SniperTag_DeactivateCloak")
		net.Send(ply)
		
		self:EmitSound("ambient/energy/weld2.wav", 75, 100)
	end
	
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Think()
	if SERVER then
		local ply = self:GetOwner()
		if IsValid(ply) then
			-- Auto-deactivate when time runs out
			if ply.CloakActiveEnd and CurTime() >= ply.CloakActiveEnd then
				ply:SetRenderMode(RENDERMODE_NORMAL)
				ply:SetColor(Color(255, 255, 255, 255))
				ply:SetMaterial("")
				
				-- Show all weapons
				for _, wep in ipairs(ply:GetWeapons()) do
					if IsValid(wep) then
						wep:SetRenderMode(RENDERMODE_NORMAL)
						wep:SetColor(Color(255, 255, 255, 255))
					end
				end
				
				net.Start("SniperTag_DeactivateCloak")
				net.Send(ply)
				
				ply.CloakActiveEnd = nil
			end
			
			-- Keep all weapons invisible while cloaked
			if ply.CloakActiveEnd and CurTime() < ply.CloakActiveEnd then
				for _, wep in ipairs(ply:GetWeapons()) do
					if IsValid(wep) and wep:GetColor().a > 0 then
						wep:SetRenderMode(RENDERMODE_TRANSALPHA)
						wep:SetColor(Color(255, 255, 255, 0))
					end
				end
			end
		end
	end
end

function SWEP:DrawHUD()
	-- HUD wordt getekend door cl_hud.lua
end

if SERVER then
	util.AddNetworkString("SniperTag_ActivateCloak")
	util.AddNetworkString("SniperTag_DeactivateCloak")
end

if CLIENT then
	local cloakActive = false
	local cloakEndTime = 0
	local cooldownEndTime = 0
	
	net.Receive("SniperTag_ActivateCloak", function()
		cloakEndTime = net.ReadFloat()
		cooldownEndTime = net.ReadFloat()
		cloakActive = true
		
		LocalPlayer():EmitSound("ambient/energy/weld1.wav", 75, 150)
	end)
	
	net.Receive("SniperTag_DeactivateCloak", function()
		cloakActive = false
		LocalPlayer():EmitSound("ambient/energy/weld2.wav", 75, 100)
	end)
	
	-- Store data for HUD access
	hook.Add("Think", "SniperTag_CloakThink", function()
		local ply = LocalPlayer()
		if IsValid(ply) then
			ply.CloakActive = cloakActive
			ply.CloakActiveEnd = cloakEndTime
			ply.CloakCooldownEnd = cooldownEndTime
		end
	end)
end
