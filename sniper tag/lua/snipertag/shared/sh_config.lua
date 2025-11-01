-- Sniper Tag - Shared Configuration
-- Deze configuratie wordt gedeeld tussen server en client

-- Initialize global table
SniperTag = SniperTag or {}
SniperTag.Config = SniperTag.Config or {}
SniperTag.Round = SniperTag.Round or {}
SniperTag.HUD = SniperTag.HUD or {}

-- ==========================================
-- STANDAARD INSTELLINGEN
-- ==========================================

-- Ronde instellingen
SniperTag.Config.RoundDuration = 600 -- Standaard 10 minuten (in seconden)
SniperTag.Config.MinRoundDuration = 300 -- Minimum 5 minuten
SniperTag.Config.MaxRoundDuration = 3600 -- Maximum 60 minuten

-- Spawn instellingen
SniperTag.Config.MinSpawnDistance = 3000 -- Minimum afstand tussen Sniper en Hider bij spawn (verhoogd naar 3000 units)

-- Player instellingen
SniperTag.Config.SniperHP = 100
SniperTag.Config.HiderHP = 11

-- Thermal Camera instellingen
SniperTag.Config.ThermalDuration = 20 -- Maximaal 20 seconden gebruik
SniperTag.Config.ThermalCooldown = 20 -- 20 seconden cooldown

-- Cloak Device instellingen
SniperTag.Config.CloakDuration = 60 -- 1 minuut onzichtbaar
SniperTag.Config.CloakCooldown = 180 -- 3 minuten cooldown

-- Anti-Camping instellingen
SniperTag.Config.CampRadius = 200 -- ~2 meter straal (in Hammer units, 1 meter ≈ 100 units)
SniperTag.Config.CampTime = 60 -- 60 seconden voor camping detectie
SniperTag.Config.CampWarningTime = 10 -- 10 seconden waarschuwing

-- Weapon class names
SniperTag.Config.Weapons = {
	Sniper = {
		Primary = "arc9_eft_sv98",
		Secondary = "arc9_eft_m7290",
		Melee = "weapon_thermal"
	},
	Hider = {
		Primary = "weapon_cloak",
		Secondary = "weapon_marker",
		Melee = "arc9_eft_melee_wycc"
	}
}

-- Team/Role definities
SniperTag.Config.Roles = {
	NONE = 0,
	SNIPER = 1,
	HIDER = 2
}

-- Kleuren voor HUD
SniperTag.Config.Colors = {
	Sniper = Color(51, 153, 255), -- Blauw
	Hider = Color(255, 204, 51), -- Geel
	Warning = Color(255, 51, 51), -- Rood
	Success = Color(51, 255, 51), -- Groen
	White = Color(255, 255, 255),
	Black = Color(0, 0, 0, 200)
}

-- Game states
SniperTag.Config.GameState = {
	WAITING = 0,
	STARTING = 1,
	ACTIVE = 2,
	ENDING = 3
}

print("[Sniper Tag] Shared configuratie geladen!")
