-- ClickDetectorExample.lua
-- Example showing how to use AuraService with a ClickDetector
-- Place this script as a child of the Part with a ClickDetector

local part = script.Parent
local clickDetector = part:FindFirstChildOfClass("ClickDetector")

if not clickDetector then
	error("[ClickDetectorExample] No ClickDetector found on " .. part.Name)
end

-- Load AuraService
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraService
do
	local auraModule = ServerScriptService:FindFirstChild("AuraService") or ReplicatedStorage:FindFirstChild("AuraService")
	if auraModule then
		AuraService = require(auraModule)
	else
		error("[ClickDetectorExample] AuraService module not found!")
	end
end

-- ============================================
-- CONFIGURATION
-- ============================================
local AURA_ID = 43
local OPTIONS = {
	cooldown = 10,
	autoEquip = true,
	announce = true,
	oneTimeOnly = true
}

-- ============================================
-- METHOD 1: Using BindClick (recommended - simplest)
-- ============================================
print(("[ClickDetectorExample] Binding click detector on %s to give aura %d"):format(part.Name, AURA_ID))
print(("[ClickDetectorExample] Options: cooldown=%d, autoEquip=%s, announce=%s, oneTimeOnly=%s"):format(
	OPTIONS.cooldown, tostring(OPTIONS.autoEquip), tostring(OPTIONS.announce), tostring(OPTIONS.oneTimeOnly)))

-- Add manual connection with explicit debug logging
clickDetector.Activated:Connect(function(player)
	print(("[ClickDetectorExample] Click detected! Player: %s"):format(player and player.Name or "nil"))
	local success, result = AuraService:GiveAuraToPlayer(AURA_ID, player, OPTIONS)
	if success then
		print(("[ClickDetectorExample] ✅ Successfully gave aura to %s"):format(player.Name))
	else
		print(("[ClickDetectorExample] ❌ Failed to give aura to %s: %s"):format(player.Name, tostring(result)))
	end
end)

print(("[ClickDetectorExample] ✅ Setup complete - ready to give aura %d"):format(AURA_ID))

-- ============================================
-- METHOD 2: Using MakeHandler (alternative)
-- ============================================
-- clickDetector.Activated:Connect(AuraService:MakeHandler(AURA_ID, OPTIONS))

-- ============================================
-- METHOD 3: Manual connection (if you need custom logic)
-- ============================================
--[[
clickDetector.Activated:Connect(function(player)
	-- Add your custom logic here before/after giving aura
	local success, result = AuraService:GiveAuraToPlayer(AURA_ID, player, OPTIONS)
	if success then
		print("Custom logic after successful aura give")
	end
end)
]]
