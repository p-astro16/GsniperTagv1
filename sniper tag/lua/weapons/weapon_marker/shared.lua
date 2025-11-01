-- Marker Gun Weapon
-- Stuurt een "You have been marked" bericht naar de Sniper
-- Doet geen damage, alleen troll-functie

SWEP.PrintName = "Marker Gun"
SWEP.Author = "Sniper Tag"
SWEP.Instructions = "Left Click: Mark the Sniper (troll message)"
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

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.UseHands = true

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	-- Check if player is the Hider
	if ply:GetNWInt("SniperTag_Role", 0) ~= SniperTag.Config.Roles.HIDER then
		return
	end
	
	-- Play shoot sound
	self:EmitSound("weapons/357/357_fire2.wav", 75, 150)
	
	-- Fire trace to see if we're aiming at someone
	local tr = ply:GetEyeTrace()
	
	if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
		local target = tr.Entity
		
		-- Check if target is the Sniper
		if target:GetNWInt("SniperTag_Role", 0) == SniperTag.Config.Roles.SNIPER then
			-- Send message to Sniper
			target:ChatPrint("⚠ You have been marked.")
			
			-- Play sound for Sniper
			target:EmitSound("buttons/button10.wav", 75, 80)
			
			-- Visual effect
			net.Start("SniperTag_MarkerHit")
			net.Send(target)
			
			-- Feedback to Hider
			ply:ChatPrint("✓ Sniper marked successfully!")
		else
			ply:ChatPrint("That's not the Sniper!")
		end
	end
	
	self:SetNextPrimaryFire(CurTime() + 1)
	
	-- Muzzle flash
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	ply:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
	-- No secondary attack
end

function SWEP:DrawHUD()
	-- Draw simple crosshair
	local x = ScrW() / 2
	local y = ScrH() / 2
	local gap = 10
	local length = 5
	
	surface.SetDrawColor(255, 255, 255, 200)
	
	-- Top
	surface.DrawLine(x, y - gap, x, y - gap - length)
	-- Bottom
	surface.DrawLine(x, y + gap, x, y + gap + length)
	-- Left
	surface.DrawLine(x - gap, y, x - gap - length, y)
	-- Right
	surface.DrawLine(x + gap, y, x + gap + length, y)
end

if SERVER then
	util.AddNetworkString("SniperTag_MarkerHit")
end

if CLIENT then
	net.Receive("SniperTag_MarkerHit", function()
		-- Screen flash effect when marked
		local flashTime = CurTime() + 0.3
		
		hook.Add("RenderScreenspaceEffects", "SniperTag_MarkerFlash", function()
			if CurTime() > flashTime then
				hook.Remove("RenderScreenspaceEffects", "SniperTag_MarkerFlash")
				return
			end
			
			local alpha = math.Clamp((flashTime - CurTime()) / 0.3 * 255, 0, 100)
			
			surface.SetDrawColor(255, 50, 50, alpha)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end)
	end)
end
