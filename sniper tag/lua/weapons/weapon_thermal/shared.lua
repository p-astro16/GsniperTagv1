-- Thermal Camera Weapon
-- Geeft de Sniper een thermal vision overlay voor 20 seconden
-- Cooldown van 20 seconden na gebruik

SWEP.PrintName = "Thermal Camera"
SWEP.Author = "Sniper Tag"
SWEP.Instructions = "Left Click: Activate thermal vision (20s duration, 20s cooldown)"
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

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

function SWEP:Initialize()
	self:SetHoldType("camera")
	
	if CLIENT then
		self.ThermalActive = false
		self.ThermalEndTime = 0
		self.CooldownEndTime = 0
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	-- Check if on cooldown
	if ply.ThermalCooldownEnd and CurTime() < ply.ThermalCooldownEnd then
		ply:ChatPrint("Thermal camera is on cooldown!")
		return
	end
	
	-- Check if already active
	if ply.ThermalActiveEnd and CurTime() < ply.ThermalActiveEnd then
		ply:ChatPrint("Thermal camera is already active!")
		return
	end
	
	-- Activate thermal
	ply.ThermalActiveEnd = CurTime() + SniperTag.Config.ThermalDuration
	ply.ThermalCooldownEnd = ply.ThermalActiveEnd + SniperTag.Config.ThermalCooldown
	
	net.Start("SniperTag_ActivateThermal")
	net.WriteFloat(ply.ThermalActiveEnd)
	net.WriteFloat(ply.ThermalCooldownEnd)
	net.Send(ply)
	
	self:EmitSound("buttons/button14.wav")
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	-- Deactivate thermal early if needed
	if CLIENT then return end
	
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	if ply.ThermalActiveEnd and CurTime() < ply.ThermalActiveEnd then
		-- Deactivate maar behoud cooldown
		ply.ThermalActiveEnd = CurTime()
		
		net.Start("SniperTag_DeactivateThermal")
		net.Send(ply)
		
		self:EmitSound("buttons/button10.wav")
	end
	
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Think()
	if SERVER then
		local ply = self:GetOwner()
		if IsValid(ply) then
			-- Auto-deactivate when time runs out
			if ply.ThermalActiveEnd and CurTime() >= ply.ThermalActiveEnd then
				net.Start("SniperTag_DeactivateThermal")
				net.Send(ply)
				ply.ThermalActiveEnd = nil
			end
		end
	end
end

function SWEP:DrawHUD()
	-- HUD wordt getekend door cl_hud.lua
end

if SERVER then
	util.AddNetworkString("SniperTag_ActivateThermal")
	util.AddNetworkString("SniperTag_DeactivateThermal")
end

if CLIENT then
	local thermalActive = false
	local thermalEndTime = 0
	local cooldownEndTime = 0
	
	net.Receive("SniperTag_ActivateThermal", function()
		thermalEndTime = net.ReadFloat()
		cooldownEndTime = net.ReadFloat()
		thermalActive = true
		
		LocalPlayer():EmitSound("buttons/button14.wav")
	end)
	
	net.Receive("SniperTag_DeactivateThermal", function()
		thermalActive = false
	end)
	
	-- Store data for HUD access
	hook.Add("Think", "SniperTag_ThermalThink", function()
		local ply = LocalPlayer()
		if IsValid(ply) then
			ply.ThermalActive = thermalActive
			ply.ThermalEndTime = thermalEndTime
			ply.ThermalCooldownEnd = cooldownEndTime
		end
	end)
	
	-- Thermal Camera Filter - Full screen thermal imaging effect
	local mat_noise = Material("effects/tvscreen_noise002a")
	
	hook.Add("RenderScreenspaceEffects", "SniperTag_ThermalFilter", function()
		if not thermalActive then return end
		if CurTime() >= thermalEndTime then
			thermalActive = false
			return
		end
		
		-- Base thermal color modification (blauw naar rood spectrum)
		local colorTab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0.15,
			["$pp_colour_brightness"] = -0.05,
			["$pp_colour_contrast"] = 1.8,
			["$pp_colour_colour"] = 0.3,
			["$pp_colour_mulr"] = 0.2,
			["$pp_colour_mulg"] = 0.3,
			["$pp_colour_mulb"] = 1.2
		}
		
		DrawColorModify(colorTab)
		DrawSharpen(3, 1.2)
		
		-- Add grain/noise effect for realism
		local noiseAlpha = 15 + math.sin(CurTime() * 10) * 5
		surface.SetMaterial(mat_noise)
		surface.SetDrawColor(255, 255, 255, noiseAlpha)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		
		-- Vignette effect (donkere randen)
		local w, h = ScrW(), ScrH()
		local centerX, centerY = w / 2, h / 2
		
		for i = 0, 360, 30 do
			local rad = math.rad(i)
			local x1 = centerX + math.cos(rad) * w * 0.6
			local y1 = centerY + math.sin(rad) * h * 0.6
			local x2 = centerX + math.cos(rad) * w
			local y2 = centerY + math.sin(rad) * h
			
			surface.SetDrawColor(0, 0, 20, 150)
			surface.DrawLine(x1, y1, x2, y2)
		end
	end)
	
	-- Thermal player highlighting (hete spelers lichten fel op)
	hook.Add("PostDrawTranslucentRenderables", "SniperTag_ThermalHighlight", function()
		if not thermalActive then return end
		if CurTime() >= thermalEndTime then
			thermalActive = false
			return
		end
		
		local localPly = LocalPlayer()
		if not IsValid(localPly) then return end
		
		-- Find all players to highlight
		local targets = {}
		for _, ply in ipairs(player.GetAll()) do
			if ply ~= localPly and ply:Alive() then
				table.insert(targets, ply)
			end
		end
		
		if #targets > 0 then
			-- Thermal gradient: warmer = hotter colors
			local pulse = math.abs(math.sin(CurTime() * 2))
			
			-- Verschillende kleuren voor verschillende rollen
			local hiders = {}
			local snipers = {}
			
			for _, ply in ipairs(targets) do
				local role = ply:GetNWInt("SniperTag_Role", 0)
				if role == SniperTag.Config.Roles.HIDER then
					table.insert(hiders, ply)
				elseif role == SniperTag.Config.Roles.SNIPER then
					table.insert(snipers, ply)
				end
			end
			
			-- Hider = WIT/GEEL (heel heet - meeste hitte)
			if #hiders > 0 then
				local r = 255
				local g = math.floor(240 + pulse * 15)
				local b = math.floor(200 + pulse * 55)
				halo.Add(hiders, Color(r, g, b, 255), 8, 8, 3, true, true)
			end
			
			-- Sniper = ORANJE/ROOD (warm)
			if #snipers > 0 then
				local r = 255
				local g = math.floor(100 + pulse * 50)
				local b = 50
				halo.Add(snipers, Color(r, g, b, 255), 5, 5, 2, true, true)
			end
		end
	end)
	
	-- HUD overlay voor thermal camera (target markers, scan lines, etc)
	hook.Add("HUDPaint", "SniperTag_ThermalHUD", function()
		if not thermalActive then return end
		if CurTime() >= thermalEndTime then
			thermalActive = false
			return
		end
		
		local w, h = ScrW(), ScrH()
		
		-- Thermal camera border/frame
		surface.SetDrawColor(0, 150, 200, 100)
		surface.DrawRect(0, 0, w, 4)
		surface.DrawRect(0, h - 4, w, 4)
		surface.DrawRect(0, 0, 4, h)
		surface.DrawRect(w - 4, 0, 4, h)
		
		-- Scanning lines effect
		local scanY = (CurTime() * 200) % h
		surface.SetDrawColor(0, 255, 255, 30)
		surface.DrawRect(0, scanY, w, 2)
		surface.DrawRect(0, scanY - h/2, w, 2)
		
		-- Thermal mode indicator
		draw.SimpleText("THERMAL ACTIVE", "DermaDefault", w - 10, 10, Color(0, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Temperature gradient reference (optional)
		local gradientW = 150
		local gradientH = 15
		local gradientX = w - gradientW - 20
		local gradientY = 40
		
		-- Draw gradient bar
		for i = 0, gradientW do
			local factor = i / gradientW
			local r = math.floor(factor * 255)
			local g = math.floor((1 - math.abs(factor - 0.5) * 2) * 255)
			local b = math.floor((1 - factor) * 255)
			
			surface.SetDrawColor(r, g, b, 200)
			surface.DrawRect(gradientX + i, gradientY, 1, gradientH)
		end
		
		-- Labels
		draw.SimpleText("COLD", "DermaDefault", gradientX, gradientY + gradientH + 2, Color(100, 100, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("HOT", "DermaDefault", gradientX + gradientW, gradientY + gradientH + 2, Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end)
end
