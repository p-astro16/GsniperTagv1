-- Sniper Tag - Client Initialization
-- Loads all client-side files

print("[Sniper Tag] Loading client files...")

-- Load shared config first
include("snipertag/shared/sh_config.lua")
include("snipertag/shared/sh_debug.lua")

-- Load client files
include("snipertag/client/cl_hud.lua")
include("snipertag/client/cl_menu.lua")

print("[Sniper Tag] Client files loaded successfully!")
print("[Sniper Tag] Version 1.0")
print("[Sniper Tag] Type 'snipertag_menu' in console to open settings (admin only)")
