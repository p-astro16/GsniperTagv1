-- Sniper Tag - Error Handler & Debug
-- Catches errors and provides debug information

if SERVER then
	-- Convar for debug mode
	CreateConVar("snipertag_debug", "0", FCVAR_ARCHIVE, "Enable debug messages for Sniper Tag")
	
	-- Debug print function
	function SniperTag.DebugPrint(...)
		if GetConVar("snipertag_debug"):GetBool() then
			print("[Sniper Tag DEBUG]", ...)
		end
	end
	
	-- Error handler
	hook.Add("OnLuaError", "SniperTag_ErrorHandler", function(err, realm, stack, name, id)
		if string.find(err, "snipertag") or string.find(err, "SniperTag") then
			print("[Sniper Tag ERROR] " .. err)
			print("[Sniper Tag ERROR] Stack: " .. stack)
		end
	end)
else
	-- Client debug
	function SniperTag.DebugPrint(...)
		-- Client debug messages can be shown in console
		print("[Sniper Tag DEBUG]", ...)
	end
end

print("[Sniper Tag] Error handler loaded!")
