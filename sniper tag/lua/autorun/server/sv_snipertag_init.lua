-- Sniper Tag - Server Initialization
-- Loads all server-side files

print("[Sniper Tag] Loading server files...")

-- Load shared config first
include("snipertag/shared/sh_config.lua")
include("snipertag/shared/sh_debug.lua")

-- Add shared config to client download
AddCSLuaFile("snipertag/shared/sh_config.lua")
AddCSLuaFile("snipertag/shared/sh_debug.lua")

-- Add client files to download
AddCSLuaFile("snipertag/client/cl_hud.lua")
AddCSLuaFile("snipertag/client/cl_menu.lua")

-- Load server files
include("snipertag/server/sv_rounds.lua")
include("snipertag/server/sv_player.lua")
include("snipertag/server/sv_anticamping.lua")

print("[Sniper Tag] Server files loaded successfully!")
print("[Sniper Tag] Version 1.0 - Ready to play!")
print("[Sniper Tag] Use Q-Menu > Utilities > Admin > Sniper Tag to configure")
