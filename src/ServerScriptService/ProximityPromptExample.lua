-- ProximityPromptExample.lua
-- Example showing how to use AuraService with a ProximityPrompt
-- Place this script as a child of the Part with a ProximityPrompt

local part = script.Parent
local proximityPrompt = part:FindFirstChildOfClass("ProximityPrompt")

if not proximityPrompt then
	error("[ProximityPromptExample] No ProximityPrompt found on " .. part.Name)
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
		error("[ProximityPromptExample] AuraService module not found!")
	end
end

-- ============================================
-- CONFIGURATION
-- ============================================
local AURA_ID = 50
local OPTIONS = {
	cooldown = 0, -- No cooldown for proximity prompts (they have their own holdDuration)
	autoEquip = true,
	announce = false,
	oneTimeOnly = true
}

-- ============================================
-- Using BindProximity (simplest method)
-- ============================================
AuraService:BindProximity(proximityPrompt, AURA_ID, OPTIONS)
print(("[ProximityPromptExample] Bound proximity prompt on %s to give aura %d"):format(part.Name, AURA_ID))
